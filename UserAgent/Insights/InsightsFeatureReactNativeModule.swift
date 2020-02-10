//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React

@objc(InsightsFeatureReactNativeModule)
class InsightsFeatureReactNativeModule: NSObject, NativeModuleBase {

    @objc(getTabsState:reject:)
    public func getTabsState(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.withAppDelegate { (appDel) in
            guard let tabManager = appDel.tabManager else {
                resolve(nil)
                return
            }

            let tabsState = tabManager.normalTabs
                .map { InsightsFeature.getTabState($0) }
                .compactMap { $0 }
                .map { $0.asDictionary() }
            resolve(tabsState)
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

}
