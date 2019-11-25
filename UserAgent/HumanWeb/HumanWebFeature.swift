//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

class HumanWebFeature: NSObject {
    private weak var browserCore: BrowserCore!
    private weak var tabManager: TabManager!

    init(tabManager: TabManager) {
        super.init()
        self.tabManager = tabManager
        self.tabManager.addNavigationDelegate(self)
    }

    // TODO: background task
}

extension HumanWebFeature: WKNavigationDelegate, BrowserCoreClient {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return
        }

        self.browserCore.notifyLocationChange(url)
    }
}
