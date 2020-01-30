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
import CoreSpotlight

enum ContextMenuActions {
    case unknwon
    case unpin
    case pin
    case newTab
    case removeTopSite
    case deleteFromHistory
}

public typealias ContextMenuActionCompletion = () -> Void

class ContextMenuUseCase {
    var profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    func present(for site: Site, with actions: [ContextMenuActions], on viewController: UIViewController, completion: @escaping ContextMenuActionCompletion) {
        var photonAction: [PhotonActionSheetItem] = []
        for action in actions {
            if let action = self.createActionItem(for: action, site: site, completion: completion) {
                photonAction.append(action)
            }
        }
        let contextMenu = self.createContextMenu(site: site, with: photonAction)

        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()

        viewController.present(contextMenu, animated: true, completion: nil)
    }

    private func createContextMenu(site: Site, with actions: [PhotonActionSheetItem]) -> PhotonActionSheet {
        let contextMenu = PhotonActionSheet(site: site, actions: actions)
        contextMenu.modalPresentationStyle = .overFullScreen
        contextMenu.modalTransitionStyle = .crossDissolve

        return contextMenu
    }

    private func createActionItem(for action: ContextMenuActions, site: Site, completion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem? {
        switch action {
        case .unpin:
            return self.createActionUnpin(site: site, actionCompletion: completion)
        case .pin:
            return self.createActionPin(site: site, actionCompletion: completion)
        case .removeTopSite:
            return self.createActionRemoveTopSite(site: site, actionCompletion: completion)
        case .deleteFromHistory:
            return self.createActionDeleteFromHistory(site: site, actionCompletion: completion)
        default:
            break
        }
        return nil
    }

    private func createActionUnpin(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let removeTopSitesPin = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.RemovePinTopsite, iconString: "action_unpin") { action in
            self.profile.history.removeFromPinnedTopSites(site).uponQueue(.main) { _ in
                actionCompletion()
            }
        }
        return removeTopSitesPin
    }

    private func createActionPin(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let addPinnedTopSite = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.PinTopsite, iconString: "action_pin") { action in
            self.profile.history.addPinnedTopSite(site).uponQueue(.main) { _ in
                actionCompletion()
            }
        }
        return addPinnedTopSite
    }

    private func createActionRemoveTopSite(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let removeFromTopSite = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.Remove, iconString: "action_remove") { action in
            if let host = site.tileURL.host {
                self.profile.history.removeHostFromTopSites(host).uponQueue(.main) { _ in
                    self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true) {
                        actionCompletion()
                    }
                }
            }
        }
        return removeFromTopSite
    }

    private func createActionDeleteFromHistory(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let removeFromTopSite = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.DeleteFromHistory, iconString: "action_delete") { action in
            self.profile.history.removeHistoryForURL(site.url).uponQueue(.main) { result in
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [site.url])
                actionCompletion()
            }
        }
        return removeFromTopSite
    }

}
