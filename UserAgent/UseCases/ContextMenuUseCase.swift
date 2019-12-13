//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Storage
import Shared

enum ContextMenuActions {
    case unknwon
    case unpin
    case pin
    case newTab
}

class ContextMenuUseCase {
    var profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    func present(for site: Site, with actions: [ContextMenuActions], on viewController: UIViewController) -> Success {
        for action in actions {
            switch action {
            case .unpin:
                let unpinAction = self.createActionUnpin(site: site)
                let contextMenu = self.createContextMenu(site: site, with: [unpinAction])
                viewController.present(contextMenu, animated: true, completion: nil)
            default:
                break
            }
        }
        return succeed()
    }

    private func createContextMenu(site: Site, with actions: [PhotonActionSheetItem]) -> PhotonActionSheet {
        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        return contextMenu
    }

    private func createActionUnpin(site: Site) -> PhotonActionSheetItem {
        let removeTopSitesPin = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.RemovePinTopsite, iconString: "action_unpin") { action in
            self.profile.history.removeFromPinnedTopSites(site)
        }
        return removeTopSitesPin
    }
}
