/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared

enum BlocklistName: String {
    case advertisingNetwork = "advertisingNetwork"
    case advertisingCosmetic = "advertisingCosmetic"
    case trackingNetwork = "trackingNetwork"

    var filename: String {
        switch self {
        case .advertisingNetwork:
            return "safari-ads-network"
        case .advertisingCosmetic:
            return "safari-ads-cosmetic"
        case .trackingNetwork:
            return "safari-tracking-network"
        }
    }

    static var all: [BlocklistName] { return [.advertisingNetwork, .advertisingCosmetic, .trackingNetwork] }
}

enum BlockerStatus: String {
    case Disabled
    case NoBlockedURLs // When TP is enabled but nothing is being blocked
    case AdBlockWhitelisted
    case AntiTrackingWhitelisted
    case Whitelisted
    case Blocking
}

struct WhitelistedDomains {
    var domainSet = Set<String>() {
        didSet {
            domainRegex = domainSet.compactMap { wildcardContentBlockerDomainToRegex(domain: "*" + $0) }
        }
    }

    private(set) var domainRegex = [String]()
}

private let PREVENT_TOP_LEVEL_BLOCKS_RULE = """
{
  "trigger": {
    "url-filter": ".*",
    "load-type": ["first-party"],
    "resource-type": ["document"]
  },
  "action": {
    "type": "ignore-previous-rules"
  }
}
"""

class ContentBlocker {
    var adsWhitelistedDomains = WhitelistedDomains()
    var trackingWhitelistedDomains = WhitelistedDomains()

    let ruleStore: WKContentRuleListStore = WKContentRuleListStore.default()
    var setupCompleted = false

    static let shared = ContentBlocker()

    private init() {
        // Read the whitelist at startup
        if let list = self.readAdsWhitelistFile() {
            self.adsWhitelistedDomains.domainSet = Set(list)
        }

        if let list = self.readAdsWhitelistFile() {
            self.adsWhitelistedDomains.domainSet = Set(list)
        }

        TPStatsBlocklistChecker.shared.startup()

        self.removeOldListsByDateFromStore() {
            self.removeOldListsByNameFromStore() {
                self.compileListsNotInStore {
                    self.setupCompleted = true
                    NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
                }
            }
        }
    }

    // Ensure domains used for whitelisting are standardized by using this function.
    func whitelistableDomain(fromUrl url: URL) -> String? {
        guard let domain = url.host, !domain.isEmpty else {
            return nil
        }
        return domain
    }

    func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // Function to install or remove TP for a tab
    func setupTrackingProtection(forTab tab: ContentBlockerTab, isEnabled: Bool, rules: [BlocklistName]) {
        removeTrackingProtection(forTab: tab)

        if !isEnabled {
            return
        }

        for list in rules {
            let name = list.filename
            ruleStore.lookUpContentRuleList(forIdentifier: name) { rule, error in
                guard let rule = rule else {
                    let msg = "lookUpContentRuleList for \(name):  \(error?.localizedDescription ?? "empty rules")"
                    print("Content blocker error: \(msg)")
                    return
                }
                self.add(contentRuleList: rule, toTab: tab)
            }
        }
    }

    private func removeTrackingProtection(forTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.removeAllContentRuleLists()
    }

    private func add(contentRuleList: WKContentRuleList, toTab tab: ContentBlockerTab) {
        tab.currentWebView()?.configuration.userContentController.add(contentRuleList)
    }
}

// MARK: Initialization code
// The rule store can compile JSON rule files into a private format which is cached on disk.
// On app boot, we need to check if the ruleStore's data is out-of-date, or if the names of the rule files
// no longer match. Finally, any JSON rule files that aren't in the ruleStore need to be compiled and stored in the
// ruleStore.
extension ContentBlocker {
    private func loadJsonFromBundle(forResource file: String, completion: @escaping (_ jsonString: String) -> Void) {
        DispatchQueue.global().async {
            guard let path = Bundle.main.path(forResource: file, ofType: "json"),
                let source = try? String(contentsOfFile: path, encoding: .utf8) else {
                    assert(false)
                    return
            }

            DispatchQueue.main.async {
                completion(source)
            }
        }
    }

