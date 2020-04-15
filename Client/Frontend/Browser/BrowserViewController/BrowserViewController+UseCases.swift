//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Storage

extension BrowserViewController: UseCasesPresentationViewController {

    func switchOrOpenTabWithURL(_ url: URL) {
        self.switchToTabForURLOrOpen(url, isPrivileged: true)
    }

    func submitURL(_ url: URL, visitType: VisitType, forTab tab: Tab) {
        self.finishEditingAndSubmit(url, visitType: visitType, forTab: tab)
    }

    func openURLInNewTab(_ url: URL, isPrivate: Bool) {
        self.openURLInNewTab(url, isPrivate: isPrivate, isPrivileged: true)
    }

    func showWipeAllTracesContextualOnboarding() {
        self.presentWipeAllTracesContextualOnboarding()
    }

    func showAutomaticForgetModeContextualOnboarding() {
        self.presentAutomaticForgetModeContextualOnboarding()
    }

    func removeQueryFromQueryList(_ query: String) {
        self.queries.removeAll(where: { $0 == query })
    }

}
