//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
import React

typealias BrowserCore = JSBridge

extension BrowserCore {
    func notifyLocationChange(_ url: URL) {
        self.callAction(
            module: "BrowserCore",
            action: "notifyLocationChange",
            args: [url.absoluteString])
    }

    func notifySearchEngineChange() {
        let searchEnginesModule = bridge.module(for: SearchEnginesModule.self) as! SearchEnginesModule
        searchEnginesModule.sendEvent(withName: "SearchEngines:SetDefault", body: nil)
    }
}
