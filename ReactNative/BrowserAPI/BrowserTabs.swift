//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React
import WebKit

private class WeakRef<T> where T: AnyObject {
    private(set) weak var value: T?

    init(_ value: T?) {
        self.value = value
    }
}

private var weakTabSet: [WeakRef<Tab>] = []

private func serializeTab(_ tab: Tab, tabManager: TabManager) -> [String: Any] {
    var id = weakTabSet.firstIndex(where: { $0.value === tab }) as Int?
    if id == nil {
        weakTabSet.append(WeakRef(tab))
        // tab id counted from 1 not from 0
        id = weakTabSet.count
    } else {
        // start counting tab ids with 1
        id = id! + 1
    }

    let isInReaderMode = tab.actualURL?.isReaderModeURL ?? false
    let isActive = tabManager.selectedTab == tab
    let isPrivate = tab.isPrivate
    let tabs = isPrivate ? tabManager.privateTabs : tabManager.normalTabs
    return [
        "id": id ?? -1,
        "active": isActive,
        "hidden": false,
        "highlighted": false,
        "incognito": isPrivate,
        "index": tabs.firstIndex(where: { $0 === tab }) ?? -1,
        "isArticle": isInReaderMode,
        "isInReaderMode": isInReaderMode,
        "lastAccessed": tab.lastExecutedTime ?? 0,
        "pinned": false,
        "selected": isActive,
        "title": tab.displayTitle,
        "url": tab.actualURL?.absoluteString ?? "about:blank",
        "windowId": isPrivate ? -10000 : 10000,
    ]
}

@objc(BrowserTabs)
class BrowserTabs: NSObject, NativeModuleBase {
    @objc(query:reject:)
    public func query(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        withAppDelegate { appDel in
            let tabManager = appDel.tabManager!
            resolve(tabManager.tabs.map { serializeTab($0, tabManager: tabManager) })
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
