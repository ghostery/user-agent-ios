/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import XCGLogger

private let log = Logger.browserLogger

private let OrderedEngineNames = "search.orderedEngineNames"
private let DisabledEngineNames = "search.disabledEngineNames"
private let ResetDisabledEngineNames = "search.reset.disabledEngineNames"
private let ShowSearchSuggestionsOptIn = "search.suggestions.showOptIn"
private let ShowSearchSuggestions = "search.suggestions.show"
private let customSearchEnginesFileName = "customEngines.plist"

/**
 * Manage a set of Open Search engines.
 *
 * The search engines are ordered.  Individual search engines can be enabled and disabled.  The
 * first search engine is distinguished and labeled the "default" search engine; it can never be
 * disabled.  Search suggestions should always be sourced from the default search engine.
 *
 * Two additional bits of information are maintained: whether the user should be shown "opt-in to
 * search suggestions" UI, and whether search suggestions are enabled.
 *
 * Consumers will almost always use `defaultEngine` if they want a single search engine, and
 * `quickSearchEngines()` if they want a list of enabled quick search engines (possibly empty,
 * since the default engine is never included in the list of enabled quick search engines, and
 * it is possible to disable every non-default quick search engine).
 *
 * The search engines are backed by a write-through cache into a ProfilePrefs instance.  This class
 * is not thread-safe -- you should only access it on a single thread (usually, the main thread)!
 */
class SearchEngines {
    fileprivate let prefs: Prefs
    fileprivate let fileAccessor: FileAccessor
    fileprivate var cliqzSearchEngine: OpenSearchEngine?

    init(prefs: Prefs, files: FileAccessor) {
        self.prefs = prefs
        // By default, show search suggestions
        self.shouldShowSearchSuggestions = prefs.boolForKey(ShowSearchSuggestions) ?? true
        self.fileAccessor = files
        self.orderedEngines = getOrderedEngines()
        self.cliqzSearchEngine = self.getEnginesForLocale().filter({ $0.engineID == "cliqz" }).first
        self.disabledEngineNames = getDisabledEngineNames()
    }

    var defaultEngine: OpenSearchEngine {
        get {
            return self.searchEnginesIncludedCliqz[0]
        }

        set(defaultEngine) {
            // The default engine is always enabled.
            self.enableEngine(defaultEngine)
            // The default engine is always first in the list.
            var orderedEngines = self.orderedEngines.filter { engine in engine.shortName != defaultEngine.shortName }
            orderedEngines.insert(defaultEngine, at: 0)
            self.orderedEngines = orderedEngines
        }
    }

    func isEngineDefault(_ engine: OpenSearchEngine) -> Bool {
        return defaultEngine.shortName == engine.shortName
    }

    // The keys of this dictionary are used as a set.
    fileprivate var disabledEngineNames: [String: Bool]! {
        didSet {
            self.prefs.setObject(Array(self.disabledEngineNames.keys), forKey: DisabledEngineNames)
        }
    }

    var orderedEngines: [OpenSearchEngine]! {
        didSet {
            self.prefs.setObject(self.orderedEngines.map { $0.shortName }, forKey: OrderedEngineNames)
        }
    }

    var searchEnginesIncludedCliqz: [OpenSearchEngine]! {
        guard let cliqz = self.cliqzSearchEngine else {
            return self.orderedEngines
        }
        return [cliqz] + self.orderedEngines
    }

    var quickSearchEngines: [OpenSearchEngine]! {
        return self.searchEnginesIncludedCliqz.filter({ (engine) in !self.isEngineDefault(engine) && self.isEngineEnabled(engine) })
    }

    var shouldShowSearchSuggestions: Bool {
        didSet {
            self.prefs.setObject(shouldShowSearchSuggestions, forKey: ShowSearchSuggestions)
        }
    }

    func isEngineEnabled(_ engine: OpenSearchEngine) -> Bool {
        return disabledEngineNames.index(forKey: engine.shortName) == nil
    }

