/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage

protocol PhotonActionSheetProtocol {
    var tabManager: TabManager { get }
    var profile: Profile { get }
}

private let log = Logger.browserLogger

extension PhotonActionSheetProtocol {
    typealias PresentableVC = UIViewController & UIPopoverPresentationControllerDelegate
    typealias MenuAction = () -> Void
    typealias IsPrivateTab = Bool
    typealias URLOpenAction = (URL?, IsPrivateTab) -> Void

    func presentSheetWith(title: String? = nil, actions: [[PhotonActionSheetItem]], on viewController: PresentableVC, from view: UIView, closeButtonTitle: String = Strings.PhotonMenu.Close, suppressPopover: Bool = false) {
        let style: UIModalPresentationStyle = (UIDevice.current.isPad && !suppressPopover) ? .popover : .overCurrentContext
        let sheet = PhotonActionSheet(title: title, actions: actions, closeButtonTitle: closeButtonTitle, style: style)
        sheet.modalPresentationStyle = style
        sheet.photonTransitionDelegate = PhotonActionSheetAnimator()

        if let popoverVC = sheet.popoverPresentationController, sheet.modalPresentationStyle == .popover {
            popoverVC.delegate = viewController
            popoverVC.sourceView = view
            popoverVC.sourceRect = CGRect(x: view.frame.width/2, y: view.frame.size.height * 0.75, width: 1, height: 1)
            popoverVC.permittedArrowDirections = .up
        }
        viewController.present(sheet, animated: true, completion: nil)
    }

    //Returns a list of actions which is used to build a menu
    //OpenURL is a closure that can open a given URL in some view controller. It is up to the class using the menu to know how to open it
    func getControlCenterActions(vcDelegate: PageOptionsVC) -> [[PhotonActionSheetItem]] {
        guard let tab = self.tabManager.selectedTab else { return [] }

        let privacyStatsView = PrivacyStatsView()
        let privacyStats = PhotonActionSheetItem(title: "", customView: privacyStatsView)

        let openHomePage = PhotonActionSheetItem(title: Strings.Menu.OpenHomePageTitleString, iconString: "menu-Home") { _ in
            if let homePanelURL = NewTabPage.topSites.url {
                tab.loadRequest(PrivilegedRequest(url: homePanelURL) as URLRequest)
            }
        }

        return [
            [
                privacyStats,
            ], [
                self.openWhatsNewItem(vcDelegate: vcDelegate),
                self.openPrivacyStatementItem(vcDelegate: vcDelegate),
            ], [
                self.burnItem(vcDelegate: vcDelegate),
            ], [
                PhotonActionSheetItem(title: "", collectionItems: [
                    openHomePage,
                    self.openSettingsItem(vcDelegate: vcDelegate),
                    self.openDownloadsItem(vcDelegate: vcDelegate),
                ]),
            ],
        ]
    }

    /*
     Returns a list of actions which is used to build the general browser menu
     These items repersent global options that are presented in the menu
     TO DO: These icons should all have the icons and use Strings.swift
     */

    typealias PageOptionsVC = SettingsDelegate & PresentingModalViewControllerDelegate & UIViewController

    func getQueriesActions(queries: [String], didSelectQuery: @escaping (String) -> Void, didRemoveQuery: @escaping (String) -> Void) -> [PhotonActionSheetItem] {
        var queryItems = [PhotonActionSheetItem]()
        for query in queries {
            var queryItem = PhotonActionSheetItem(title: query, accessory: .Remove) { item in
                didSelectQuery(item.title)
            }
            queryItem.didRemoveHandler = { item in
                didRemoveQuery(item.title)
            }
            queryItems.append(queryItem)
        }
        return queryItems
    }

