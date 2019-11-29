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

    override var isPrivacyDashboardEnabled: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.PrivacyDashboardEnabledKey) ?? true
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: self.isPrivacyDashboardEnabled, rules: BlocklistName.all)
    }

    @objc override func notifiedTabSetupRequired() {
        setupForTab()
    }

    override func notifyContentBlockingChanged() {
        guard let tab = tab as? Tab else { return }
        TabEvent.post(.didChangeContentBlocking, for: tab)
    }
}

// Static methods to access user prefs for tracking protection
extension FirefoxTabContentBlocker {

    static func setPrivacyDashboard(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.PrivacyDashboardEnabledKey)
        ContentBlocker.shared.prefsChanged()
    }

    static func isPrivacyDashboardEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isPrivacyDashboardEnabled
    }

    static func togglePrivacyDashboardEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isPrivacyDashboardEnabled(tabManager: tabManager)
        self.setPrivacyDashboard(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }
}
