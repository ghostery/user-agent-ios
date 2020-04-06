//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class UseCases {
    let contextMenu: ContextMenuUseCase
    let openLink: OpenLinkUseCases
    let history: HistoryUseCase

    init(tabManager: TabManager, profile: Profile, browserViewController: BrowserViewController) {
        self.history = HistoryUseCase(profile: profile)
        self.openLink = OpenLinkUseCases(
            profile: profile,
            tabManager: tabManager,
            browserViewController: browserViewController)
        self.contextMenu = ContextMenuUseCase(
            profile: profile,
            openLink: self.openLink,
            history: self.history)
    }
}
