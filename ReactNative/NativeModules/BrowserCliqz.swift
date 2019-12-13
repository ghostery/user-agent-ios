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

@objc(BrowserCliqz)
class BrowserCliqz: RCTEventEmitter, NativeModuleBase {
    private let PrefMapping = [
        "toolkit.telemetry.enabled": AppConstants.PrefSendUsageData,
    ]

    private let OtherPrefMapping = [
        "distribution.version": { AppInfo.appVersion },
    ]

    @objc(getPref:resolve:reject:)
    public func getPref(key: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {

        if let valueGetter = OtherPrefMapping[key as String] {
            resolve(valueGetter())
            return
        }

        guard let pref = PrefMapping[key as String] else {
            resolve(nil)
            return
        }

        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                resolve(nil)
                return
            }
            resolve(profile.prefs.objectForKey(pref) as Any?)
        }
    }

    @objc(addPrefListener:)
    public func addPrefListener(key: NSString) {
        guard let pref = PrefMapping[key as String] else { return }

        self.withAppDelegate { appDel in
            appDel.profile?.prefs.addListener(pref, callback: {
                self.sendEvent(withName: "prefChange", body: key)
            })
        }
    }

    @objc(removePrefListener:)
    public func removePrefListener(key: NSString) {
        guard let pref = PrefMapping[key as String] else { return }
        self.withAppDelegate { appDel in
            appDel.profile?.prefs.removeListener(pref)
        }
    }

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["prefChange"]
    }
}