    func getBurnActions(presentableVC: PresentableVC) -> [[PhotonActionSheetItem]] {
        var userData: [String: (Clearable, Bool)] = [
            "CacheClearable": (CacheClearable(tabManager: self.tabManager), true),
            "CookiesClearable": (CookiesClearable(tabManager: self.tabManager), true),
            "SiteDataClearable": (SiteDataClearable(tabManager: self.tabManager), true),
            "HistoryClearable": (HistoryClearable(profile: self.profile), false),
            "SearchHistoryClearable": (SearchHistoryClearable(profile: self.profile), false),
            "DownloadedFilesClearable": (DownloadedFilesClearable(), false),
            "TrackingProtectionClearable": (TrackingProtectionClearable(), false),
            "PrivacyStatsClearable": (PrivacyStatsClearable(), false),
        ]
        func switchSetting(key: String, value: Bool) {
            userData[key]?.1 = value
        }
        let text = "\(Strings.Settings.DataManagement.PrivateData.Cache), \(Strings.Settings.DataManagement.PrivateData.Cookies), \(Strings.Settings.DataManagement.PrivateData.OfflineWebsiteData)"
        let clearBrowserStorage = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.BrowsingStorage, text: text, isEnabled: true, accessory: .Switch) { item in
            switchSetting(key: "CacheClearable", value: item.isEnabled)
            switchSetting(key: "CookiesClearable", value: item.isEnabled)
            switchSetting(key: "SiteDataClearable", value: item.isEnabled)
        }
        var closeAllTabsSetting = true
        let closeAllTabs = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.AllTabs, isEnabled: closeAllTabsSetting, accessory: .Switch) { item in
            closeAllTabsSetting = item.isEnabled
        }
        let clearBrowserHistory = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.BrowsingHistory, isEnabled: false, accessory: .Switch) { item in
            switchSetting(key: "HistoryClearable", value: item.isEnabled)
        }
        let clearSearchHistory = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.SearchHistory, isEnabled: false, accessory: .Switch) { item in
            switchSetting(key: "SearchHistoryClearable", value: item.isEnabled)
        }
        var clearTopSitesSetting = false
        let clearTopSites = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.TopAndPinnedSites, isEnabled: clearTopSitesSetting, accessory: .Switch) { item in
            clearTopSitesSetting = item.isEnabled
        }
        let clearDownloadFiles = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.DownloadedFiles, isEnabled: false, accessory: .Switch) { item in
            switchSetting(key: "DownloadedFilesClearable", value: item.isEnabled)
        }
        let clearAllowList = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.TrackingProtection, isEnabled: false, accessory: .Switch) { item in
            switchSetting(key: "TrackingProtectionClearable", value: item.isEnabled)
        }
        let clearPrivacyStats = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.PrivacyStats, isEnabled: false, accessory: .Switch) { item in
            switchSetting(key: "PrivacyStatsClearable", value: item.isEnabled)
        }
        var clearBookmarksSetting = false
        let clearBookmarks = PhotonActionSheetItem(title: Strings.Settings.DataManagement.PrivateData.Bookmarks, isEnabled: clearBookmarksSetting, accessory: .Switch) { item in
            clearBookmarksSetting = item.isEnabled
        }
        let closeAllTabsAndClearData = PhotonActionSheetItem(title: Strings.Menu.CloseAllTabsAndClearDataTitleString, iconString: "menu-burn") { _ in
            if closeAllTabsSetting {
                self.tabManager.removeAllTabs()
            }
            if clearBookmarksSetting {
                self.profile.bookmarks.modelFactory >>== { $0.clearBookmarks() }
                (presentableVC as? BrowserViewController)?.homeViewController?.refreshBookmarks()
            }
            if clearTopSitesSetting {
                _ = self.profile.history.clearTopSitesCache()
                _ = self.profile.history.clearPinnedSitesCache()
                (presentableVC as? BrowserViewController)?.homeViewController?.refreshTopSites()
            }
            userData.forEach { (_, value) in
                if value.1 {
                    _ = value.0.clear()
                }
            }
            (presentableVC as? BrowserViewController)?.homeViewController?.refreshHistory()
        }
        return [[clearBrowserStorage, closeAllTabs, clearBrowserHistory, clearSearchHistory, clearTopSites, clearDownloadFiles, clearAllowList, clearPrivacyStats, clearBookmarks], [closeAllTabsAndClearData]]
    }

    fileprivate func saveFileToDownloads(fileURL: URL, presentableVC: PresentableVC) {
        let fileName = fileURL.lastPathComponent
        do {
            let downloadsURL = try DownloadFolder.downloadsURL()
            var toURL = downloadsURL.appendingPathComponent(fileName)
            let files = try FileManager.default.contentsOfDirectory(at: downloadsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants])
            if files.contains(toURL) {
                var index = 1
                let fileExtension = fileURL.pathExtension
                let fileNameWithoutExtension = fileURL.deletingPathExtension().lastPathComponent
                files.forEach { (fileUrl) in
                    let nameWithoutExtension = fileUrl.deletingPathExtension().lastPathComponent
                    if nameWithoutExtension.contains(fileNameWithoutExtension + "_") {
                        if let number = Int(nameWithoutExtension.replaceFirstOccurrence(of: fileNameWithoutExtension + "_", with: "")) {
                            index = max(index, number + 1)
                        }
                    }
                }
                toURL = downloadsURL.appendingPathComponent("\(fileNameWithoutExtension)_\(index).\(fileExtension)")
            }
            try FileManager.default.copyItem(at: fileURL, to: toURL)
            (presentableVC as? BrowserViewController)?.showDownloadsToast(filename: toURL.lastPathComponent)
        } catch {
            print(error.localizedDescription)
        }
    }

    fileprivate func share(fileURL: URL, buttonView: UIView, presentableVC: PresentableVC) {
        let helper = ShareExtensionHelper(url: fileURL, tab: tabManager.selectedTab)
        let controller = helper.createActivityViewController(withDownloadActivity: true) { completed, activityType in
            print("Shared downloaded file: \(completed)")
            if activityType == FileDownloadActivity.activityType {
                if completed {
                    self.saveFileToDownloads(fileURL: fileURL, presentableVC: presentableVC)
                }
            }
        }

        if let popoverPresentationController = controller.popoverPresentationController {
            popoverPresentationController.sourceView = buttonView
            popoverPresentationController.sourceRect = buttonView.bounds
            popoverPresentationController.permittedArrowDirections = .up
        }

        presentableVC.present(controller, animated: true, completion: nil)
    }

    func getTabActions(tab: Tab, buttonView: UIView,
                       presentShareMenu: @escaping (URL, Tab, UIView, UIPopoverArrowDirection) -> Void,
                       findInPage:  @escaping () -> Void,
                       presentableVC: PresentableVC,
                       isBookmarked: Bool,
                       isPinned: Bool,
                       isReaderModeEnabled: Bool?,
                       readerModeChanged: ((Bool) -> Void)?,
                       success: @escaping (String) -> Void) -> [[PhotonActionSheetItem]] {
        if tab.url?.isFileURL ?? false {
            let shareFile = PhotonActionSheetItem(title: Strings.Menu.SharePageTitleString, iconString: "action_share") { action in
                guard let url = tab.url else { return }

                self.share(fileURL: url, buttonView: buttonView, presentableVC: presentableVC)
            }

            return [[shareFile]]
        }

        let defaultUAisDesktop = UserAgent.isDesktop(ua: UserAgent.getUserAgent())
        let toggleActionTitle: String
        if defaultUAisDesktop {
            toggleActionTitle = tab.changedUserAgent ? Strings.Menu.ViewDesktopSiteTitleString : Strings.Menu.ViewMobileSiteTitleString
        } else {
            toggleActionTitle = tab.changedUserAgent ? Strings.Menu.ViewMobileSiteTitleString : Strings.Menu.ViewDesktopSiteTitleString
        }

        let toggleDesktopSite = PhotonActionSheetItem(title: toggleActionTitle, iconString: "menu-RequestDesktopSite", isEnabled: tab.changedUserAgent, accessory: .Switch, badgeIconNamed: "menuBadge") { action in
            if let url = tab.url {
                tab.toggleChangeUserAgent()
                Tab.ChangeUserAgent.updateDomainList(forUrl: url, isChangedUA: tab.changedUserAgent, isPrivate: tab.isPrivate)
            }
        }
        var domainActions = [toggleDesktopSite]

        let bookmarkPage = PhotonActionSheetItem(title: Strings.Menu.AddBookmarkTitleString, iconString: "menu-Bookmark") { action in
            guard let url = tab.canonicalURL?.displayURL,
                let bvc = presentableVC as? BrowserViewController else {
                return
            }
            bvc.addBookmark(url: url.absoluteString, title: tab.title, favicon: tab.displayFavicon)
            success(Strings.Menu.AddBookmarkConfirmMessage)
        }

        let removeBookmark = PhotonActionSheetItem(title: Strings.Menu.RemoveBookmarkTitleString, iconString: "menu-Bookmark-Remove") { action in
            guard let url = tab.url?.displayURL else { return }

            let absoluteString = url.absoluteString
            self.profile.bookmarks.modelFactory >>== {
                $0.removeByURL(absoluteString).uponQueue(.main) { res in
                    if res.isSuccess {
                        success(Strings.Menu.RemoveBookmarkConfirmMessage)
                    }
                }
            }
        }

        let pinToTopSites = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.PinTopsite, iconString: "action_pin") { action in
            guard let url = tab.url?.displayURL, let sql = self.profile.history as? SQLiteHistory else { return }

            if tab.isPrivate {
                let site = Site(url: url.absoluteString, title: tab.displayTitle, bookmarked: nil, guid: Bytes.generateGUID())
                _ = self.profile.history.addPinnedTopSite(site)
            } else {
                sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                    guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                        return succeed()
                    }

                    return self.profile.history.addPinnedTopSite(site)
                }.uponQueue(.main) { _ in }
            }
        }

        let removeTopSitesPin = PhotonActionSheetItem(title: Strings.ActivityStream.ContextMenu.RemovePinTopsite, iconString: "action_unpin") { action in
            guard let url = tab.url?.displayURL, let sql = self.profile.history as? SQLiteHistory else { return }

            sql.getSites(forURLs: [url.absoluteString]).bind { val -> Success in
                guard let site = val.successValue?.asArray().first?.flatMap({ $0 }) else {
                    return succeed()
                }

                return self.profile.history.removeFromPinnedTopSites(site)
            }.uponQueue(.main) { _ in }
        }

        var mainActions = [PhotonActionSheetItem]()

        // Disable bookmarking if the URL is too long.
        if !tab.urlIsTooLong {
            mainActions.append(isBookmarked ? removeBookmark : bookmarkPage)
        }

        let pinAction = (isPinned ? removeTopSitesPin : pinToTopSites)
        mainActions.append(pinAction)

        let refreshPage = self.refreshPageItem()

        if let isReaderModeEnabled = isReaderModeEnabled {
            let readerModeAction = PhotonActionSheetItem(title: Strings.Menu.ReaderModeTitleString, iconString: "reader", isEnabled: isReaderModeEnabled, accessory: .Switch, badgeIconNamed: "menuBadge") { (item) in
                tab.toggleChangeReaderMode()
                readerModeChanged?(item.isEnabled)
            }
            domainActions.append(readerModeAction)
        }

        var commonActions = [refreshPage]

        // Disable find in page if document is pdf.
        if tab.mimeType != MIMEType.PDF {
            let findInPageAction = PhotonActionSheetItem(title: Strings.Menu.FindInPageTitleString, iconString: "menu-FindInPage") { action in
                findInPage()
            }
            commonActions.insert(findInPageAction, at: 0)
        }

        let sharePage = PhotonActionSheetItem(title: Strings.Menu.SharePageTitleString, iconString: "action_share") { action in
            guard let url = tab.canonicalURL?.displayURL else { return }

            if let temporaryDocument = tab.temporaryDocument {
                temporaryDocument.getURL().uponQueue(.main, block: { tempDocURL in
                    // If we successfully got a temp file URL, share it like a downloaded file,
                    // otherwise present the ordinary share menu for the web URL.
                    if tempDocURL.isFileURL {
                        self.share(fileURL: tempDocURL, buttonView: buttonView, presentableVC: presentableVC)
                    } else {
                        presentShareMenu(url, tab, buttonView, .up)
                    }
                })
            } else {
                presentShareMenu(url, tab, buttonView, .up)
            }
        }

        commonActions.append(sharePage)
        return [mainActions, domainActions, [PhotonActionSheetItem(title: "", collectionItems: commonActions)]]
    }

    func fetchBookmarkStatus(for url: String) -> Deferred<Maybe<Bool>> {
        return self.profile.bookmarks.modelFactory.bind {
            guard let factory = $0.successValue else {
                return deferMaybe(false)
            }
            return factory.isBookmarked(url)
        }
    }

    func fetchPinnedTopSiteStatus(for url: String) -> Deferred<Maybe<Bool>> {
        return self.profile.history.isPinnedTopSite(url)
    }

    func getLongPressLocationBarActions(with urlBar: URLBarView) -> [PhotonActionSheetItem] {
        let copyAddressAction = PhotonActionSheetItem(title: Strings.Menu.CopyAddressTitle, iconString: "menu-Copy-Link") { action in
            if let url = self.tabManager.selectedTab?.canonicalURL?.displayURL ?? urlBar.currentURL {
                UIPasteboard.general.url = url
            }
        }
        guard let string = UIPasteboard.general.string else {
            return [copyAddressAction]
        }
        var actions = [PhotonActionSheetItem]()
        if UIPasteboard.general.isCopiedStringValidURL {
            let pasteGoAction = PhotonActionSheetItem(title: Strings.Menu.PasteAndGoTitle, iconString: "menu-PasteAndGo") { action in
                urlBar.delegate?.urlBar(urlBar, didSubmitText: string, completion: nil)
            }
            actions.append(pasteGoAction)
        }
        let pasteAction = PhotonActionSheetItem(title: Strings.Menu.PasteTitle, iconString: "menu-Paste") { action in
            if let pasteboardContents = UIPasteboard.general.string {
                urlBar.enterOverlayMode(pasteboardContents, pasted: true, search: true)
            }
        }
        actions.append(contentsOf: [pasteAction, copyAddressAction])
        return actions
    }

    @available(iOS 11.0, *)
    private func menuActionsForNotBlocking() -> [PhotonActionSheetItem] {
        return [PhotonActionSheetItem(title: Strings.Settings.TrackingProtection.SectionName, text: Strings.Menu.TPNoBlockingDescription, iconString: "menu-TrackingProtection")]
    }

    @available(iOS 11.0, *)
    private func menuActionsForTrackingProtectionDisabled(for tab: Tab, vcDelegate: PageOptionsVC) -> [[PhotonActionSheetItem]] {
        let moreInfo = PhotonActionSheetItem(title: Strings.Menu.TPBlockingMoreInfo)
        return [[moreInfo], [openSettingsItem(vcDelegate: vcDelegate)]]
    }

    @available(iOS 11.0, *)
    private func menuActionsForTrackingProtectionEnabled(for tab: Tab) -> [[PhotonActionSheetItem]] {
        guard let blocker = tab.contentBlocker else {
            return []
        }

        // Menu Actions
        let menuActions = self.menuActions(for: tab)

        // Tracker Info
        let trackerInfoView = PrivacyDashboardView()
        trackerInfoView.blocker = blocker
        let trackerInfo = PhotonActionSheetItem(title: "", customView: trackerInfoView)

        // Whotracks.me link
        guard let url = blocker.tab?.currentURL(), let baseDomain = url.baseDomain, let appDel = UIApplication.shared.delegate as? AppDelegate else {
            return [menuActions, [trackerInfo]]
        }

        let whoTracksMeLink = PhotonActionSheetItem(title: Strings.PrivacyDashboard.ViewFullReport) { action in
            let url = URL(string: "https://whotracks.me/websites/\(baseDomain).html")!
            appDel.browserViewController.homePanel(didSelectURL: url, visitType: VisitType.link)
        }

        let reportPage = PhotonActionSheetItem(title: Strings.PrivacyDashboard.ReportPage.SectionTitle) { action in
            appDel.browserViewController.presentReportPageScreenFor(url: url)
        }

        let statisticAndReportPage = PhotonActionSheetItem(title: "", collectionItems: [whoTracksMeLink, reportPage])

        if blocker.status == .Disabled {
            return [[statisticAndReportPage]]
        }
        if blocker.stats.total > 0 {
            return [menuActions, [trackerInfo], [statisticAndReportPage]]
        } else {
            return [menuActions, [trackerInfo], [reportPage]]
        }
    }

    @available(iOS 11.0, *)
    private func menuActionsForAllowListedSite(for tab: Tab) -> [[PhotonActionSheetItem]] {
        return [self.menuActions(for: tab)]
    }

    private func menuActions(for tab: Tab) -> [PhotonActionSheetItem] {
        guard let currentURL = tab.url else {
            return []
        }

        let trackingProtection = PhotonActionSheetItem(
            title: Strings.PrivacyDashboard.Switch.AntiTracking,
            iconString: "menu-TrackingProtection",
            isEnabled: !ContentBlocker.shared.isTrackingAllowListed(url: currentURL),
            accessory: .Switch
        ) { action in
            ContentBlocker.shared.trackingAllowList(
                enable: !ContentBlocker.shared.isTrackingAllowListed(url: currentURL),
                url: currentURL
            ) {
                tab.reload()
            }
        }

        let adBlocking = PhotonActionSheetItem(
            title: Strings.PrivacyDashboard.Switch.AdBlock,
            iconString: "menu-AdBlocking",
            isEnabled: !ContentBlocker.shared.isAdsAllowListed(url: currentURL),
            accessory: .Switch
        ) { action in
            ContentBlocker.shared.adsAllowList(
                enable: !ContentBlocker.shared.isAdsAllowListed(url: currentURL),
                url: currentURL
            ) {
                tab.reload()
            }
        }

        let popupsBlocking = PhotonActionSheetItem(
            title: Strings.PrivacyDashboard.Switch.PopupsBlocking,
            iconString: "menu-PopupBlocking",
            isEnabled: !ContentBlocker.shared.isPopupsAllowListed(url: currentURL),
            accessory: .Switch
        ) { action in
            ContentBlocker.shared.popupsAllowList(
                enable: !ContentBlocker.shared.isPopupsAllowListed(url: currentURL),
                url: currentURL
            ) {
                tab.reload()
            }
        }

        return [trackingProtection, adBlocking, popupsBlocking]
    }

    @available(iOS 11.0, *)
    func getTrackingSubMenu(for tab: Tab, vcDelegate: PageOptionsVC) -> [[PhotonActionSheetItem]] {
        guard let blocker = tab.contentBlocker else {
            return []
        }

        switch blocker.status {
        case .Disabled:
            return menuActionsForTrackingProtectionDisabled(for: tab, vcDelegate: vcDelegate)
        default:
            return menuActionsForTrackingProtectionEnabled(for: tab)
        }
    }

    private func openWhatsNewItem(vcDelegate: PageOptionsVC) -> PhotonActionSheetItem {
        let badgeIconName: String? = (self.profile.prefs.boolForKey(PrefsKeys.WhatsNewBubble) == nil) ? "menuBadge" : nil
        let openSettings = PhotonActionSheetItem(title: Strings.Menu.WhatsNewTitleString, iconString: "menu-whatsNew", isEnabled: badgeIconName != nil, badgeIconNamed: badgeIconName) { action in
            self.profile.prefs.setBool(true, forKey: PrefsKeys.WhatsNewBubble)
            (vcDelegate as? BrowserViewController)?.presentWhatsNewViewController()
        }
        return openSettings
    }

    private func openPrivacyStatementItem(vcDelegate: PageOptionsVC) -> PhotonActionSheetItem {
        let openSettings = PhotonActionSheetItem(title: Strings.Menu.PrivacyStatementTitleString, iconString: "menu-privacy") { action in
            (vcDelegate as? BrowserViewController)?.presentPrivacyStatementViewController()
        }
        return openSettings
    }

    private func burnItem(vcDelegate: PageOptionsVC) -> PhotonActionSheetItem {
        let openSettings = PhotonActionSheetItem(title: Strings.Menu.BurnTitleString, iconString: "menu-burn") { action in
            (vcDelegate as? BrowserViewController)?.didPressBurnMenuItem()
        }
        return openSettings
    }

    private func openSettingsItem(vcDelegate: PageOptionsVC) -> PhotonActionSheetItem {
        let openSettings = PhotonActionSheetItem(title: Strings.Menu.SettingsTitleString, iconString: "menu-Settings") { action in
            (vcDelegate as? BrowserViewController)?.presentSettingsViewController()
        }
        return openSettings
    }

    private func openDownloadsItem(vcDelegate: PageOptionsVC) -> PhotonActionSheetItem {
        let openDownloads = PhotonActionSheetItem(title: Strings.Menu.DownloadsTitleString, iconString: "menu-downloads") { action in
            (vcDelegate as? BrowserViewController)?.showDownloads()
        }
        return openDownloads
    }

    private func refreshPageItem() -> PhotonActionSheetItem {
        let refreshPage = PhotonActionSheetItem(title: Strings.Menu.ReloadTitleString, iconString: "nav-refresh") { action in
                self.tabManager.selectedTab?.reload()
           }
           return refreshPage
       }

}
