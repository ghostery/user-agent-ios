//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React

class ReactNativeBridge {
    static let sharedInstance = ReactNativeBridge()

    lazy var bridge: RCTBridge = RCTBridge(delegate: ReactNativeBridgeDelegate(), launchOptions: nil)

    weak var extensionContext: NSExtensionContext?
}

private class ReactNativeBridgeDelegate: NSObject, RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG
            return URL(string: "http://localhost:8081/index.widget.bundle?platform=ios")
        #else
            return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}
