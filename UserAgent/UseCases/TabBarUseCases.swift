//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class TabUseCases {

    private let tabManager: TabManager

    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    // MARK: - New Tab Methods

    func openNewTab(url: URL? = nil) {
        var tab: Tab!
        if let url = url {
            tab = self.tabManager.addTab(URLRequest(url: url), afterTab: self.tabManager.normalTabs.last, isPrivate: false)
        } else {
            tab = self.tabManager.addTab(afterTab: self.tabManager.normalTabs.last, isPrivate: false)
        }
        self.tabManager.selectTab(tab)
    }

    // MARK: - New Private Tab Methods

    func openNewPrivateTab(url: URL? = nil) {
        var tab: Tab!
        if let url = url {
            tab = self.tabManager.addTab(URLRequest(url: url), afterTab: self.tabManager.privateTabs.last, isPrivate: true)
        } else {
            tab = self.tabManager.addTab(afterTab: self.tabManager.privateTabs.last, isPrivate: true)
        }
        self.tabManager.selectTab(tab)
    }

}
