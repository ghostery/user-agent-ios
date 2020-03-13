//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React
import Shared

@objc(UserAgentConstants)
class UserAgentConstants: NSObject {
    @objc
    func constantsToExport() -> [String: Any]! {
         return [
             "channel": self.channel,
             "appVersion": AppInfo.appVersion,
             "installDate": UserAgentConstants.installDate,
             "appName": AppInfo.displayName,
         ]
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    fileprivate var channel: String {
        return "iOS-\(AppInfo.baseBundleIdentifier)"
    }

    static var installDate: String {
        let installDate: Date

        let InstallDateKey = "InstallDateKey"

        // Installion date was stored without any prefix in previous generation
        // of Cliqz browser. It should be migrated to profile.
        let localDataStore = NSUserDefaultsPrefs(prefix: "")

        if let installDateTime = localDataStore.objectForKey(InstallDateKey) as Double? {
            installDate = Date(timeIntervalSince1970: installDateTime)
        } else {
            installDate = Date()
            localDataStore.setObject(installDate.timeIntervalSince1970, forKey: InstallDateKey)
        }

        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyyMMdd"
        return dateformat.string(from: installDate)
    }
}
