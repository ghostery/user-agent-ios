//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

/*
 * Remeber to assign url and set view constraints.
 */
class LogoView: UIView {
    public var url: String? {
        willSet(newUrl) {
            guard newUrl != url else {
                return
            }
            self.cleanReactView()
        }
    }

    private var reactView: RCTRootView?
    private var size: CGFloat?

    override func layoutSubviews() {
        super.layoutSubviews()
        if self.reactView != nil && (self.bounds.height == self.size) {
            return
        }

        // In case the view have resized the React has to be re-created
        self.size = self.bounds.height
        self.cleanReactView()

        guard let reactView = self.createLogoView() else { return }
        self.reactView = reactView
        self.addSubview(reactView)
    }

    private func cleanReactView() {
        self.reactView?.removeFromSuperview()
        self.reactView = nil
    }

    private func createLogoView() -> RCTRootView? {
        guard let url = self.url else { return nil }

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
    }
}
