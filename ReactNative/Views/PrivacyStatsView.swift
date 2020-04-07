//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

class PrivacyStatsView: UIView, PhotonCustomViewCellContent {
    var onSizeChange: (() -> Void)?

    private lazy var reactView: RCTRootView = {
        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "PrivacyStats",
            initialProperties: [:]
        )

        reactView.delegate = self
        reactView.backgroundColor = .clear
        reactView.sizeFlexibility = .height

        return reactView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.addSubview(self.reactView)
        self.snp.makeConstraints { (make) in
            make.height.equalTo(100)
        }
        self.reactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
}

extension PrivacyStatsView: RCTRootViewDelegate {
    func rootViewDidChangeIntrinsicSize(_ rootView: RCTRootView!) {
        if rootView.intrinsicContentSize.height == self.frame.size.height {
            return
        }
        self.snp.updateConstraints { (make) in
            make.height.equalTo(rootView.intrinsicContentSize.height)
        }
        self.onSizeChange?()
    }
}
