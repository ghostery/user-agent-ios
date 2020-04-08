//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React
import Storage

class HomeView: UIView {
    private var speedDials: [Site]?
    private var pinnedSites: [Site]?
    private var isNewsEnabled = true
    private var isNewsImagesEnabled = true
    private var reactView: UIView?
    private var height: Int?
    private var toolbarHeight: CGFloat

    override init(frame: CGRect) {
        self.toolbarHeight = 0
        super.init(frame: frame)
    }

    convenience init(
        toolbarHeight: CGFloat,
        speedDials: [Site],
        pinnedSites: [Site],
        isNewsEnabled: Bool,
        isNewsImagesEnabled: Bool
    ) {
        self.init(frame: .zero)
        self.toolbarHeight = toolbarHeight
        self.pinnedSites = pinnedSites
        self.speedDials = speedDials
        self.isNewsEnabled = isNewsEnabled
        self.isNewsImagesEnabled = isNewsImagesEnabled
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func layoutSubviews() {
        let height = Int(self.bounds.height)
        if height == self.height ?? 0 {
            super.layoutSubviews()
            return
        } else {
            self.height = height
        }

        if let reactView = self.reactView {
            reactView.removeFromSuperview()
            self.reactView = nil
        }

        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Home",
            initialProperties: [
                "speedDials": self.speedDials!.map { $0.toDict() },
                "pinnedSites": self.pinnedSites!.map { $0.toDict() },
                "isNewsEnabled": self.isNewsEnabled,
                "isNewsImagesEnabled": self.isNewsImagesEnabled,
                "height": height,
                "toolbarHeight": self.toolbarHeight,
            ]
        )

        reactView.backgroundColor = .clear
        reactView.frame = self.bounds
        self.reactView = reactView

        self.addSubview(reactView)

        super.layoutSubviews()
    }
}
