//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@objc(Constants)
class Constants: NSObject {
    @objc
    func constantsToExport() -> [String: Any]! {
        return [
            "isDebug": self.isDebug,
            "isCI": self.isCI,
        ]
    }

    private var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }

    private var isCI: Bool {
        #if CI
            return true
        #else
            return false
        #endif
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
