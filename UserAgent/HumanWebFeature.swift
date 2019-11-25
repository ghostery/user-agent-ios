//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit
import Shared

class HumanWebFeature: NSObject {
    private weak var tabManager: TabManager!
    private let queue = DispatchQueue(label: "human-web")
    private let delayedInteraval = DispatchTimeInterval.seconds(15)
    private var processPendingJobsWorkItem: DispatchWorkItem?

    init(tabManager: TabManager) {
        super.init()
        self.tabManager = tabManager
        self.tabManager.addNavigationDelegate(self)
    }

    private func scheduleProcessPendingJobs() {
        self.processPendingJobsWorkItem?.cancel()

        let workItem = DispatchWorkItem { [weak self] in
            self?.processPendingJobs()
            self?.processPendingJobsWorkItem = nil
        }
        self.processPendingJobsWorkItem = workItem

        self.queue.asyncAfter(
            deadline: .now() + delayedInteraval,
            execute: workItem)
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

        if
            self.tabManager[webView]?.isPrivate ?? false ||
            !url.isWebPage(includeDataURIs: false)
        {
            return
        }

        self.notifyLocationChange(url)

        self.scheduleProcessPendingJobs()
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
