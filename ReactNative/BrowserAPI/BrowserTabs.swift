//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React
import WebKit
import Shared

@objc(BrowserTabs)
class BrowserTabs: RCTEventEmitter, NativeModuleBase {
    private var weakTabSet: [WeakRef<Tab>] = []
    private var isListeningForTabEvents = false

    @objc(startListeningForTabEvents)
    public func startListeningForTabEvents() {
        if self.isListeningForTabEvents { return }

        self.withTabManager { tabManager in
            // in case of race condition
            if self.isListeningForTabEvents { return }

            tabManager.addDelegate(self)
            self.isListeningForTabEvents = true
        }
    }

    @objc(query:reject:)
    public func query(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.withTabManager { tabManager in
            let tabs = tabManager.tabs.filter {
                guard let url = $0.actualURL else { return false }

                if InternalURL(url) == nil { return true }

                return false
            }.map { self.serializeTab($0, withTabManager: tabManager) }
            resolve(tabs)
        }
    }

    private func getTabId(_ tab: Tab?) -> Int? {
        guard let tab = tab else { return nil }
        var id = self.weakTabSet.firstIndex(where: { $0.value === tab }) as Int?
        if id == nil {
            weakTabSet.append(WeakRef(tab))
            // tab id counted from 1 not from 0
            id = weakTabSet.count
        } else {
            // start counting tab ids with 1
            id = id! + 1
        }
        return id
    }

    private func serializeTab(_ tab: Tab, withTabManager tabManager: TabManager) -> [String: Any] {
        let id = getTabId(tab)
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

    private class WeakRef<T> where T: AnyObject {
        private(set) weak var value: T?

        init(_ value: T?) {
            self.value = value
        }
    }

    func withTabManager(completion: @escaping (TabManager) -> Void) {
        withAppDelegate() { appDel in
            guard let tabManager = appDel.tabManager else { return }
            completion(tabManager)
        }
    }

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["BrowserTabsEvent"]
    }

    private func sendEvent(body: Any) {
        self.sendEvent(withName: "BrowserTabsEvent", body: body)
    }
}

extension BrowserTabs: TabManagerDelegate {
    func tabManager(_ tabManager: TabManager, didSelectedTabChange selected: Tab?, previous: Tab?, isRestoring: Bool) {
        guard let selectedTab = selected else { return }
        let serializedSelectedTab = self.serializeTab(selectedTab, withTabManager: tabManager)
        let previousTabId = self.getTabId(previous)

        sendEvent(body: [
            "eventName": "onActivated",
            "eventData": [
                [
                    "tabId": serializedSelectedTab["id"],
                    "previousTabId": previousTabId ?? nil,
                    "windowId": serializedSelectedTab["windowId"],
                ],
            ],
        ])
    }

    func tabManager(_ tabManager: TabManager, didAddTab tab: Tab, isRestoring: Bool) {
        sendEvent(body: [
            "eventName": "onCreated",
            "eventData": [
                self.serializeTab(tab, withTabManager: tabManager),
            ],
        ])
    }

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {
        let serializedTab = self.serializeTab(tab, withTabManager: tabManager)
        sendEvent(body: [
            "eventName": "onRemoved",
            "eventData": [
                serializedTab["id"],
                [
                    "windowId": serializedTab["windowId"],
                    "isWindowClosing": false,
                ],
            ],
        ])
    }

    func tabManagerDidRestoreTabs(_ tabManager: TabManager) {

    }

    func tabManagerDidAddTabs(_ tabManager: TabManager) {

    }

    func tabManagerDidRemoveAllTabs(_ tabManager: TabManager, toast: ButtonToast?) {

    }
}
