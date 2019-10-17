//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import React

@objc(BrowserCliqz)
class BrowserCliqz: RCTEventEmitter {
    private let PrefMapping = [
        "toolkit.telemetry.enabled": Preference.SendUsageData.key,
    ]

    @objc(getPref:resolve:reject:)
    public func getPref(key: NSString, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        if key as String == "toolkit.telemetry.enabled" {
            let value = Preference.SendUsageData.get()
            resolve(value)
            return
        }
        resolve(nil)
    }

    @objc(addPrefListener:)
    public func addPrefListener(key: NSString) {
        guard let pref = PrefMapping[key as String] else { return }

        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            appDel.profile?.prefs.addListener(pref, callback: {
                self.sendEvent(withName: "prefChange", body: key)
            })
        }
    }

    @objc(removePrefListener:)
    public func removePrefListener(key: NSString) {
        guard let pref = PrefMapping[key as String] else { return }
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
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
