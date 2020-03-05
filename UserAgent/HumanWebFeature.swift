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
            deadline: .now() + DispatchTimeInterval.seconds(Int.random(in: 10..<20)),
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

    static func enable() {
        self.browserCore.callAction(
            module: "core",
            action: "enableModule",
            args: ["human-web-lite"])
    }

    static func disable() {
        self.browserCore.callAction(
           module: "core",
           action: "disableModule",
           args: ["human-web-lite"])
    }

    static func isEnabled(callback: @escaping (Bool) -> Void) {
        self.browserCore.callAction(
          module: "core",
          action: "status",
          args: []
        ) { (error, result) in
            if error != nil {
                callback(false)
                return
            }

            guard
                let status = result as? [String: [String: [String: Any]]],
                let modules = status["modules"],
                let humanWeb = modules["human-web-lite"],
                let isEnabled = humanWeb["isEnabled"] as? Bool
            else {
                callback(false)
                return
            }

            callback(isEnabled)
        }
    }
}
