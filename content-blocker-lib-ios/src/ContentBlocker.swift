/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared

private let HIDE_ADS_RULE = """
{
    "trigger": {
        "url-filter": ".*"
    },
    "action": {
        "type": "css-display-none",
        "selector": "#tads"
    }
}
"""

private let HIDE_POPUPS_RULE = """
{
    "action": {
        "type": "ignore-previous-rules"
    },
    "trigger": {
        "url-filter": ".*",
        "if-domain": ["*www.spiegel.de"]
    }
}
"""

enum BlocklistName: String {
    case advertisingNetwork = "advertisingNetwork"
    case advertisingCosmetic = "advertisingCosmetic"
    case trackingNetwork = "trackingNetwork"
    case popupsCosmetic = "popupsCosmetic"
    case popupsNetwork = "popupsNetwork"

    var filename: String {
        switch self {
        case .advertisingNetwork:
            return "safari-ads-network"
        case .advertisingCosmetic:
            return "safari-ads-cosmetic"
        case .trackingNetwork:
            return "safari-tracking-network"
        case .popupsCosmetic:
            return "safari-popups-cosmetic"
        case .popupsNetwork:
            return "safari-popups-network"
        }
    }

    static let all: [BlocklistName] = [
        .advertisingNetwork,
        .advertisingCosmetic,
        .trackingNetwork,
        .popupsCosmetic,
        .popupsNetwork,
    ]
}

enum BlockerStatus: String {
    case Disabled
    case NoBlockedURLs // When TP is enabled but nothing is being blocked
    case AdBlockAllowListed
    case AntiTrackingAllowListed
    case AllowListed
    case Blocking
}

internal class AllowLists {
    public let ads = AllowList(allowListFilename: "ads_whitelist", blocklists: [.advertisingNetwork, .advertisingCosmetic])
    public let trackers = AllowList(allowListFilename: "whitelist", blocklists: [.trackingNetwork])
    public let popups = AllowList(allowListFilename: "popups_whitelist", blocklists: [.popupsNetwork, .popupsCosmetic])

    var cleanupStore: AllowList.CleanupStore? {
        didSet {
            self.ads.cleanupStore = cleanupStore
            self.trackers.cleanupStore = cleanupStore
            self.popups.cleanupStore = cleanupStore
        }
    }

    init() {}
}

class ContentBlocker {
    internal let allowLists = AllowLists()

    let ruleStore: WKContentRuleListStore = WKContentRuleListStore.default()
    var setupCompleted = false

    static let shared = ContentBlocker()

    private init() {
        self.allowLists.cleanupStore = { (blocklists, completion) in
            self.clearAllowLists(fromLists: blocklists, completion: completion)
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

    func clearAllowLists(fromLists: [BlocklistName] = [], completion: (() -> Void)?) {
        self.removeAllRulesInStore(fromLists: fromLists) {
            self.compileListsNotInStore {
                completion?()
                NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
            }
        }
    }

    // Ensure domains used for allowListing are standardized by using this function.
    func allowListableDomain(fromUrl url: URL) -> String? {
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

    func removeAllRulesInStore(fromLists: [BlocklistName] = [], completion: @escaping () -> Void) {
        let filenamesOfListToClean = fromLists.map { $0.filename }

        ruleStore.getAvailableContentRuleListIdentifiers { available in
            guard var available = available else {
                completion()
                return
            }

            available = available.filter { filenamesOfListToClean.contains($0) }

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
        guard let fileDate = dateOfMostRecentBlockerFile() else {
            completion()
            return
        }

        guard let prefsNewestDate = UserDefaults.standard.object(forKey: "blocker-file-date") as? Date else {
            UserDefaults.standard.set(fileDate, forKey: "blocker-file-date")
            removeAllRulesInStore() {
                completion()
            }
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
                    case .advertisingNetwork:
                        str = str.replacingCharacters(in: range, with: self.adsAllowListAsJSON() + "]")
                    case .advertisingCosmetic:
                        str = str.replacingCharacters(in: range, with: self.adsAllowListAsJSON() + "," + HIDE_ADS_RULE + "]")
                    case .trackingNetwork:
                        str = str.replacingCharacters(in: range, with: self.trackingAllowListAsJSON() + "]")
                    case .popupsNetwork:
                        str = str.replacingCharacters(in: range, with: self.popupsAllowListAsJSON() + "," + HIDE_POPUPS_RULE + "]")
                    case .popupsCosmetic:
                        str = str.replacingCharacters(in: range, with: self.popupsAllowListAsJSON() + "," + HIDE_POPUPS_RULE + "]")
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
