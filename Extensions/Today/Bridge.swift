//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

@objc(Bridge)
class Bridge: RCTEventEmitter {
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["theme"]
    }

    @objc(configure)
    func configure() {
        guard let scheme = Bundle.main.infoDictionary?["AppURLScheme"] else {
            return
        }
        guard let url = URL(string: "\(scheme)://deep-link?url=/settings/today-widget-setting") else {
            return
        }
        ReactNativeBridge.sharedInstance.extensionContext?.open(url, completionHandler: nil)
    }
}
