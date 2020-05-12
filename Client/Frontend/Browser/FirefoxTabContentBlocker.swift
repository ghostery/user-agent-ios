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

    override var isAntiTrackingEnabled: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.AntiTracking) ?? Features.PrivacyDashboard.isAntiTrackingEnabled
    }

    override var isAdBlockingEnabled: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.Adblocker) ?? Features.PrivacyDashboard.isAdBlockingEnabled
    }

    override var isPopupBlockerEnabled: Bool {
        return self.userPrefs.boolForKey(PrefsKeys.PopupBlocker) ?? Features.PrivacyDashboard.isPopupBlockerEnabled
    }

    init(tab: ContentBlockerTab, prefs: Prefs) {
        userPrefs = prefs
        super.init(tab: tab)
        setupForTab()
    }

    func setupForTab() {
        guard let tab = tab else { return }
        var rules = [BlocklistName]()
        if self.isAdBlockingEnabled {
            rules.append(contentsOf: [.advertisingCosmetic, .advertisingNetwork])
        }
        if self.isAntiTrackingEnabled {
            rules.append(.trackingNetwork)
        }
        if self.isPopupBlockerEnabled {
            rules.append(contentsOf: [.popupsNetwork, .popupsCosmetic])
        }
        let isPrivacyDashboardEnabled = self.isAdBlockingEnabled || self.isAntiTrackingEnabled || self.isPopupBlockerEnabled
        ContentBlocker.shared.setupTrackingProtection(forTab: tab, isEnabled: isPrivacyDashboardEnabled, rules: rules)
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

    static func setAntiTracking(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.AntiTracking)
        ContentBlocker.shared.prefsChanged()
    }

    static func setAdBlocking(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.Adblocker)
        ContentBlocker.shared.prefsChanged()
    }

    static func setPopupBlocker(enabled: Bool, prefs: Prefs, tabManager: TabManager) {
        prefs.setBool(enabled, forKey: PrefsKeys.PopupBlocker)
        ContentBlocker.shared.prefsChanged()
    }

    static func isAntiTrackingEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isAntiTrackingEnabled
    }

    static func isAdBlockingEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isAdBlockingEnabled
    }

    static func isPopupBlockerEnabled(tabManager: TabManager) -> Bool {
        guard let blocker = tabManager.selectedTab?.contentBlocker else { return false }
        return blocker.isPopupBlockerEnabled
    }

    static func toggleAntiTrackingEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isAntiTrackingEnabled(tabManager: tabManager)
        self.setAntiTracking(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

    static func toggleAdBlockingEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isAdBlockingEnabled(tabManager: tabManager)
        self.setAdBlocking(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

    static func togglePopupBlockerEnabled(prefs: Prefs, tabManager: TabManager) {
        let isEnabled = FirefoxTabContentBlocker.isPopupBlockerEnabled(tabManager: tabManager)
        self.setPopupBlocker(enabled: !isEnabled, prefs: prefs, tabManager: tabManager)
    }

}
