//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React

@objc(BrowserSearch)
class BrowserSearch: NSObject, NativeModuleBase {

    @objc(get:reject:)
    public func get(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.withAppDelegate { (appDel) in
            guard let profile = appDel.profile else {
                resolve(nil)
                return
            }
            let engines = profile.searchEngines.orderedEngines.filter({
                return profile.searchEngines.isEngineEnabled($0)
            }).map { self.serializeSearchEngine($0, searchEngines: profile.searchEngines) }
            resolve(engines)
        }
    }

    @objc(search:name:)
    public func search(query: NSString, name: NSString) {
        self.withAppDelegate { (appDel) in
            guard let engine = appDel.profile?.searchEngines.orderedEngines.first(where: { $0.shortName == name as String }) else {
                return
            }
            if let url = engine.searchURLForQuery(query as String) {
                appDel.useCases.openLink.openLink(url: url, visitType: .link, query: query as String)
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    private func serializeSearchEngine(_ engine: OpenSearchEngine, searchEngines: SearchEngines) -> [String: Any] {
        return [
            "name": engine.shortName,
            "isDefault": searchEngines.isEngineDefault(engine),
            "favIconUrl": engine.searchURLForQuery("")?.absoluteString ?? "", ]
    }
}
