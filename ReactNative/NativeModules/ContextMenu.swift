//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Storage

@objc(ContextMenu)
class ContextMenuNativeModule: NSObject, NativeModuleBase {

    @objc(speedDial:)
    public func speedDial(url_str: NSString) {
        let rawUrl = url_str as String
        guard let url = URL(string: rawUrl) else { return }

        self.withAppDelegate { appDel in
            guard let sql = appDel.profile?.history as? SQLiteHistory else { return }

            sql.getSites(forURLs: [url.absoluteString]).uponQueue(.main) { result in
                let site = result.successValue?.asArray().first?.flatMap({ $0 })
                    ?? Site(url: url.absoluteString, title: url.normalizedHost ?? rawUrl)
                appDel.useCases.contextMenu.present(
                    for: site,
                    with: [.unpin],
                    on: appDel.browserViewController
                ) {
                    appDel.browserViewController?.homeViewController?.refresh()
                }
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
