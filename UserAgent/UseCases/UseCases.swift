//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Storage

protocol UseCasesPresentationViewController: class {
    func switchOrOpenTabWithURL(_ url: URL)
    func submitURL(_ url: URL, visitType: VisitType, forTab tab: Tab)
    func openURLInNewTab(_ url: URL, isPrivate: Bool)
    func showWipeAllTracesContextualOnboarding()
    func showAutomaticForgetModeContextualOnboarding()
    func removeQueryFromQueryList(_ query: String)
}

class UseCases {
    let contextMenu: ContextMenuUseCase
    let openLink: OpenLinkUseCases
    let history: HistoryUseCase

    weak var viewController: UseCasesPresentationViewController?

    init(tabManager: TabManager, profile: Profile, viewController: UseCasesPresentationViewController) {
        self.viewController = viewController
        self.history = HistoryUseCase(profile: profile, viewController: viewController)
        self.openLink = OpenLinkUseCases(
            profile: profile,
            tabManager: tabManager,
            viewController: viewController)
        self.contextMenu = ContextMenuUseCase(
            profile: profile,
            openLink: self.openLink,
            history: self.history,
            viewController: viewController)
    }
}
