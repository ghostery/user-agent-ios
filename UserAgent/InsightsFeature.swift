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

    func clearStats() {
        self.browserCore.callAction(
            module: "insights",
            action: "clearData",
            args: [])
    }
}

extension InsightsFeature: TabManagerDelegate {
    func tabManagerDidClearContentBlocker(_ tabManager: TabManager, tab: Tab, isRestoring: Bool) {
        if isRestoring { return }
        guard let stats = tab.contentBlocker?.stats else { return }

        self.reportStats(
            tabId: tab.id,
            trackers: stats.trackers,
            blockedTrackersCount: stats.total - stats.adCount)
    }
}

extension InsightsFeature: BrowserCoreClient {
    private func reportStats(tabId: Int, trackers: Set<Tracker>, blockedTrackersCount: Int) {
        let adTrackerCount = trackers.filter { $0.category == WTMCategory.advertising }.count
        let otherTrackersCount = trackers.count - adTrackerCount

        browserCore.callAction(
            module: "insights",
            action: "reportStats",
            args: [
                tabId,
                [
                    "loadTime": 0,
                    "timeSaved": 0,
                    "trackersDetected": otherTrackersCount,
                    "trackersBlocked": otherTrackersCount,
                    "trackerRequestsBlocked": blockedTrackersCount,
                    "cookiesBlocked": 0,
                    "fingerprintsRemoved": 0,
                    "adsBlocked": adTrackerCount,
                    "dataSaved": 0,
                    "trackers": trackers.map { $0.id },
                ],
            ]
        )
    }
}
