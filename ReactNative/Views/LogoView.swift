//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

class LogoView: UIView {
    private var url: String?
    private lazy var reactView: UIView = {
        guard let url = self.url else { return UIView() }

        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Logo",
            initialProperties: [
                "url": url,
                "size": self.bounds.width,
            ]
        )!

        reactView.backgroundColor = .clear
        return reactView
    }()

    init(frame: CGRect, url: String) {
        super.init(frame: frame)
        self.url = url
        self.addSubview(self.reactView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}
