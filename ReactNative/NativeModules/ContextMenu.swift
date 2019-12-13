//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@objc(ContextMenu)
class ContextMenuNativeModule: NSObject, NativeModuleBase {

    @objc(speedDial:)
    public func speedDial(url_str: NSString) {
        guard let url = URL(string: url_str as String) else { return }

        self.withAppDelegate { appDel in
            //appDel.useCases
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
