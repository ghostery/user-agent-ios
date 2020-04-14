//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import NotificationCenter
import React

@objc(TodayViewController)
class TodayViewController: UIViewController, NCWidgetProviding {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded

        ReactNativeBridge.sharedInstance.extensionContext = self.extensionContext
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .expanded {
            preferredContentSize = CGSize(width: maxSize.width, height: 300)
        } else {
            preferredContentSize = maxSize
        }
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Today",
            initialProperties: [
                "city": self.getCity() as Any,
                "theme": self.getTheme(),
                "i18n": self.getTranslations(),
                "locale": Locale.current.identifier,
            ]
        )

        reactView.backgroundColor = .clear

        self.view = reactView

        completionHandler(NCUpdateResult.newData)
    }

    private func getTheme() -> [String: String] {
        var mode = "light"
        if #available(iOS 13.0, *) {
            mode = self.traitCollection.userInterfaceStyle == .dark ? "dark" : "light"
        }
        let textColor = mode == "dark" ? "rgba(255, 255, 255, 0.61)" : "rgba(0, 0, 0, 0.61)"
        return [
            "textColor": textColor,
            "descriptionColor": textColor,
            "separatorColor": "transparent",
        ]
    }

    private func getCity() -> String? {
        return UserDefaults(suiteName: "group.\(baseBundleIdentifier)")?.string(forKey: "profile.WeatherLocation")
    }

    private func getTranslations() -> [String: String] {
        return [
            "reload": NSLocalizedString("reload", tableName: "Today", comment: "Reload weather data"),
            "configure": NSLocalizedString("configure", tableName: "Today", comment: "Configure weather widget"),
            "expand": NSLocalizedString("expand", tableName: "Today", comment: "Show more info"),
            "collapse": NSLocalizedString("collapse", tableName: "Today", comment: "Show less info"),
        ]
    }

    private var baseBundleIdentifier: String {
        let bundle = Bundle.main
        let packageType = bundle.object(forInfoDictionaryKey: "CFBundlePackageType") as! String
        let baseBundleIdentifier = bundle.bundleIdentifier!
        if packageType == "XPC!" {
            let components = baseBundleIdentifier.components(separatedBy: ".")
            return components[0..<components.count-1].joined(separator: ".")
        }
        return baseBundleIdentifier
    }
}
