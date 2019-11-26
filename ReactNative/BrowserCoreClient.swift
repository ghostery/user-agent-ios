//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol BrowserCoreClient {
    var browserCore: BrowserCore { get }
    static var browserCore: BrowserCore { get }
}

extension BrowserCoreClient {
    var browserCore: BrowserCore {
        return ReactNativeBridge.sharedInstance.browserCore
    }

    static var browserCore: BrowserCore {
        return ReactNativeBridge.sharedInstance.browserCore
    }
}