    private func lastModifiedSince1970(forFileAtPath path: String) -> Date? {
        do {
            let url = URL(fileURLWithPath: path)
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            guard let date = attr[FileAttributeKey.modificationDate] as? Date else { return nil }
            return date
        } catch {
            return nil
        }
    }

    private func dateOfMostRecentBlockerFile() -> Date? {
        let blocklists = BlocklistName.all

        return blocklists.reduce(Date(timeIntervalSince1970: 0)) { result, list in
            guard let path = Bundle.main.path(forResource: list.filename, ofType: "json") else { return result }
            if let date = lastModifiedSince1970(forFileAtPath: path) {
                return date > result ? date : result
            }
            return result
        }
    }

    func removeAllRulesInStore(completion: @escaping () -> Void) {
        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }
            let deferreds: [Deferred<Void>] = available.map { filename in
                let result = Deferred<Void>()
                self.ruleStore.removeContentRuleList(forIdentifier: filename) { _ in
                    result.fill(())
                }
                return result
            }
            all(deferreds).uponQueue(.main) { _ in
                completion()
            }
        }
    }

    // If any blocker files are newer than the date saved in prefs,
    // remove all the content blockers and reload them.
    func removeOldListsByDateFromStore(completion: @escaping () -> Void) {

        guard let fileDate = dateOfMostRecentBlockerFile(), let prefsNewestDate = UserDefaults.standard.object(forKey: "blocker-file-date") as? Date else {
            completion()
            return
        }

        if fileDate <= prefsNewestDate {
            completion()
            return
        }

        UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
        removeAllRulesInStore() {
            completion()
        }
    }

    func removeOldListsByNameFromStore(completion: @escaping () -> Void) {
        var noMatchingIdentifierFoundForRule = false

        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard let available = available else {
                completion()
                return
            }

            let blocklists = BlocklistName.all.map { $0.filename }
            for contentRuleIdentifier in available {
                if !blocklists.contains(where: { $0 == contentRuleIdentifier }) {
                    noMatchingIdentifierFoundForRule = true
                    break
                }
            }

            guard let fileDate = self.dateOfMostRecentBlockerFile(), let prefsNewestDate = UserDefaults.standard.object(forKey: "blocker-file-date") as? Date else {
                completion()
                return
            }

            if fileDate <= prefsNewestDate && !noMatchingIdentifierFoundForRule {
                completion()
                return
            }

            UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
            self.removeAllRulesInStore {
                completion()
            }
        }
    }

    func compileListsNotInStore(completion: @escaping () -> Void) {
        let deferreds: [Deferred<Void>] = BlocklistName.all.map { item in
            let result = Deferred<Void>()
            ruleStore.lookUpContentRuleList(forIdentifier: item.filename) { contentRuleList, error in
                if contentRuleList != nil {
                    result.fill(())
                    return
                }
                self.loadJsonFromBundle(forResource: item.filename) { jsonString in
                    var str = jsonString
                    guard let range = str.range(of: "]", options: String.CompareOptions.backwards) else { return }
                    switch item {
                    case .advertisingNetwork, .advertisingCosmetic:
                        str = str.replacingCharacters(in: range, with: self.adsWhitelistAsJSON() + "," + PREVENT_TOP_LEVEL_BLOCKS_RULE + "]")
                    case .trackingNetwork:
                        str = str.replacingCharacters(in: range, with: self.trackingWhitelistAsJSON() + "," + PREVENT_TOP_LEVEL_BLOCKS_RULE + "]")
                    }
                    self.ruleStore.compileContentRuleList(forIdentifier: item.filename, encodedContentRuleList: str) { rule, error in
                        if let error = error {
                            print("Content blocker error: \(error)")
                            assert(false)
                        }
                        assert(rule != nil)

                        result.fill(())
                    }
                }
            }
            return result
        }

        all(deferreds).uponQueue(.main) { _ in
            completion()
        }
    }
}
