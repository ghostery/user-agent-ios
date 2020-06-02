//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared
import React

@objc(Constants)
class Constants: NSObject {
    @objc
    func constantsToExport() -> [String: Any]! {
        var colorScheme = "light"
        if #available(iOS 13.0, *) {
            colorScheme = UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
        }
        return [
            "isDebug": self.isDebug,
            "isCI": self.isCI,
            "userAgent": UserAgent.getUserAgent(),
            "bundleIdentifier": AppInfo.applicationBundle.bundleIdentifier ?? "",
            "version": AppInfo.appVersion,
            "initialTheme": Self.getTheme(mode: colorScheme),
            "Features": Features.toDict(),
        ]
    }

    private var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    private var isCI: Bool {
        #if CI
            return true
        #else
            return false
        #endif
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(getTheme:resolve:reject:)
    func getTheme(
        mode: String,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        resolve(Self.getTheme(mode: mode))
    }

    static func getTheme(mode: String) -> [String: Any] {
        return [
            "mode": mode,
            "backgroundColor": Theme.browser.homeBackground.hexString,
            "textColor": Theme.browser.tint.hexString,
            "descriptionColor": mode == "dark" ? UIColor.White.withAlphaComponent(0.61).hexString : UIColor.black.withAlphaComponent(0.61).hexString,
            "visitedColor": mode == "dark" ? "#BDB6FF" : "#610072",
            "separatorColor": Theme.homePanel.separatorColor.hexString,
            "unsafeUrlColor": mode == "dark" ? "#BE9681" : "#5D4037",
            "urlColor": mode == "dark" ? "#6BA573" : "#579D61",
            "linkColor": mode == "dark" ? "#FFFFFF" : "#003172",
            "redColor": "#E64C68",
            "tintColor": Theme.toolbarButton.selectedTint.hexString,
            "fontSizeSmall": DynamicFontHelper.defaultHelper.SmallSizeRegularWeightAS.pointSize,
            "fontSizeMedium": DynamicFontHelper.defaultHelper.MediumSizeRegularWeightAS.pointSize,
            "fontSizeLarge": DynamicFontHelper.defaultHelper.LargeSizeRegularWeightAS.pointSize,
            "brandColor": UIColor.Blue.hexString,
            "brandTintColor": Theme.general.controlTint.hexString,
        ]
    }
}
