//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class InsightsFeature: NSObject {
    private weak var tabManager: TabManager!

    init(tabManager: TabManager) {
        super.init()
        self.tabManager = tabManager
        self.tabManager.addDelegate(self)
    }
}

extension InsightsFeature: TabManagerDelegate {
    func tabManagerDidClearContentBlocker(_ tabManager: TabManager, tab: Tab, isRestoring: Bool) {
        if isRestoring { return }
        self.reportStats(tabId: tab.id)
    }
}

extension InsightsFeature: BrowserCoreClient {
    private func reportStats(tabId: Int) {
        browserCore.callAction(
            module: "insights",
            action: "reportStats",
            args: [
                tabId,
                [
                    "loadTime": 0,
                    "timeSaved": 0,
                    "trackersDetected": 0,
                    "trackersBlocked": 0,
                    "trackerRequestsBlocked": 0,
                    "cookiesBlocked": 0,
                    "fingerprintsRemoved": 0,
                    "adsBlocked": 0,
                    "dataSaved": 0,
                    "trackers": [],
                ],
            ]
        )
    }
}
