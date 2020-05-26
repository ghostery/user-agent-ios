//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Storage
import Shared

protocol LibraryContextMenu {
    func getSiteDetails(for indexPath: IndexPath) -> Site?
    func getContextMenuActions(for site: Site, with indexPath: IndexPath) -> [PhotonActionSheetItem]?
    func presentContextMenu(for indexPath: IndexPath)
    func presentContextMenu(for site: Site, with indexPath: IndexPath, completionHandler: @escaping () -> PhotonActionSheet?)
}

extension LibraryContextMenu {
    func presentContextMenu(for indexPath: IndexPath) {
        guard let site = getSiteDetails(for: indexPath) else { return }

        self.presentContextMenu(for: site, with: indexPath, completionHandler: {
            return self.contextMenu(for: site, with: indexPath)
        })
    }

    func contextMenu(for site: Site, with indexPath: IndexPath) -> PhotonActionSheet? {
        guard let actions = self.getContextMenuActions(for: site, with: indexPath) else { return nil }

        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        HapticFeedback.vibrate()

        return contextMenu
    }

    func getDefaultContextMenuActions(for site: Site, libraryViewDelegate: LibraryViewDelegate?) -> [PhotonActionSheetItem]? {
        guard let siteURL = URL(string: site.url) else { return nil }
        let openInNewTabAction = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.OpenInNewTab, iconString: "quick_action_new_tab") { action in
            libraryViewDelegate?.libraryDidRequestToOpenInNewTab(siteURL, isPrivate: false)
        }
        let openInNewPrivateTabAction = PhotonActionSheetItem(title: Strings.ForgetMode.ContextMenu.OpenInNewPrivateTab, iconString: "forgetMode") { action in
            libraryViewDelegate?.libraryDidRequestToOpenInNewTab(siteURL, isPrivate: true)
        }
        return [openInNewTabAction, openInNewPrivateTabAction]
    }
}
