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
import WebKit

public enum ContextMenuActions: String {
    case unpin
    case pin
    case removeTopSite
    case deleteFromHistory
    case deleteAllTracesForDomain
    case openInNewTab
    case openInNewPrivateTab
}

public typealias ContextMenuActionCompletion = (ContextMenuActions?) -> Void

class ContextMenuUseCase {
    private let profile: Profile
    private let openLink: OpenLinkUseCases
    private let history: HistoryUseCase
    private weak var viewController: UseCasesPresentationViewController?

    init(profile: Profile, openLink: OpenLinkUseCases, history: HistoryUseCase, viewController: UseCasesPresentationViewController?) {
        self.profile = profile
        self.openLink = openLink
        self.history = history
        self.viewController = viewController
    }

    func present(for site: Site, withQuery query: String? = nil, withActions actions: [ContextMenuActions], on viewController: UIViewController, completion: @escaping ContextMenuActionCompletion) {
        var photonAction: [PhotonActionSheetItem] = []
        for action in actions {
            if let action = self.createActionItem(for: action, site: site, query: query, completion: completion) {
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

    private func createActionItem(
        for action: ContextMenuActions,
        site: Site,
        query: String?,
        completion: @escaping ContextMenuActionCompletion
    ) -> PhotonActionSheetItem? {
        switch action {
        case .unpin:
            return self.createActionUnpin(site: site, actionCompletion: completion)
        case .pin:
            return self.createActionPin(site: site, actionCompletion: completion)
        case .removeTopSite:
            return self.createActionRemoveTopSite(site: site, actionCompletion: completion)
        case .deleteFromHistory:
            return self.createActionDeleteFromHistory(site: site, actionCompletion: completion)
        case .deleteAllTracesForDomain:
            return self.createActionDeleteAllTraces(site: site, actionCompletion: completion)
        case .openInNewTab:
            return self.createActionOpenInNewTab(site: site, actionCompletion: completion)
        case .openInNewPrivateTab:
            return self.createActionOpenInNewPrivateTab(site: site, actionCompletion: completion)
        }
    }

    private func createActionUnpin(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let removeTopSitesPin = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.RemovePinTopsite, iconString: "action_unpin") { action in
            self.profile.history.removeFromPinnedTopSites(site).uponQueue(.main) { _ in
                actionCompletion(.unpin)
            }
        }
        return removeTopSitesPin
    }

    private func createActionPin(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let addPinnedTopSite = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.PinTopsite, iconString: "action_pin") { action in
            self.profile.history.addPinnedTopSite(site).uponQueue(.main) { _ in
                actionCompletion(.pin)
            }
        }
        return addPinnedTopSite
    }

    private func createActionRemoveTopSite(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let removeFromTopSite = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.Remove, iconString: "action_remove") { action in
            if let host = site.tileURL.host {
                self.profile.history.removeHostFromTopSites(host).uponQueue(.main) { _ in
                    self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true) {
                        actionCompletion(.removeTopSite)
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
                actionCompletion(.deleteFromHistory)
            }
        }
        return removeFromTopSite
    }

    private func createActionDeleteAllTraces(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let host = site.url.asURL?.normalizedHost ?? site.url
        let title = String(format: Strings.HomePanel.ContextMenu.DeleteAllTraces, host)
        let removeFromTopSite = PhotonActionSheetItem(title: title, iconString: "wipe") { action in
            self.history.deleteAllTracesOfDomain(host) {
                actionCompletion(.deleteAllTracesForDomain)
                self.viewController?.showWipeAllTracesContextualOnboarding()
            }
        }
        return removeFromTopSite
    }

    private func createActionOpenInNewTab(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let actionSheetItem = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.OpenInNewTab, iconString: "quick_action_new_tab") { action in
            self.openLink.openNewTab(url: site.tileURL)
            actionCompletion(.openInNewTab)
        }
        return actionSheetItem
    }

    private func createActionOpenInNewPrivateTab(site: Site, actionCompletion: @escaping ContextMenuActionCompletion) -> PhotonActionSheetItem {
        let actionSheetItem = PhotonActionSheetItem(title: Strings.HomePanel.ContextMenu.OpenInNewPrivateTab, iconString: "forgetMode") { action in
            self.openLink.openNewForgetModeTab(url: site.tileURL)
            actionCompletion(.openInNewPrivateTab)
        }
        return actionSheetItem
    }

}
