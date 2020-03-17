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
                "city": self.getCity(),
                "theme": self.getTheme(),
            ]
        )

        reactView.backgroundColor = .clear

        self.view = reactView

        completionHandler(NCUpdateResult.newData)
    }

    private func getTheme() -> [String: String] {
        var mode = "light"
        if #available(iOS 13.0, *) {
            mode = UITraitCollection.current.userInterfaceStyle == .dark ? "dark" : "light"
        }
        let textColor = mode == "dark" ? "rgba(255, 255, 255, 0.61)" : "rgba(0, 0, 0, 0.61)"
        return [
            "textColor": textColor,
            "descriptionColor": textColor,
            "separatorColor": "transparent",
        ]
    }

    private func getCity() -> String {
        return "Munich"
    }
}
