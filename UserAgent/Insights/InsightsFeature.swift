//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class InsightsFeature: NSObject {

    struct TabStats: Codable {
        let loadTime: Int
        let timeSaved: Int
        let trackersDetected: Int
        let trackersBlocked: Int
        let trackerRequestsBlocked: Int
        let cookiesBlocked: Int
        let fingerprintsRemoved: Int
        let adsBlocked: Int
        let dataSaved: Int
        let trackers: [String]

        func asDictionary() -> [String: Any] {
            return [
                "loadTime": self.loadTime,
                "timeSaved": self.timeSaved,
                "trackersDetected": self.trackersDetected,
                "trackersBlocked": self.trackersBlocked,
                "trackerRequestsBlocked": self.trackerRequestsBlocked,
                "cookiesBlocked": self.cookiesBlocked,
                "fingerprintsRemoved": self.fingerprintsRemoved,
                "adsBlocked": self.adsBlocked,
                "dataSaved": self.dataSaved,
                "trackers": self.trackers,
            ]
        }
    }

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

    static func getTabState(_ tab: Tab) -> TabStats? {
        guard let stats = tab.contentBlocker?.stats else { return nil }

        let blockedTrackersCount = stats.total - stats.adCount
        let adTrackerCount = stats.trackers.filter { $0.category == WTMCategory.advertising }.count
        let otherTrackersCount = stats.trackers.count - adTrackerCount

        return TabStats(
            loadTime: 0,
            timeSaved: 0,
            trackersDetected: otherTrackersCount,
            trackersBlocked: otherTrackersCount,
            trackerRequestsBlocked: blockedTrackersCount,
            cookiesBlocked: 0,
            fingerprintsRemoved: 0,
            adsBlocked: adTrackerCount,
            dataSaved: 0,
            trackers: stats.trackers.map { $0.id }
        )
    }

    func reportStatsForTab(_ tab: Tab) {
        guard !tab.isPrivate else { return }

        guard let tabStats = InsightsFeature.getTabState(tab) else { return }

        self.reportStats(tabId: tab.id, tabStats: tabStats)
    }
}

extension InsightsFeature: TabManagerDelegate {
    func tabManagerDidClearContentBlocker(_ tabManager: TabManager, tab: Tab, isRestoring: Bool) {
        if isRestoring { return }

        self.reportStatsForTab(tab)
    }

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {
        if isRestoring { return }

        self.reportStatsForTab(tab)
    }
}

extension InsightsFeature: BrowserCoreClient {
    private func reportStats(tabId: Int, tabStats: TabStats) {
        browserCore.callAction(
            module: "insights",
            action: "reportStats",
            args: [
                tabId,
                tabStats.asDictionary(),
            ]
        )
    }
}
