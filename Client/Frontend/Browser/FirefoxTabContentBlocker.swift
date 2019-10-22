/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit
import Shared

/**
 Firefox-specific implementation of tab content blocking.
 */
class FirefoxTabContentBlocker: TabContentBlocker, TabContentScript {
    let userPrefs: Prefs

    class func name() -> String {
        return "TrackingProtectionStats"
    }

    var isUserEnabled: Bool? {
        didSet {
            guard let tab = tab as? Tab else { return }
            setupForTab()
            TabEvent.post(.didChangeContentBlocking, for: tab)
            tab.reload()
        }
    }

    override var isEnabled: Bool {
        if let enabled = isUserEnabled {
            return enabled
        }
        guard let _ = self.tab as? Tab else { return false }
        return self.isEnabledInBrowsing
    }

    var isEnabledInBrowsing: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.BrowsingEnabledKey) ?? true
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: isEnabled, rules: BlocklistName.all)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()
    }

    override func currentlyEnabledLists() -> [BlocklistName] {
        return BlocklistName.all
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {
    static func setTrackingProtection(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.BrowsingEnabledKey)
        ContentBlocker.shared.prefsChanged()
    }

    static func isTrackingProtectionEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isEnabledInBrowsing
    }

    static func toggleTrackingProtectionEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isTrackingProtectionEnabled(tabManager: tabManager)
        setTrackingProtection(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }
}
