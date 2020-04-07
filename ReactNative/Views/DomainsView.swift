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

class DomainsView: UIView {
    var toolbarHeight: CGFloat
    private lazy var reactView: UIView = {
        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "History",
            initialProperties: [
                "toolbarHeight": self.toolbarHeight,
            ]
        )

        reactView.backgroundColor = .clear
        return reactView
    }()

    override init(frame: CGRect) {
        self.toolbarHeight = 0
        super.init(frame: frame)
    }

    convenience init(toolbarHeight: CGFloat) {
        self.init(frame: .zero)
        self.toolbarHeight = toolbarHeight
        self.addSubview(self.reactView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.reactView.frame = self.bounds
    }
}
