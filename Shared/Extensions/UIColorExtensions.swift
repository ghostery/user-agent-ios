/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

private struct Color {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
}

public extension UIColor {
    enum AlphaLevel: CGFloat {
        case opaque = 0.0
        case transparent = 1.0

        case tenPercent = 0.1
        case twentyPercent = 0.2
        case thirtyPercent = 0.3
        case fortyPercent = 0.4
        case fiftyPercent = 0.5
        case sixtyPercent = 0.6
        case eightyPercent = 0.8
    }

    /// Return the same color, but with a modified alpha level.
    func with(alpha: AlphaLevel) -> UIColor {
        return self.withAlphaComponent(alpha.rawValue)
    }
}

extension UIColor {
    /**
     * Initializes and returns a color object for the given RGB hex integer.
     */
    public convenience init(rgb: Int) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8)  / 255.0,
            blue: CGFloat((rgb & 0x0000FF) >> 0)  / 255.0,
            alpha: 1)
    }

    public convenience init(rgba: UInt32) {
        self.init(
            red: CGFloat((rgba & 0xFF000000) >> 24) / 255.0,
            green: CGFloat((rgba & 0x00FF0000) >> 16)  / 255.0,
            blue: CGFloat((rgba & 0x0000FF00) >> 8)  / 255.0,
            alpha: CGFloat((rgba & 0x000000FF) >> 0) / 255.0
        )
    }

    public convenience init(hexString: String) {
        let replacedString = hexString.replaceFirstOccurrence(of: "#", with: "")
        var colorInt: UInt32 = 0
        Scanner(string: replacedString).scanHexInt32(&colorInt)
        self.init(rgb: (Int) (colorInt))
    }

    public convenience init(colorString: String) {
        var colorInt: UInt32 = 0
        Scanner(string: colorString).scanHexInt32(&colorInt)
        self.init(rgb: (Int) (colorInt))
    }

    public var hexString: String {
        let colorRef = cgColor.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha

        var color = String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a)))
        }

        return color
    }
}
