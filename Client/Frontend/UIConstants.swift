/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

public struct UIConstants {
    static let DefaultPadding: CGFloat = 10
    static let SnackbarButtonHeight: CGFloat = 57
    static let TopToolbarHeight: CGFloat = 50
    static var ToolbarHeight: CGFloat = 46
    static let URLBarViewHeight: CGFloat = 35
    static var BottomToolbarHeight: CGFloat {
        var bottomInset: CGFloat = 0.0
        if let window = UIApplication.shared.keyWindow {
            bottomInset = window.safeAreaInsets.bottom
        }
        return ToolbarHeight + bottomInset
    }

    static let SystemBlueColor = UIColor.CliqzBlue

    // Static fonts
    static let DefaultChromeSize: CGFloat = 16
    static let DefaultChromeSmallSize: CGFloat = 11
    static let PasscodeEntryFontSize: CGFloat = 36
    static let DefaultChromeFont = UIFont.systemFont(ofSize: DefaultChromeSize, weight: UIFont.Weight.regular)
    static let DefaultChromeSmallFontBold = UIFont.boldSystemFont(ofSize: DefaultChromeSmallSize)
    static let PasscodeEntryFont = UIFont.systemFont(ofSize: PasscodeEntryFontSize, weight: UIFont.Weight.bold)

    /// JPEG compression quality for persisted screenshots. Must be between 0-1.
    static let ScreenshotQuality: Float = 0.3
    static let ActiveScreenshotQuality: CGFloat = 0.5
}
