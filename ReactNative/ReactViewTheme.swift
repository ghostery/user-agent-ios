//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol ReactViewTheme {
    static func getTheme() -> [String: Any]
}

extension ReactViewTheme {
    static func getTheme() -> [String: Any] {
        var mode = "light"
        if #available(iOS 13.0, *) {
            mode = UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
        }
        return [
            "mode": mode,
            "backgroundColor": UIColor.theme.textField.backgroundInOverlay.hexString,
            "textColor": UIColor.theme.browser.tint.hexString,
            "descriptionColor": mode == "dark" ? "rgba(255, 255, 255, 0.61)" : "rgba(0, 0, 0, 0.61)",
            "visitedColor": mode == "dark" ? "#BDB6FF" : "#610072",
            "separatorColor": UIColor.theme.homePanel.separatorColor.hexString,
            "urlColor": mode == "dark" ? "#6BA573" : "#579D61",
            "linkColor": mode == "dark" ? "#FFFFFF" : "#003172",
            "redColor": "#E64C68",
        ]
    }
}
