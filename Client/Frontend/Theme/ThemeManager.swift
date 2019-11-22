/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

enum ThemeManagerPrefs: String {
    case themeName = "prefKeyThemeName"
}

class ThemeManager {
    static let instance = ThemeManager()

    var current: Theme = themeFrom(name: UserDefaults.standard.string(forKey: ThemeManagerPrefs.themeName.rawValue)) {
        didSet {
            UserDefaults.standard.set(current.name, forKey: ThemeManagerPrefs.themeName.rawValue)
            NotificationCenter.default.post(name: .DisplayThemeChanged, object: nil)
        }
    }

    var currentName: BuiltinThemeName {
        return BuiltinThemeName(rawValue: ThemeManager.instance.current.name) ?? .normal
    }

    // UIViewControllers / UINavigationControllers need to have `preferredStatusBarStyle` and call this.
    var statusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark && currentName == .normal {
                return .darkContent
            }
        }

        return currentName == .dark ? .lightContent : .default
    }

}

private func themeFrom(name: String?) -> Theme {
    guard let name = name, let theme = BuiltinThemeName(rawValue: name) else { return NormalTheme() }
    switch theme {
    case .dark:
        return DarkTheme()
    default:
        return NormalTheme()
    }
}
