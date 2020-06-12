//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {
    public struct Menu {
        public static let SharePageTitleString = NSLocalizedString("Menu.SharePageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the share dialog.")
        public static let NewTabTitleString = NSLocalizedString("Menu.NewTabAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open a new tab")
        public static let AddBookmarkTitleString = NSLocalizedString("Menu.AddBookmarkAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to create a bookmark for the current website.")
        public static let RemoveBookmarkTitleString = NSLocalizedString("Menu.RemoveBookmarkAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to delete an existing bookmark for the current website.")
        public static let FindInPageTitleString = NSLocalizedString("Menu.FindInPageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the toolbar to search for text within the current page.")
        public static let ViewDesktopSiteTitleString = NSLocalizedString("Menu.ViewDekstopSiteAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the desktop version of the current website.")
        public static let ViewMobileSiteTitleString = NSLocalizedString("Menu.ViewMobileSiteAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the mobile version of the current website.")
        public static let ReaderModeTitleString = NSLocalizedString("Menu.ReaderMode.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the reader mode version of the current website")
        public static let SettingsTitleString = NSLocalizedString("Menu.OpenSettingsAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the Settings menu.")
        public static let WhatsNewTitleString = NSLocalizedString("Menu.OpenWhatsNewAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the What's new page.")
        public static let PrivacyStatementTitleString = NSLocalizedString("Menu.OpenPrivacyStatementAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the Privacy Statement.")
        public static let ReloadTitleString = NSLocalizedString("Reload", comment: "Reload")
        public static let CloseAllTabsTitleString = NSLocalizedString("Menu.CloseAllTabsAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to close all tabs currently open.")
        public static let OpenHomePageTitleString = NSLocalizedString("Menu.OpenHomePageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to navigate to the home page.")
        public static let BurnTitleString = NSLocalizedString("Menu.Burn.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to navigate to the burn options.")
        public static let CloseAllTabsAndClearDataTitleString = NSLocalizedString("Menu.CloseAllTabsAndClearData.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to close all tabs and clear data.")
        public static let DownloadsTitleString = NSLocalizedString("Menu.OpenDownloadsAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Downloads home panel.")
        public static let CopyURLConfirmMessage = NSLocalizedString("Menu.CopyURL.Confirm", tableName: "Menu", comment: "Toast displayed to user after copy url pressed.")
        public static let AddBookmarkConfirmMessage = NSLocalizedString("Menu.AddBookmark.Confirm", tableName: "Menu", comment: "Toast displayed to the user after a bookmark has been added.")
        public static let RemoveBookmarkConfirmMessage = NSLocalizedString("Menu.RemoveBookmark.Confirm", tableName: "Menu", comment: "Toast displayed to the user after a bookmark has been removed.")
        public static let PageActionMenuTitle = NSLocalizedString("Menu.PageActions.Title", tableName: "Menu", comment: "Label for title in page action menu.")
        public struct TrackingProtection {
            public static let NoBlockingDescription = NSLocalizedString("Menu.TrackingProtectionNoBlocking.Description", tableName: "Menu", comment: "The description of the Tracking Protection menu item when no scripts are blocked but tracking protection is enabled.")
            public static let BlockingMoreInfo = NSLocalizedString("Menu.TrackingProtectionMoreInfo.Description", tableName: "Menu", comment: "more info about what tracking protection is about")
            public static let AdsBlocked = NSLocalizedString("Menu.TrackingProtectionAdsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
            public static let AnalyticsBlocked = NSLocalizedString("Menu.TrackingProtectionAnalyticsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
            public static let SocialBlocked = NSLocalizedString("Menu.TrackingProtectionSocialBlocked.Title", tableName: "Menu", comment: "The title that shows the number of social scripts blocked")
            public static let ContentBlocked = NSLocalizedString("Menu.TrackingProtectionContentBlocked.Title", tableName: "Menu", comment: "The title that shows the number of content scripts blocked")
            public static let EssentialBlocked = NSLocalizedString("Menu.TrackingProtectionEssentialBlocked.Title", tableName: "Menu", comment: "")
            public static let MiscBlocked = NSLocalizedString("Menu.TrackingProtectionEssentialMisc.Title", tableName: "Menu", comment: "")
            public static let HostingBlocked = NSLocalizedString("Menu.TrackingProtectionHostingBlocked.Title", tableName: "Menu", comment: "")
            public static let PornvertisingBlocked = NSLocalizedString("Menu.TrackingProtectionPornvertisingBlocked.Title", tableName: "Menu", comment: "")
            public static let AudioVideoPlayerBlocked = NSLocalizedString("Menu.TrackingProtectionAVPLayerBlocked.Title", tableName: "Menu", comment: "")
            public static let ExtensionsBlocked = NSLocalizedString("Menu.TrackingProtectionExtensionsBlocked.Title", tableName: "Menu", comment: "")
            public static let CustomerInteractionBlocked = NSLocalizedString("Menu.TrackingProtectionCustomerInteractionBlocked.Title", tableName: "Menu", comment: "")
            public static let CommentsBlocked = NSLocalizedString("Menu.TrackingProtectionCommentsBlocked.Title", tableName: "Menu", comment: "")
            public static let CDNBlocked = NSLocalizedString("Menu.TrackingProtectionCDNBlocked.Title", tableName: "Menu", comment: "")
            public static let UnknownBlocked = NSLocalizedString("Menu.TrackingProtectionUnknownBlocked.Title", tableName: "Menu", comment: "")
        }
        public static let PasteAndGoTitle = NSLocalizedString("Menu.PasteAndGo.Title", tableName: "Menu", comment: "The title for the button that lets you paste and go to a URL")
        public static let PasteTitle = NSLocalizedString("Menu.Paste.Title", tableName: "Menu", comment: "The title for the button that lets you paste into the location bar")
        public static let CopyAddressTitle = NSLocalizedString("Menu.Copy.Title", tableName: "Menu", comment: "The title for the button that lets you copy the url from the location bar.")
        public static let ClearSearchHistory = NSLocalizedString("Menu.ClearSearchHistory", tableName: "Menu", comment: "Action item that deletes all queries from database, shown on long press on search icon")
        public static let ShowQueryHistoryTitle = NSLocalizedString("Menu.QueryHistory.Title", tableName: "Menu", comment: "The title for the button that query history list")
    }
}
