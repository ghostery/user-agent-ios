//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

import React

@objc(SearchEnginesModule)
class SearchEnginesModule: RCTEventEmitter {

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["SearchEngines:SetDefault"]
    }

    @objc(getSearchEngines:reject:)
    func getSearchEngines(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {

        DispatchQueue.main.async {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                if let searchEngines = appDel.profile?.searchEngines.orderedEngines {
                    var engines = [[String: Any]]()

                    for i in 0..<searchEngines.count {
                        let searchEngine = searchEngines[i].toDictionary(isDefault: i==0)
                        engines.append(searchEngine)
                    }
                    resolve(engines)
                    return
                } else {
                    reject("SeachEngineError", "Could not retrieve search engines", nil)
                }
            } else {
                reject("AppError", "Could not find AppDelegate", nil)
            }
        }
    }
}
