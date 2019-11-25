//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

class HumanWebFeature: NSObject {
    private weak var tabManager: TabManager!
    private let queue = DispatchQueue(label: "human-web")
    private let delayedInteraval = DispatchTimeInterval.seconds(30)

    init(tabManager: TabManager) {
        super.init()
        self.tabManager = tabManager
        self.tabManager.addNavigationDelegate(self)
    }
}

extension HumanWebFeature: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy
    ) -> Void) {
        guard let url = navigationAction.request.url else {
            return
        }

        self.notifyLocationChange(url)

        self.queue.asyncAfter(deadline: .now() + delayedInteraval) {
            self.processPendingJobs()
        }
    }
}

extension HumanWebFeature: BrowserCoreClient {
    func notifyLocationChange(_ url: URL) {
        self.browserCore.notifyLocationChange(url)
    }

    func processPendingJobs() {
        self.browserCore.callAction(
           module: "human-web-lite",
           action: "processPendingJobs",
           args: [])
    }
}