    func enableEngine(_ engine: OpenSearchEngine) {
        disabledEngineNames.removeValue(forKey: engine.shortName)
    }

    func disableEngine(_ engine: OpenSearchEngine) {
        if isEngineDefault(engine) {
            // Can't disable default engine.
            return
        }
        disabledEngineNames[engine.shortName] = true
    }

    func deleteCustomEngine(_ engine: OpenSearchEngine) {
        // We can't delete a preinstalled engine or an engine that is currently the default.
        if !engine.isCustomEngine || isEngineDefault(engine) {
            return
        }

        customEngines.remove(at: customEngines.firstIndex(of: engine)!)
        saveCustomEngines()
        orderedEngines = getOrderedEngines()
    }

    /// Adds an engine to the front of the search engines list.
    func addSearchEngine(_ engine: OpenSearchEngine) {
        customEngines.append(engine)
        orderedEngines.insert(engine, at: 1)
        saveCustomEngines()
    }

    func isSearchEngineRedirectURL(url: URL, query: String) -> Bool {
        guard let urlHost = (url.host as NSString?)?.deletingPathExtension else {
            return false
        }

        if url.scheme == SearchURL.scheme {
            return true
        }
        /// This is a special behavior of Cliqz SERP, which is going to be removed in near future. Until then the App should ignore those urls in history search.
        if let cliqzMQueriesURL = URL(string: "https://beta.cliqz.com/mqueries"), let host = (cliqzMQueriesURL.host as NSString?)?.deletingPathExtension {
            if host + cliqzMQueriesURL.path == urlHost + url.path {
                return true
            }
        }
        for engine in self.searchEnginesIncludedCliqz {
            guard let searchEngineURL = engine.searchURLForQuery(query as String) else {
                continue
            }
            if let searchEngineURLHost = (searchEngineURL.host as NSString?)?.deletingPathExtension {
                if searchEngineURLHost + searchEngineURL.path == urlHost + url.path {
                    return true
                }
            }
        }
        return false
    }

    func queryForSearchURL(_ url: URL?) -> String? {
        for engine in self.searchEnginesIncludedCliqz {
            guard let searchTerm = engine.queryForSearchURL(url) else { continue }
            return searchTerm
        }
        if let url = url, let searchUrl = SearchURL(url) {
            return searchUrl.query
        }
        return nil
    }

    fileprivate func resetDisabledEngineNamesIfNeeded() {
        let defaultEnabledEnginesIDs = ["google-b-m", "google-b-1-m", "bing", "ddg"]
        let reset = self.prefs.boolForKey(ResetDisabledEngineNames)
        if reset == nil || !reset! {
            var disabledNames = [String]()
            for engine in self.orderedEngines {
                guard let engineID = engine.engineID else {
                    disabledNames.append(engine.shortName)
                    continue
                }
                if !defaultEnabledEnginesIDs.contains(engineID) {
                    disabledNames.append(engine.shortName)
                }
            }
            self.prefs.setObject(Array(disabledNames), forKey: DisabledEngineNames)
            self.prefs.setBool(true, forKey: ResetDisabledEngineNames)
        }
    }

    fileprivate func getDisabledEngineNames() -> [String: Bool] {
        self.resetDisabledEngineNamesIfNeeded()
        if let disabledEngineNames = self.prefs.stringArrayForKey(DisabledEngineNames) {
            var disabledEngineDict = [String: Bool]()
            for engineName in disabledEngineNames {
                disabledEngineDict[engineName] = true
            }
            return disabledEngineDict
        } else {
            return [String: Bool]()
        }
    }

    fileprivate func customEngineFilePath() -> String {
        let profilePath = try! self.fileAccessor.getAndEnsureDirectory() as NSString
        return profilePath.appendingPathComponent(customSearchEnginesFileName)
    }

