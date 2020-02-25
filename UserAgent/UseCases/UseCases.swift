//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class UseCases {

    var tabUseCases: TabUseCases
    var contextMenu: ContextMenuUseCase
    var openLink: OpenLinkUseCases

    init(tabManager: TabManager, profile: Profile, browserViewController: BrowserViewController) {
        self.tabUseCases = TabUseCases(tabManager: tabManager)
        self.openLink = OpenLinkUseCases(tabManager: tabManager, browserViewController: browserViewController)
        self.contextMenu = ContextMenuUseCase(profile: profile, browserViewController: browserViewController)
    }

}
