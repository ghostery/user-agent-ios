/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared

struct ContentBlockingConfig {
    struct Prefs {
        static let StrengthKey = "prefkey.trackingprotection.strength"
        static let NormalBrowsingTrackingProtectionEnabledKey = "prefkey.trackingprotection.normalbrowsing"
        static let PrivateBrowsingTrackingProtectionEnabledKey = "prefkey.trackingprotection.privatebrowsing"
        static let NormalBrowsingAdBlockingEnabledKey = "prefkey.adBlocking.normalbrowsing"
        static let PrivateBrowsingAdBlockingEnabledKey = "prefkey.adBlocking.privatebrowsing"
    }

    struct Defaults {
        static let NormalBrowsing = true
        static let PrivateBrowsing = true
    }
}

enum BlockingStrength: String {
    case basic
    case strict

    static let allOptions: [BlockingStrength] = [.basic, .strict]
}

/**
 Firefox-specific implementation of tab content blocking.
 */
class FirefoxTabContentBlocker: TabContentBlocker, TabContentScript {
    let userPrefs: Prefs

    class func name() -> String {
        return "TrackingProtectionStats"
    }

    override var isEnabledTrackingProtection: Bool {
        guard let tab = tab as? Tab else { return false }
        return tab.isPrivate ? self.isEnabledTrackingProtectionInPrivateBrowsing : self.isEnabledTrackingProtectionInNormalBrowsing
    }

    override var isEnabledAdBlocking: Bool {
        guard let tab = tab as? Tab else { return false }
        return tab.isPrivate ? self.isEnabledAdBlockingInPrivateBrowsing : self.isEnabledAdBlockingInNormalBrowsing
    }

    var isEnabledTrackingProtectionInNormalBrowsing: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.NormalBrowsingTrackingProtectionEnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    var isEnabledTrackingProtectionInPrivateBrowsing: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.PrivateBrowsingTrackingProtectionEnabledKey) ?? ContentBlockingConfig.Defaults.PrivateBrowsing
    }

    var isEnabledAdBlockingInNormalBrowsing: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.NormalBrowsingAdBlockingEnabledKey) ?? ContentBlockingConfig.Defaults.NormalBrowsing
    }

    var isEnabledAdBlockingInPrivateBrowsing: Bool {
        return userPrefs.boolForKey(ContentBlockingConfig.Prefs.PrivateBrowsingAdBlockingEnabledKey) ?? ContentBlockingConfig.Defaults.PrivateBrowsing
    }

    var blockingStrengthPref: BlockingStrength {
        return userPrefs.stringForKey(ContentBlockingConfig.Prefs.StrengthKey).flatMap(BlockingStrength.init) ?? .basic
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        let adsRules = BlocklistName.ads
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: self.isEnabledAdBlocking, rules: adsRules)
        let trackingRules = BlocklistName.tracking
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: self.isEnabledTrackingProtection, rules: trackingRules)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()
    }

    override func currentlyEnabledLists() -> [BlocklistName] {
        var list = [BlocklistName]()
        if self.isEnabledAdBlocking {
            list.append(contentsOf: BlocklistName.ads)
        }
        if self.isEnabledTrackingProtection {
            list.append(contentsOf: BlocklistName.tracking)
        }
        return list
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {

    static func setTrackingProtection(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        guard let isPrivate = tabManager.selectedTab?.isPrivate else { return }
        let key = isPrivate ? ContentBlockingConfig.Prefs.PrivateBrowsingTrackingProtectionEnabledKey : ContentBlockingConfig.Prefs.NormalBrowsingTrackingProtectionEnabledKey
        prefs.setBool(enabled, forKey: key)
        ContentBlocker.shared.prefsChanged()
    }

    static func setAdBlocking(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        guard let isPrivate = tabManager.selectedTab?.isPrivate else { return }
        let key = isPrivate ? ContentBlockingConfig.Prefs.PrivateBrowsingAdBlockingEnabledKey : ContentBlockingConfig.Prefs.NormalBrowsingAdBlockingEnabledKey
        prefs.setBool(enabled, forKey: key)
        ContentBlocker.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        return isPrivate ? blocker.isEnabledTrackingProtectionInPrivateBrowsing : blocker.isEnabledTrackingProtectionInNormalBrowsing
    }

    static func isAdBlockingEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        let isPrivate = tabManager.selectedTab?.isPrivate ?? false
        return isPrivate ? blocker.isEnabledAdBlockingInPrivateBrowsing : blocker.isEnabledAdBlockingInNormalBrowsing
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isTrackingProtectionEnabled(tabManager: tabManager)
        self.setTrackingProtection(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

    static func toggleAdBlockingEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isAdBlockingEnabled(tabManager: tabManager)
        self.setAdBlocking(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

}
