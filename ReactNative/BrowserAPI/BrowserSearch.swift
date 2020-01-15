//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React
import Storage
//import Shared

@objc(BrowserSearch)
class BrowserSearch: RCTEventEmitter, NativeModuleBase {

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

    public func search(query: NSString, name: NSString) {
        self.withAppDelegate { (appDel) in
            guard let engine = appDel.profile?.searchEngines.orderedEngines.first(where: { $0.shortName == name as String }) else {
                return
            }
            if let url = engine.searchURLForQuery(query as String), let tab = appDel.tabManager.selectedTab {
                appDel.browserViewController.finishEditingAndSubmit(url, visitType: VisitType.link, forTab: tab)
                if query.length > 0 {
                    tab.queries[url] = String(query)
                }
            }
        }
    }

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    private func serializeSearchEngine(_ engine: OpenSearchEngine, searchEngines: SearchEngines) -> [String: Any] {
        return [
            "name": engine.shortName,
            "isDefault": searchEngines.isEngineDefault(engine),
            "favIconUrl": engine.searchURLForQuery("")?.absoluteString ?? "", ]
    }
}
