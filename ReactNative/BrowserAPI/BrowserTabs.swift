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

    private func serializeTab(_ tab: Tab, withTabManager tabManager: TabManager) -> [String: Any] {
        let isInReaderMode = tab.actualURL?.isReaderModeURL ?? false
        let isActive = tabManager.selectedTab == tab
        let isPrivate = tab.isPrivate
        let tabs = isPrivate ? tabManager.privateTabs : tabManager.normalTabs
        return [
            "id": tab.id,
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
        if isRestoring { return }

        guard let selectedTab = selected else { return }
        let serializedSelectedTab = self.serializeTab(selectedTab, withTabManager: tabManager)
        let previousTabId = previous?.id

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
        if isRestoring { return }

        sendEvent(body: [
            "eventName": "onCreated",
            "eventData": [
                self.serializeTab(tab, withTabManager: tabManager),
            ],
        ])
    }

    func tabManager(_ tabManager: TabManager, didRemoveTab tab: Tab, isRestoring: Bool) {
        if isRestoring { return }

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

    func tabManager(_ tabManager: TabManager, didUpdateTab tab: Tab, isRestoring: Bool) {
        if isRestoring { return }

        let serializedTab = self.serializeTab(tab, withTabManager: tabManager)
        sendEvent(body: [
            "eventName": "onUpdated",
            "eventData": [
                serializedTab["id"],
                // This should be a changeInfo object but Browser Core
                // incorectly expects a tab
                serializedTab,
                serializedTab,
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