    fileprivate lazy var customEngines: [OpenSearchEngine] = {
        return NSKeyedUnarchiver.unarchiveObject(withFile: self.customEngineFilePath()) as? [OpenSearchEngine] ?? []
    }()

    fileprivate func saveCustomEngines() {
        NSKeyedArchiver.archiveRootObject(customEngines, toFile: self.customEngineFilePath())
    }

    /// Return all possible language identifiers in the order of most specific to least specific.
    /// For example, zh-Hans-CN will return [zh-Hans-CN, zh-CN, zh].
    class func possibilitiesForLanguageIdentifier(_ languageIdentifier: String) -> [String] {
        var possibilities: [String] = []
        let components = languageIdentifier.components(separatedBy: "-")
        possibilities.append(languageIdentifier)

        if components.count == 3, let first = components.first, let last = components.last {
            possibilities.append("\(first)-\(last)")
        }
        if components.count >= 2, let first = components.first {
            possibilities.append("\(first)")
        }
        return possibilities
    }

    /// Get all bundled (not custom) search engines, with the default search engine first,
    /// but the others in no particular order.
    class func getUnorderedBundledEnginesFor(locale: Locale) -> [OpenSearchEngine] {
        let languageIdentifier = locale.identifier
        let region = locale.regionCode ?? "US"
        let parser = OpenSearchParser(pluginMode: true)

        guard let pluginDirectory = Bundle.main.resourceURL?.appendingPathComponent("SearchPlugins") else {
            assertionFailure("Search plugins not found. Check bundle")
            return []
        }

        guard let defaultSearchPrefs = DefaultSearchPrefs(with: pluginDirectory.appendingPathComponent("list.json")) else {
            assertionFailure("Failed to parse List.json")
            return []
        }
        let possibilities = possibilitiesForLanguageIdentifier(languageIdentifier)
        let engineNames = defaultSearchPrefs.visibleDefaultEngines(for: possibilities, and: region)
        let defaultEngineName = defaultSearchPrefs.searchDefault(for: possibilities, and: region)
        assert(!engineNames.isEmpty, "No search engines")

        return engineNames.map({ (name: $0, path: pluginDirectory.appendingPathComponent("\($0).xml").path) })
            .filter({ FileManager.default.fileExists(atPath: $0.path) })
            .compactMap({ parser.parse($0.path, engineID: $0.name) })
            .sorted { e, _ in e.shortName == defaultEngineName }
    }

    /// Get all known search engines, possibly as ordered by the user.
    fileprivate func getOrderedEngines() -> [OpenSearchEngine] {
        let defaultSearchEngines = self.getEnginesForLocale()
        let unorderedEngines = customEngines + defaultSearchEngines.filter({ $0.engineID != "cliqz" })

        // might not work to change the default.
        guard let orderedEngineNames = prefs.stringArrayForKey(OrderedEngineNames) else {
            // We haven't persisted the engine order, so return whatever order we got from disk.
            return unorderedEngines
        }

        // We have a persisted order of engines, so try to use that order.
        // We may have found engines that weren't persisted in the ordered list
        // (if the user changed locales or added a new engine); these engines
        // will be appended to the end of the list.
        return unorderedEngines.sorted { engine1, engine2 in
            let index1 = orderedEngineNames.firstIndex(of: engine1.shortName)
            let index2 = orderedEngineNames.firstIndex(of: engine2.shortName)

            if index1 == nil && index2 == nil {
                return engine1.shortName < engine2.shortName
            }

            // nil < N for all non-nil values of N.
            if index1 == nil || index2 == nil {
                return index1 ?? -1 > index2 ?? -1
            }

            return index1! < index2!
        }
    }

    private func getEnginesForLocale() -> [OpenSearchEngine] {
        let locale = Locale(identifier: Locale.preferredLanguages.first ?? Locale.current.identifier)
        return SearchEngines.getUnorderedBundledEnginesFor(locale: locale)
    }
}
