/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

enum ThemeManagerPrefs: String {
    case themeName = "prefKeyThemeName"
}

class ThemeManager {
    static let instance = ThemeManager()

    var current: Theme = Theme() {
        didSet {
            // TODO: Remove
            UserDefaults.standard.set(current.name, forKey: ThemeManagerPrefs.themeName.rawValue)
            NotificationCenter.default.post(name: .DisplayThemeChanged, object: nil)
        }
    }

    var currentName: BuiltinThemeName {
        return .normal
    }

    // UIViewControllers / UINavigationControllers need to have `preferredStatusBarStyle` and call this.
    var statusBarStyle: UIStatusBarStyle {
        return currentName == .dark ? .lightContent : .default
    }

}

private func themeFrom(name: String?) -> Theme {
    return Theme()
}
