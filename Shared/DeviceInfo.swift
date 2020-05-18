/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

open class DeviceInfo {

    open class func deviceModel() -> String {
        return UIDevice.current.model
    }

    open class func isSimulator() -> Bool {
        return ProcessInfo.processInfo.environment["SIMULATOR_ROOT"] != nil
    }

    open class func hasConnectivity() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
        case .online(.wwan), .online(.wiFi):
            return true
        default:
            return false
        }
    }
}
