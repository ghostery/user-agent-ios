/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import WebKit
import Shared

struct NightModePrefsKey {
    static let NightModeButtonIsInMenu = PrefsKeys.KeyNightModeButtonIsInMenu
    static let NightModeStatus = PrefsKeys.KeyNightModeStatus
    static let NightModeEnabledDarkTheme = PrefsKeys.KeyNightModeEnabledDarkTheme
}

class NightModeHelper: TabContentScript {
    fileprivate weak var tab: Tab?

    required init(tab: Tab) {
        self.tab = tab
    }

    static func name() -> String {
        return "NightMode"
    }

    func scriptMessageHandlerName() -> String? {
        return "NightMode"
    }

    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        // Do nothing.
    }

    static func toggle(_ prefs: Prefs, tabManager: TabManager) {
        let isActive = prefs.boolForKey(NightModePrefsKey.NightModeStatus) ?? false
        setNightMode(prefs, tabManager: tabManager, enabled: !isActive)
        // If we've enabled night mode and the theme is normal, enable dark theme
        if NightModeHelper.isActivated(prefs), ThemeManager.instance.currentName == .normal {
            NightModeHelper.setEnabledDarkTheme(prefs, darkTheme: true)
        }
        // If we've disabled night mode and dark theme was activated by it then disable dark theme
        if !NightModeHelper.isActivated(prefs), NightModeHelper.hasEnabledDarkTheme(prefs), ThemeManager.instance.currentName == .dark {
            NightModeHelper.setEnabledDarkTheme(prefs, darkTheme: false)
        }
    }

    static func setNightMode(_ prefs: Prefs, tabManager: TabManager, enabled: Bool) {
        prefs.setBool(enabled, forKey: NightModePrefsKey.NightModeStatus)
        for tab in tabManager.tabs {
            tab.nightMode = enabled
        }
    }

    static func setEnabledDarkTheme(_ prefs: Prefs, darkTheme enabled: Bool) {
        ThemeManager.instance.current = enabled ? DarkTheme() : NormalTheme()
        prefs.setBool(enabled, forKey: NightModePrefsKey.NightModeEnabledDarkTheme)
    }

    static func hasEnabledDarkTheme(_ prefs: Prefs) -> Bool {
        return prefs.boolForKey(NightModePrefsKey.NightModeEnabledDarkTheme) ?? false
    }

    static func isActivated(_ prefs: Prefs) -> Bool {
        return prefs.boolForKey(NightModePrefsKey.NightModeStatus) ?? false
    }
}
