//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Storage
import React

@objc(ContextMenu)
class ContextMenuNativeModule: NSObject, NativeModuleBase {

    @objc(result:title:isHistory:query:)
    public func result(url_str: NSString, title: NSString, isHistory: Bool, query: NSString) {
        let rawUrl = url_str as String
        guard let url = URL(string: rawUrl) else { return }

        var actions: [ContextMenuActions] = [.openInNewTab, .openInNewPrivateTab]

        if isHistory {
            actions += [.deleteFromHistory, .deleteAllTracesForDomain]
        }

        self.withAppDelegate { appDel in
            let site = Site(url: url.absoluteString, title: title as String)

            appDel.useCases.contextMenu.present(
                for: site,
                withQuery: query as String,
                withActions: actions,
                on: appDel.browserViewController
            ) { _ in
                guard let searchContorller = appDel.browserViewController?.searchController else { return }
                // redo query
                let query = searchContorller.searchQuery
                searchContorller.searchQuery = query
                appDel.browserViewController?.homeViewController?.refreshHistory()
            }
        }
    }

    @objc(visit:title:isHistory:resolve:reject:)
    public func visit(
        url_str: NSString,
        title: NSString,
        isHistory: Bool,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        let rawUrl = url_str as String
        guard let url = URL(string: rawUrl) else { return }

        var actions: [ContextMenuActions] = [.openInNewTab, .openInNewPrivateTab]

        if isHistory {
            actions += [.deleteFromHistory]
        }

        self.withAppDelegate { appDel in
            let site = Site(url: url.absoluteString, title: title as String)

            appDel.useCases.contextMenu.present(
                for: site,
                withActions: actions,
                on: appDel.browserViewController
            ) { action in
                resolve([
                    "action": action?.rawValue ?? "",
                ])
            }
        }
    }

    @objc(speedDial:isPinned:)
    public func speedDial(url_str: NSString, isPinned: Bool) {
        let rawUrl = url_str as String
        guard let url = URL(string: rawUrl) else { return }

        var actions: [ContextMenuActions] = []

        if isPinned {
            actions += [.unpin]
        } else {
            actions += [.removeTopSite]
        }

        self.withAppDelegate { appDel in
            guard let sql = appDel.profile?.history as? SQLiteHistory else { return }

            sql.getSites(forURLs: [url.absoluteString]).uponQueue(.main) { result in
                var site: Site
                if let historySite = result.successValue?.asArray().first?.flatMap({ $0 }) {
                    site = historySite
                    if !isPinned {
                        actions += [.pin]
                    }
                } else {
                    site = Site(url: url.absoluteString, title: url.normalizedHost ?? rawUrl)
                }

                appDel.useCases.contextMenu.present(
                    for: site,
                    withActions: actions,
                    on: appDel.browserViewController
                ) { _ in
                    appDel.browserViewController?.homeViewController?.refreshTopSites()
                }
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
