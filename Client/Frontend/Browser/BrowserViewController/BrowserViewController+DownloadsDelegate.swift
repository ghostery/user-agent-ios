//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Storage

extension BrowserViewController: DownloadsDelegate {
    func downloads(didSelectURL url: URL, visitType: VisitType) {
        let selectedTab = self.tabManager.selectedTab
        if selectedTab?.isNewTabPage ?? false {
            self.openURL(url: url, visitType: visitType)
        } else {
            self.openAndShowURLInNewTab(url: url, isPrivate: selectedTab?.isPrivate ?? false)
        }
    }

    func downloadsDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        self.openURLInNewTab(url: url, isPrivate: isPrivate)
    }

    func downloadsDidClose() {
        self.setPhoneWindowBackground(color: Theme.browser.background, animationDuration: 1.0)
    }

}
