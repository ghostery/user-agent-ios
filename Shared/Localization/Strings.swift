/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public struct Strings {}

/// Return the main application bundle. Even if called from an extension. If for some reason we cannot find the
/// application bundle, the current bundle is returned, which will then result in an English base language string.
private func applicationBundle() -> Bundle {
    let bundle = Bundle.main
    guard bundle.bundleURL.pathExtension == "appex", let applicationBundleURL = (bundle.bundleURL as NSURL).deletingLastPathComponent?.deletingLastPathComponent() else {
        return bundle
    }
    return Bundle(url: applicationBundleURL) ?? bundle
}

extension Strings {
    public struct General {
        public static let OKString = NSLocalizedString("OK", comment: "OK button")
        public static let CancelString = NSLocalizedString("Cancel", comment: "Label for Cancel button")
        public static let OpenSettingsString = NSLocalizedString("Open Settings", comment: "See http://mzl.la/1G7uHo7")
    }
}

extension Strings {
    public struct Toasts {
        public static let NotNowString = NSLocalizedString("Toasts.NotNow", comment: "label for Not Now button")
        public static let AppStoreString = NSLocalizedString("Toasts.OpenAppStore", comment: "Open App Store button")
    }
}

// Table date section titles.
extension Strings {
    public static let TableDateSectionTitleToday = NSLocalizedString("Today", comment: "History tableview section header")
    public static let TableDateSectionTitleYesterday = NSLocalizedString("Yesterday", comment: "History tableview section header")
    public static let TableDateSectionTitleLastWeek = NSLocalizedString("Last week", comment: "History tableview section header")
    public static let TableDateSectionTitleLastMonth = NSLocalizedString("Last month", comment: "History tableview section header")
}

// Top Sites.
extension Strings {
    public static let TopSitesEmptyStateDescription = NSLocalizedString("TopSites.EmptyState.Description", comment: "Description label for the empty Top Sites state.")
    public static let TopSitesEmptyStateTitle = NSLocalizedString("TopSites.EmptyState.Title", comment: "The title for the empty Top Sites state")
    public static let TopSitesRemoveButtonAccessibilityLabel = NSLocalizedString("TopSites.RemovePage.Button", comment: "Button shown in editing mode to remove this site from the top sites panel.")
}

// Activity Stream.

extension Strings {
    public struct ActivityStream {
        public struct News {
            public static let BreakingLabel = NSLocalizedString("ActivityStream.News.BreakingLabel", comment: "")
        }
    }
}

extension Strings {
    public static let ASTopSitesTitle =  NSLocalizedString("ActivityStream.TopSites.SectionTitle", comment: "Section title label for Top Sites")
    public static let ASPinnedSitesTitle =  NSLocalizedString("ActivityStream.PinnedSites.SectionTitle", comment: "Section title label for Pinned Sites")
    public static let HighlightVistedText = NSLocalizedString("ActivityStream.Highlights.Visited", comment: "The description of a highlight if it is a site the user has visited")
    public static let HighlightBookmarkText = NSLocalizedString("ActivityStream.Highlights.Bookmark", comment: "The description of a highlight if it is a site the user has bookmarked")
    public static let TopSitesRowSettingFooter = NSLocalizedString("ActivityStream.TopSites.RowSettingFooter", comment: "The title for the setting page which lets you select the number of top site rows")
    public static let TopSitesRowCount = NSLocalizedString("ActivityStream.TopSites.RowCount", comment: "label showing how many rows of topsites are shown. %d represents a number")
    public static let RecentlyBookmarkedTitle = NSLocalizedString("ActivityStream.NewRecentBookmarks.Title", comment: "Section title label for recently bookmarked websites")
    public static let RecentlyVisitedTitle = NSLocalizedString("ActivityStream.RecentHistory.Title", comment: "Section title label for recently visited websites")
}

// Home Panel Context Menu.
extension Strings {
    public static let OpenInNewTabContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.OpenInNewTab", comment: "The title for the Open in New Tab context menu action for sites in Home Panels")
    public static let OpenInNewPrivateTabContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.OpenInNewPrivateTab", comment: "The title for the Open in New Private Tab context menu action for sites in Home Panels")
    public static let BookmarkContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.Bookmark", comment: "The title for the Bookmark context menu action for sites in Home Panels")
    public static let RemoveBookmarkContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.RemoveBookmark", comment: "The title for the Remove Bookmark context menu action for sites in Home Panels")
    public static let DeleteFromHistoryContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.DeleteFromHistory", comment: "The title for the Delete from History context menu action for sites in Home Panels")
    public static let ShareContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.Share", comment: "The title for the Share context menu action for sites in Home Panels")
    public static let RemoveContextMenuTitle = NSLocalizedString("HomePanel.ContextMenu.Remove", comment: "The title for the Remove context menu action for sites in Home Panels")
    public static let PinTopsiteActionTitle = NSLocalizedString("ActivityStream.ContextMenu.PinTopsite", comment: "The title for the pinning a topsite action")
    public static let RemovePinTopsiteActionTitle = NSLocalizedString("ActivityStream.ContextMenu.RemovePinTopsite", comment: "The title for removing a pinned topsite action")
}

//  PhotonActionSheet Strings
extension Strings {
    public static let CloseButtonTitle = NSLocalizedString("PhotonMenu.close", comment: "Button for closing the menu action sheet")

}

// Home page.
extension Strings {
    public static let SettingsHomePageSectionName = NSLocalizedString("Settings.HomePage.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog to configure the home page and its uses.")
    public static let SettingsHomePageTitle = NSLocalizedString("Settings.HomePage.Title", comment: "Title displayed in header of the setting panel.")
    public static let SettingsHomePageURLSectionTitle = NSLocalizedString("Settings.HomePage.URL.Title", comment: "Title of the setting section containing the URL of the current home page.")
    public static let SettingsHomePageUseCurrentPage = NSLocalizedString("Settings.HomePage.UseCurrent.Button", comment: "Button in settings to use the current page as home page.")
    public static let SettingsHomePagePlaceholder = NSLocalizedString("Settings.HomePage.URL.Placeholder", comment: "Placeholder text in the homepage setting when no homepage has been set.")
    public static let SettingsHomePageUseCopiedLink = NSLocalizedString("Settings.HomePage.UseCopiedLink.Button", comment: "Button in settings to use the current link on the clipboard as home page.")
    public static let SettingsHomePageUseDefault = NSLocalizedString("Settings.HomePage.UseDefault.Button", comment: "Button in settings to use the default home page. If no default is set, then this button isn't shown.")
    public static let SettingsHomePageClear = NSLocalizedString("Settings.HomePage.Clear.Button", comment: "Button in settings to clear the home page.")
    public static let SetHomePageDialogTitle = NSLocalizedString("HomePage.Set.Dialog.Title", comment: "Alert dialog title when the user opens the home page for the first time.")
    public static let SetHomePageDialogMessage = NSLocalizedString("HomePage.Set.Dialog.Message", comment: "Alert dialog body when the user opens the home page for the first time.")
    public static let SetHomePageDialogYes = NSLocalizedString("HomePage.Set.Dialog.OK", comment: "Button accepting changes setting the home page for the first time.")
    public static let SetHomePageDialogNo = NSLocalizedString("HomePage.Set.Dialog.Cancel", comment: "Button cancelling changes setting the home page for the first time.")
    public static let ReopenLastTabAlertTitle = NSLocalizedString("ReopenAlert.Title", comment: "Reopen alert title shown at home page.")
    public static let ReopenLastTabButtonText = NSLocalizedString("ReopenAlert.Actions.Reopen", comment: "Reopen button text shown in reopen-alert at home page.")
    public static let ReopenLastTabCancelText = NSLocalizedString("ReopenAlert.Actions.Cancel", comment: "Cancel button text shown in reopen-alert at home page.")
}

// Home View
extension Strings {
    public static let SegmentedControlTopSitesTitle = NSLocalizedString("HomeView.SegmentedControl.TopSites.Title", tableName: "UserAgent", comment: "")
    public static let SegmentedControlBookmarksTitle = NSLocalizedString("HomeView.SegmentedControl.Bookmarks.Title", tableName: "UserAgent", comment: "")
    public static let SegmentedControlHistoryTitle = NSLocalizedString("HomeView.SegmentedControl.History.Title", tableName: "UserAgent", comment: "")
    public static let SegmentedControlDownloadsTitle = NSLocalizedString("HomeView.SegmentedControl.Downloads.Title", tableName: "UserAgent", comment: "")
    public static let emptyBookmarksText = NSLocalizedString("Bookmarks you save will show up here.", comment: "Status label for the empty Bookmarks state.")
    public static let deleteBookmark = NSLocalizedString("Delete", tableName: "HistoryPanel", comment: "Action button for deleting history entries in the history panel.")
}

// Settings.
extension Strings {
    public static let SettingsGeneralSectionTitle = NSLocalizedString("Settings.General.SectionName", comment: "General settings section title")
    public static let SettingsClearPrivateDataClearButton = NSLocalizedString("Settings.ClearPrivateData.Clear.Button", comment: "Button in settings that clears private data for the selected items.")
    public static let SettingsClearAllWebsiteDataButton = NSLocalizedString("Settings.ClearAllWebsiteData.Clear.Button", comment: "Button in Data Management that clears private data for the selected items.")
    public static let SettingsClearPrivateDataSectionName = NSLocalizedString("Settings.ClearPrivateData.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
    public static let SettingsDataManagementSectionName = NSLocalizedString("Settings.DataManagement.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
    public static let SettingsFilterSitesSearchLabel = NSLocalizedString("Settings.DataManagement.SearchLabel", comment: "Default text in search bar for Data Management")
    public static let SettingsClearPrivateDataTitle = NSLocalizedString("Settings.ClearPrivateData.Title", comment: "Title displayed in header of the setting panel.")
    public static let SettingsDataManagementTitle = NSLocalizedString("Settings.DataManagement.Title", comment: "Title displayed in header of the setting panel.")
    public static let SettingsWebsiteDataTitle = NSLocalizedString("Settings.WebsiteData.Title", comment: "Title displayed in header of the Data Management panel.")
    public static let SettingsWebsiteDataShowMoreButton = NSLocalizedString("Settings.WebsiteData.ButtonShowMore", comment: "Button shows all websites on website data tableview")
    public static let SettingsClearWebsiteDataMessage = NSLocalizedString("Settings.WebsiteData.ConfirmPrompt", comment: "Description of the confirmation dialog shown when a user tries to clear their private data.")
    public static let SettingsEditWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonEdit", comment: "Button to edit website search results")
    public static let SettingsDeleteWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonDelete", comment: "Button to delete website in search results")
    public static let SettingsDoneWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonDone", comment: "Button to exit edit website search results")
    public static let SettingsDisconnectSyncButton = NSLocalizedString("Settings.Disconnect.Button", comment: "Button displayed at the bottom of settings page allowing users to Disconnect from FxA")
    public static let SettingsDisconnectCancelAction = NSLocalizedString("Settings.Disconnect.CancelButton", comment: "Cancel action button in alert when user is prompted for disconnect")
    public static let SettingsDisconnectDestructiveAction = NSLocalizedString("Settings.Disconnect.DestructiveButton", comment: "Destructive action button in alert when user is prompted for disconnect")
    public static let SettingsSearchDoneButton = NSLocalizedString("Settings.Search.Done.Button", comment: "Button displayed at the top of the search settings.")
    public static let SettingsSearchEditButton = NSLocalizedString("Settings.Search.Edit.Button", comment: "Button displayed at the top of the search settings.")
    public static let UseTouchID = NSLocalizedString("Use Touch ID", tableName: "AuthenticationManager", comment: "List section title for when to use Touch ID")
    public static let UseFaceID = NSLocalizedString("Use Face ID", tableName: "AuthenticationManager", comment: "List section title for when to use Face ID")
    public static let SettingsCopyAppVersionAlertTitle = NSLocalizedString("Settings.CopyAppVersion.Title", comment: "Copy app version alert shown in settings.")
}

// Error pages.
extension Strings {
    public static let ErrorPagesAdvancedButton = NSLocalizedString("ErrorPages.Advanced.Button", comment: "Label for button to perform advanced actions on the error page")
    public static let ErrorPagesAdvancedWarning1 = NSLocalizedString("ErrorPages.AdvancedWarning1.Text", comment: "Warning text when clicking the Advanced button on error pages")
    public static let ErrorPagesAdvancedWarning2 = NSLocalizedString("ErrorPages.AdvancedWarning2.Text", comment: "Additional warning text when clicking the Advanced button on error pages")
    public static let ErrorPagesCertWarningDescription = NSLocalizedString("ErrorPages.CertWarning.Description", comment: "Warning text on the certificate error page. First argument 'Error Domain', Second - 'App name'")
    public static let ErrorPagesCertWarningTitle = NSLocalizedString("ErrorPages.CertWarning.Title", comment: "Title on the certificate error page")
    public static let ErrorPagesGoBackButton = NSLocalizedString("ErrorPages.GoBack.Button", comment: "Label for button to go back from the error page")
    public static let ErrorPagesVisitOnceButton = NSLocalizedString("ErrorPages.VisitOnce.Button", comment: "Button label to temporarily continue to the site from the certificate error page")
}

// Logins Helper.
extension Strings {
    public static let LoginsHelperSaveLoginButtonTitle = NSLocalizedString("LoginsHelper.SaveLogin.Button", comment: "Button to save the user's password")
    public static let LoginsHelperDontSaveButtonTitle = NSLocalizedString("LoginsHelper.DontSave.Button", comment: "Button to not save the user's password")
    public static let LoginsHelperUpdateButtonTitle = NSLocalizedString("LoginsHelper.Update.Button", comment: "Button to update the user's password")
    public static let LoginsHelperDontUpdateButtonTitle = NSLocalizedString("LoginsHelper.DontUpdate.Button", comment: "Button to not update the user's password")
}

// Downloads Panel
extension Strings {
    public static let DownloadsPanelEmptyStateTitle = NSLocalizedString("DownloadsPanel.EmptyState.Title", comment: "Title for the Downloads Panel empty state.")
}

// History Panel
extension Strings {
    public static let HistoryBackButtonTitle = NSLocalizedString("HistoryPanel.HistoryBackButton.Title", comment: "Title for the Back to History button in the History Panel")
    public static let HistoryPanelEmptyStateTitle = NSLocalizedString("HistoryPanel.EmptyState.Title", comment: "Title for the History Panel empty state.")
    public static let RecentlyClosedTabsButtonTitle = NSLocalizedString("HistoryPanel.RecentlyClosedTabsButton.Title", comment: "Title for the Recently Closed button in the History Panel")
    public static let RecentlyClosedTabsPanelTitle = NSLocalizedString("RecentlyClosedTabsPanel.Title", comment: "Title for the Recently Closed Tabs Panel")
    public static let HistoryPanelClearHistoryButtonTitle = NSLocalizedString("HistoryPanel.ClearHistoryButtonTitle", comment: "Title for button in the history panel to clear recent history")
    public static let FirefoxHomePage = String(format: NSLocalizedString("UserAgent.HomePage.Title", comment: "Title for firefox about:home page in tab history list"), AppInfo.displayName)
}

// Clear recent history action menu
extension Strings {
    public static let ClearHistoryMenuTitle = NSLocalizedString("HistoryPanel.ClearHistoryMenuTitle", comment: "Title for popup action menu to clear recent history.")
    public static let ClearHistoryMenuOptionTheLastHour = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionTheLastHour", comment: "Button to perform action to clear history for the last hour")
    public static let ClearHistoryMenuOptionToday = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionToday", comment: "Button to perform action to clear history for today only")
    public static let ClearHistoryMenuOptionTodayAndYesterday = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionTodayAndYesterday", comment: "Button to perform action to clear history for yesterday and today")
}

// Firefox Logins
extension Strings {
    public static let LoginsAndPasswordsTitle = NSLocalizedString("Settings.LoginsAndPasswordsTitle", comment: "Title for the logins and passwords screen. Translation could just use 'Logins' if the title is too long")

    // Prompts
    public static let SaveLoginUsernamePrompt = NSLocalizedString("LoginsHelper.PromptSaveLogin.Title", comment: "Prompt for saving a login. The first parameter is the username being saved. The second parameter is the hostname of the site.")
    public static let SaveLoginPrompt = NSLocalizedString("LoginsHelper.PromptSavePassword.Title", comment: "Prompt for saving a password with no username. The parameter is the hostname of the site.")
    public static let UpdateLoginUsernamePrompt = NSLocalizedString("LoginsHelper.PromptUpdateLogin.Title", comment: "Prompt for updating a login. The first parameter is the username for which the password will be updated for. The second parameter is the hostname of the site.")
    public static let UpdateLoginPrompt = NSLocalizedString("LoginsHelper.PromptUpdateLogin.Title", comment: "Prompt for updating a login. The first parameter is the username for which the password will be updated for. The second parameter is the hostname of the site.")

    // Setting
    public static let SettingToSaveLogins = NSLocalizedString("Settings.SaveLogins.Title", comment: "Setting to enable the built-in password manager")
    public static let SettingToShowLoginsInAppMenu = NSLocalizedString("Settings.ShowLoginsInAppMenu.Title", comment: "Setting to show Logins & Passwords quick access in the application menu")

    // List view
    public static let LoginsListTitle = NSLocalizedString("LoginsList.Title", comment: "Title for the list of logins")
    public static let LoginsListSearchPlaceholder = NSLocalizedString("LoginsList.LoginsListSearchPlaceholder", comment: "Placeholder test for search box in logins list view.")
    public static let LoginsFilterWebsite = NSLocalizedString("LoginsList.LoginsListFilterWebsite", comment: "For filtering the login list, search only the website names")
    public static let LoginsFilterLogin = NSLocalizedString("LoginsList.LoginsListFilterLogin", comment: "For filtering the login list, search only the login names")
    public static let LoginsFilterAll = NSLocalizedString("LoginsList.LoginsListFilterSearchAll", comment: "For filtering the login list, search both website and login names.")

    // Detail view
    public static let LoginsDetailViewLoginTitle = NSLocalizedString("LoginsDetailView.LoginTitle", comment: "Title for the login detail view")
    public static let LoginsDetailViewLoginModified = NSLocalizedString("LoginsDetailView.LoginModified", comment: "Login detail view field name for the last modified date")
}

//Hotkey Titles
extension Strings {
    public static let ReloadPageTitle = NSLocalizedString("Hotkeys.Reload.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let BackTitle = NSLocalizedString("Hotkeys.Back.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ForwardTitle = NSLocalizedString("Hotkeys.Forward.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")

    public static let FindTitle = NSLocalizedString("Hotkeys.Find.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let SelectLocationBarTitle = NSLocalizedString("Hotkeys.SelectLocationBar.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let privateBrowsingModeTitle = NSLocalizedString("Hotkeys.PrivateMode.DiscoveryTitle", comment: "Label to switch to private browsing mode")
    public static let normalBrowsingModeTitle = NSLocalizedString("Hotkeys.NormalMode.DiscoveryTitle", comment: "Label to switch to normal browsing mode")
    public static let NewTabTitle = NSLocalizedString("Hotkeys.NewTab.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let NewPrivateTabTitle = NSLocalizedString("Hotkeys.NewPrivateTab.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let CloseTabTitle = NSLocalizedString("Hotkeys.CloseTab.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ShowNextTabTitle = NSLocalizedString("Hotkeys.ShowNextTab.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
    public static let ShowPreviousTabTitle = NSLocalizedString("Hotkeys.ShowPreviousTab.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
}

// New tab choice settings
extension Strings {
    public static let CustomNewPageURL = NSLocalizedString("Settings.NewTab.CustomURL", comment: "Label used to set a custom url as the new tab option (homepage).")
    public static let SettingsNewTabSectionName = NSLocalizedString("Settings.NewTab.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog to configure the new tab behaviour.")
    public static let NewTabSectionName =
        NSLocalizedString("Settings.NewTab.TopSectionName", comment: "Label at the top of the New Tab screen after entering New Tab in settings")
    public static let SettingsNewTabTitle = NSLocalizedString("Settings.NewTab.Title", comment: "Title displayed in header of the setting panel.")
    public static let NewTabSectionNameFooter =
        NSLocalizedString("Settings.NewTab.TopSectionNameFooter", comment: "Footer at the bottom of the New Tab screen after entering New Tab in settings")
    public static let SettingsNewTabTopSites = String(format: NSLocalizedString("Settings.NewTab.Option.Home", comment: "Option in settings to show Firefox Home when you open a new tab"), AppInfo.displayName)
    public static let SettingsNewTabBookmarks = NSLocalizedString("Settings.NewTab.Option.Bookmarks", comment: "Option in settings to show bookmarks when you open a new tab")
    public static let SettingsNewTabHistory = NSLocalizedString("Settings.NewTab.Option.History", comment: "Option in settings to show history when you open a new tab")
    public static let SettingsNewTabBlankPage = NSLocalizedString("Settings.NewTab.Option.BlankPage", comment: "Option in settings to show a blank page when you open a new tab")
    public static let SettingsNewTabHomePage = NSLocalizedString("Settings.NewTab.Option.HomePage", comment: "Option in settings to show your homepage when you open a new tab")
    public static let SettingsNewTabDescription = NSLocalizedString("Settings.NewTab.Description", comment: "A description in settings of what the new tab choice means")
    // AS Panel settings
    public static let SettingsNewTabASTitle = NSLocalizedString("Settings.NewTab.Option.ASTitle", comment: "The title of the section in newtab that lets you modify the topsites panel")
    public static let SettingsNewTabHiglightsHistory = NSLocalizedString("Settings.NewTab.Option.HighlightsHistory", comment: "Option in settings to turn off history in the highlights section")
    public static let SettingsNewTabHighlightsBookmarks = NSLocalizedString("Settings.NewTab.Option.HighlightsBookmarks", comment: "Option in the settings to turn off recent bookmarks in the Highlights section")
    public static let SettingsTopSitesCustomizeTitle = String(format: NSLocalizedString("Settings.NewTab.Option.CustomizeTitle", comment: "The title for the section to customize top sites in the new tab settings page."), AppInfo.displayName)
    public static let SettingsTopSitesCustomizeFooter = NSLocalizedString("Settings.NewTab.Option.CustomizeFooter", comment: "The footer for the section to customize top sites in the new tab settings page.")

}

// Custom account settings - These strings did not make it for the v10 l10n deadline so we have turned them into regular strings. These strings will come back localized in a next version.

extension Strings {
    // Settings.AdvancedAccount.AutoconfigSectionFooter
    // Details for using custom Firefox Account service.
    public static let SettingsAdvancedAccountAutoconfigSectionFooter = "To use custom Firefox Account/Sync servers via autoconfig, specify the root URL of the custom Firefox Account site. This will download the configuration and setup this device to use the new service. After the new service has been set, you will need to create a new Firefox Account or login with an existing one."

    // Settings.AdvancedAccount.TokenServerSectionFooter
    // Details for using custom Firefox Account service.
    public static let SettingsAdvancedAccountTokenServerSectionFooter = "To override a custom Firefox Sync server, specify the URL of the custom Firefox Sync server. After the new server has been set, you will need to log-out and login again for the changes to take effect."

    // Settings.AdvancedAccount.SectionName
    // Title displayed in header of the setting panel.
    public static let SettingsAdvancedAccountTitle = "Advanced Sync Settings"

    // Settings.AdvancedAccount.CustomAutoconfigURIPlaceholder
    // Title displayed in header of the setting panel.
    public static let SettingsAdvancedAccountCustomAutoconfigURIPlaceholder = "Custom Autoconfig URI"

    // Settings.AdvancedAccount.ustomSyncTokenServerURIPlaceholder
    // Title displayed in header of the setting panel.
    public static let SettingsAdvancedAccountCustomSyncTokenServerURIPlaceholder = "Custom Sync Token Server URI"

    // Settings.AdvancedAccount.UpdatedAlertMessage
    // Messaged displayed when sync service has been successfully set.
    public static let SettingsAdvancedAccountUrlUpdatedAlertMessage = "Firefox Account service updated. To begin using custom server, please log out and re-login."

    // Settings.AdvancedAccount.ErrorAlertTitle
    // Error alert message title.
    public static let SettingsAdvancedAccountUrlErrorAlertTitle = "Error"

    // Settings.AdvancedAccount.ErrorAlertMessage
    // Messaged displayed when sync service has an error setting a custom sync url.
    public static let SettingsAdvancedAccountUrlErrorAlertMessage = "There was an error while attempting to fetch the autoconfig. Please make sure that it is a valid Firefox Account root URL."

    // Settings.AdvancedAccount.UseCustomAccountsServiceTitle
    // Toggle switch to use custom FxA server
    public static let SettingsAdvancedAccountUseCustomAccountsServiceTitle = "Use Custom Autoconfig"

    // Settings.AdvancedAccount.EmptyAutoconfigURIErrorAlertMessage
    // No custom service set.
    public static let SettingsAdvancedAccountEmptyAutoconfigURIErrorAlertMessage = "Please enter a custom autoconfig URI before enabling."

    // Settings.AdvancedAccount.UseCustomSyncTokenServerTitle
    // Toggle switch to use custom FxA server
    public static let SettingsAdvancedAccountUseCustomSyncTokenServerTitle = "Use Custom Sync Token Server"

    // Settings.AdvancedAccount.EmptyTokenServerURIErrorAlertMessage
    // No custom service set.
    public static let SettingsAdvancedAccountEmptyTokenServerURIErrorAlertMessage = "Please enter a custom token server URI before enabling."
}

// Open With Settings
extension Strings {
    public static let SettingsOpenWithSectionName = NSLocalizedString("Settings.OpenWith.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog to configure the open with (mail links) behaviour.")
    public static let SettingsOpenWithPageTitle = NSLocalizedString("Settings.OpenWith.PageTitle", comment: "Title for Open With Settings")
}

// Third Party Search Engines
extension Strings {
    public static let ThirdPartySearchEngineAdded = NSLocalizedString("Search.ThirdPartyEngines.AddSuccess", comment: "The success message that appears after a user sucessfully adds a new search engine")
    public static let ThirdPartySearchAddTitle = NSLocalizedString("Search.ThirdPartyEngines.AddTitle", comment: "The title that asks the user to Add the search provider")
    public static let ThirdPartySearchAddMessage = NSLocalizedString("Search.ThirdPartyEngines.AddMessage", comment: "The message that asks the user to Add the search provider explaining where the search engine will appear")
    public static let ThirdPartySearchCancelButton = NSLocalizedString("Search.ThirdPartyEngines.Cancel", comment: "The cancel button if you do not want to add a search engine.")
    public static let ThirdPartySearchOkayButton = NSLocalizedString("Search.ThirdPartyEngines.OK", comment: "The confirmation button")
    public static let ThirdPartySearchFailedTitle = NSLocalizedString("Search.ThirdPartyEngines.FailedTitle", comment: "A title explaining that we failed to add a search engine")
    public static let ThirdPartySearchFailedMessage = NSLocalizedString("Search.ThirdPartyEngines.FailedMessage", comment: "A title explaining that we failed to add a search engine")
    public static let CustomEngineFormErrorTitle = NSLocalizedString("Search.ThirdPartyEngines.FormErrorTitle", comment: "A title stating that we failed to add custom search engine.")
    public static let CustomEngineFormErrorMessage = NSLocalizedString("Search.ThirdPartyEngines.FormErrorMessage", comment: "A message explaining fault in custom search engine form.")
    public static let CustomEngineDuplicateErrorTitle = NSLocalizedString("Search.ThirdPartyEngines.DuplicateErrorTitle", comment: "A title stating that we failed to add custom search engine.")
    public static let CustomEngineDuplicateErrorMessage = NSLocalizedString("Search.ThirdPartyEngines.DuplicateErrorMessage", comment: "A message explaining fault in custom search engine form.")
}

// Root Bookmarks folders
extension Strings {
    public static let BookmarksFolderTitleMobile = NSLocalizedString("Mobile Bookmarks", tableName: "Storage", comment: "The title of the folder that contains mobile bookmarks. This should match bookmarks.folder.mobile.label on Android.")
    public static let BookmarksFolderTitleMenu = NSLocalizedString("Bookmarks Menu", tableName: "Storage", comment: "The name of the folder that contains desktop bookmarks in the menu. This should match bookmarks.folder.menu.label on Android.")
    public static let BookmarksFolderTitleToolbar = NSLocalizedString("Bookmarks Toolbar", tableName: "Storage", comment: "The name of the folder that contains desktop bookmarks in the toolbar. This should match bookmarks.folder.toolbar.label on Android.")
    public static let BookmarksFolderTitleUnsorted = NSLocalizedString("Unsorted Bookmarks", tableName: "Storage", comment: "The name of the folder that contains unsorted desktop bookmarks. This should match bookmarks.folder.unfiled.label on Android.")
}

// Bookmark Management
extension Strings {
    public static let BookmarksTitle = NSLocalizedString("Bookmarks.Title.Label", comment: "The label for the title of a bookmark")
    public static let BookmarksURL = NSLocalizedString("Bookmarks.URL.Label", comment: "The label for the URL of a bookmark")
    public static let BookmarksFolder = NSLocalizedString("Bookmarks.Folder.Label", comment: "The label to show the location of the folder where the bookmark is located")
    public static let BookmarksNewBookmark = NSLocalizedString("Bookmarks.NewBookmark.Label", comment: "The button to create a new bookmark")
    public static let BookmarksNewFolder = NSLocalizedString("Bookmarks.NewFolder.Label", comment: "The button to create a new folder")
    public static let BookmarksNewSeparator = NSLocalizedString("Bookmarks.NewSeparator.Label", comment: "The button to create a new separator")
    public static let BookmarksEditBookmark = NSLocalizedString("Bookmarks.EditBookmark.Label", comment: "The button to edit a bookmark")
    public static let BookmarksEditFolder = NSLocalizedString("Bookmarks.EditFolder.Label", comment: "The button to edit a folder")
    public static let BookmarksFolderName = NSLocalizedString("Bookmarks.FolderName.Label", comment: "The label for the title of the new folder")
    public static let BookmarksFolderLocation = NSLocalizedString("Bookmarks.FolderLocation.Label", comment: "The label for the location of the new folder")
    public static let BookmarksDeleteFolderWarningTitle = NSLocalizedString("Bookmarks.DeleteFolderWarning.Title", tableName: "BookmarkPanelDeleteConfirm", comment: "Title of the confirmation alert when the user tries to delete a folder that still contains bookmarks and/or folders.")
    public static let BookmarksDeleteFolderWarningDescription = NSLocalizedString("Bookmarks.DeleteFolderWarning.Description", tableName: "BookmarkPanelDeleteConfirm", comment: "Main body of the confirmation alert when the user tries to delete a folder that still contains bookmarks and/or folders.")
    public static let BookmarksDeleteFolderCancelButtonLabel = NSLocalizedString("Bookmarks.DeleteFolderWarning.CancelButton.Label", tableName: "BookmarkPanelDeleteConfirm", comment: "Button label to cancel deletion when the user tried to delete a non-empty folder.")
    public static let BookmarksDeleteFolderDeleteButtonLabel = NSLocalizedString("Bookmarks.DeleteFolderWarning.DeleteButton.Label", tableName: "BookmarkPanelDeleteConfirm", comment: "Button label for the button that deletes a folder and all of its children.")
    public static let BookmarksPanelEmptyStateTitle = NSLocalizedString("BookmarksPanel.EmptyState.Title", comment: "Status label for the empty Bookmarks state.")
    public static let BookmarksPanelDeleteTableAction = NSLocalizedString("Delete", tableName: "BookmarkPanel", comment: "Action button for deleting bookmarks in the bookmarks panel.")
    public static let BookmarkDetailFieldTitle = NSLocalizedString("Bookmark.DetailFieldTitle.Label", comment: "The label for the Title field when editing a bookmark")
    public static let BookmarkDetailFieldURL = NSLocalizedString("Bookmark.DetailFieldURL.Label", comment: "The label for the URL field when editing a bookmark")
    public static let BookmarkDetailFieldsHeaderBookmarkTitle = NSLocalizedString("Bookmark.BookmarkDetail.FieldsHeader.Bookmark.Title", comment: "The header title for the fields when editing a Bookmark")
    public static let BookmarkDetailFieldsHeaderFolderTitle = NSLocalizedString("Bookmark.BookmarkDetail.FieldsHeader.Folder.Title", comment: "The header title for the fields when editing a Folder")
}

// Tabs Delete All Undo Toast
extension Strings {
    public static let TabsDeleteAllUndoTitle = NSLocalizedString("Tabs.DeleteAllUndo.Title", comment: "The label indicating that all the tabs were closed")
    public static let TabsDeleteAllUndoAction = NSLocalizedString("Tabs.DeleteAllUndo.Button", comment: "The button to undo the delete all tabs")
}

//Clipboard Toast
extension Strings {
    public static let GoToCopiedLink = NSLocalizedString("ClipboardToast.GoToCopiedLink.Title", comment: "Message displayed when the user has a copied link on the clipboard")
    public static let GoButtonTittle = NSLocalizedString("ClipboardToast.GoToCopiedLink.Button", comment: "The button to open a new tab with the copied link")

    public static let SettingsOfferClipboardBarTitle = NSLocalizedString("Settings.OfferClipboardBar.Title", comment: "Title of setting to enable the Go to Copied URL feature. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349")
    public static let SettingsOfferClipboardBarStatus = String(format: NSLocalizedString("Settings.OfferClipboardBar.Status", comment: "Description displayed under the ”Offer to Open Copied Link” option. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349"), AppInfo.displayName)
}

// errors
extension Strings {
    public static let UnableToDownloadError = String(format: NSLocalizedString("Downloads.Error.Message", comment: "The message displayed to a user when they try and perform the download of an asset that Firefox cannot currently handle."), AppInfo.displayName)
    public static let UnableToAddPassErrorTitle = NSLocalizedString("AddPass.Error.Title", comment: "Title of the 'Add Pass Failed' alert. See https://support.apple.com/HT204003 for context on Wallet.")
    public static let UnableToAddPassErrorMessage = NSLocalizedString("AddPass.Error.Message", comment: "Text of the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
    public static let UnableToAddPassErrorDismiss = NSLocalizedString("AddPass.Error.Dismiss", comment: "Button to dismiss the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
    public static let UnableToOpenURLError = String(format: NSLocalizedString("OpenURL.Error.Message", comment: "The message displayed to a user when they try to open a URL that cannot be handled by Firefox, or any external app."), AppInfo.displayName)
    public static let UnableToOpenURLErrorTitle = NSLocalizedString("OpenURL.Error.Title", comment: "Title of the message shown when the user attempts to navigate to an invalid link.")
    public static let RestoreTabsAfterCrashMessage = String(format: NSLocalizedString("Restore.Tabs.After.Crash", comment: "Restore Tabs Prompt Description"), AppInfo.displayName)
    public static let AppCrashedMessage = String(format: NSLocalizedString("App.Crashed", comment: "App crashed"), AppInfo.displayName)
}

// Download Helper
extension Strings {
    public static let OpenInDownloadHelperAlertDownloadNow = NSLocalizedString("Downloads.Alert.DownloadNow", comment: "The label of the button the user will press to start downloading a file")
    public static let DownloadsButtonTitle = NSLocalizedString("Downloads.Toast.GoToDownloads.Button", comment: "The button to open a new tab with the Downloads home panel")
    public static let CancelDownloadDialogTitle = NSLocalizedString("Downloads.CancelDialog.Title", comment: "Alert dialog title when the user taps the cancel download icon.")
    public static let CancelDownloadDialogMessage = NSLocalizedString("Downloads.CancelDialog.Message", comment: "Alert dialog body when the user taps the cancel download icon.")
    public static let CancelDownloadDialogResume = NSLocalizedString("Downloads.CancelDialog.Resume", comment: "Button declining the cancellation of the download.")
    public static let CancelDownloadDialogCancel = NSLocalizedString("Downloads.CancelDialog.Cancel", comment: "Button confirming the cancellation of the download.")
    public static let DownloadCancelledToastLabelText = NSLocalizedString("Downloads.Toast.Cancelled.LabelText", comment: "The label text in the Download Cancelled toast for showing confirmation that the download was cancelled.")
    public static let DownloadFailedToastLabelText = NSLocalizedString("Downloads.Toast.Failed.LabelText", comment: "The label text in the Download Failed toast for showing confirmation that the download has failed.")
    public static let DownloadFailedToastButtonTitled = NSLocalizedString("Downloads.Toast.Failed.RetryButton", comment: "The button to retry a failed download from the Download Failed toast.")
    public static let DownloadMultipleFilesToastDescriptionText = NSLocalizedString("Downloads.Toast.MultipleFiles.DescriptionText", comment: "The description text in the Download progress toast for showing the number of files when multiple files are downloading.")
    public static let DownloadProgressToastDescriptionText = NSLocalizedString("Downloads.Toast.Progress.DescriptionText", comment: "The description text in the Download progress toast for showing the downloaded file size (1$) out of the total expected file size (2$).")
    public static let DownloadMultipleFilesAndProgressToastDescriptionText = NSLocalizedString("Downloads.Toast.MultipleFilesAndProgress.DescriptionText", comment: "The description text in the Download progress toast for showing the number of files (1$) and download progress (2$). This string only consists of two placeholders for purposes of displaying two other strings side-by-side where 1$ is Downloads.Toast.MultipleFiles.DescriptionText and 2$ is Downloads.Toast.Progress.DescriptionText. This string should only consist of the two placeholders side-by-side separated by a single space and 1$ should come before 2$ everywhere except for right-to-left locales.")
}

// Add Custom Search Engine
extension Strings {
    public static let SettingsSearchSectionTitle = NSLocalizedString("Settings.Search.SectionName", comment: "Search settings section title")
    public static let SettingsAdditionalSearchEnginesSectionTitle = NSLocalizedString("Settings.AdditionalSearchEngines.SectionName", comment: "The button text in Search Settings that opens the Additional Search Engines view.")
    public static let SettingsAddCustomEngine = NSLocalizedString("Settings.AddCustomEngine", comment: "The button text in Search Settings that opens the Custom Search Engine view.")
    public static let SettingsAddCustomEngineTitle = NSLocalizedString("Settings.AddCustomEngine.Title", comment: "The title of the  Custom Search Engine view.")
    public static let SettingsAddCustomEngineTitleLabel = NSLocalizedString("Settings.AddCustomEngine.TitleLabel", comment: "The title for the field which sets the title for a custom search engine.")
    public static let SettingsAddCustomEngineURLLabel = NSLocalizedString("Settings.AddCustomEngine.URLLabel", comment: "The title for URL Field")
    public static let SettingsAddCustomEngineTitlePlaceholder = NSLocalizedString("Settings.AddCustomEngine.TitlePlaceholder", comment: "The placeholder for Title Field when saving a custom search engine.")
    public static let SettingsAddCustomEngineURLPlaceholder = NSLocalizedString("Settings.AddCustomEngine.URLPlaceholder", comment: "The placeholder for URL Field when saving a custom search engine")
    public static let SettingsAddCustomEngineSaveButtonText = NSLocalizedString("Settings.AddCustomEngine.SaveButtonText", comment: "The text on the Save button when saving a custom search engine")
}

// Search Results For Language
extension Strings {
    public static let SettingsSearchResultForLanguage = NSLocalizedString("Settings.SearchResultForLanguage", comment: "The button text in Settings that opens the list of supported search languages.")
    public static let SettingsSearchResultForGerman = NSLocalizedString("region-DE", comment: "Localized String for German region")
}

// Adult Filter Mode
extension Strings {
    public static let SettingsAdultFilterMode = NSLocalizedString("Settings.AdultFilterMode", comment: "Block explicit content")
}

// Ad Blocking and Tracking Protection
extension Strings {
    public struct Settings {
        public struct PrivacyDashboard {
            public static let Title = NSLocalizedString("Settings.PrivacyDashboard.Title", comment: "Privacy Dashboard Title")
            public static let Description = NSLocalizedString("Settings.PrivacyDashboard.Description", comment: "Privacy Dashboard Description")
        }
    }
}

// Context menu ButtonToast instances.
extension Strings {
    public static let ContextMenuButtonToastNewTabOpenedLabelText = NSLocalizedString("ContextMenu.ButtonToast.NewTabOpened.LabelText", comment: "The label text in the Button Toast for switching to a fresh New Tab.")
    public static let ContextMenuButtonToastNewTabOpenedButtonText = NSLocalizedString("ContextMenu.ButtonToast.NewTabOpened.ButtonText", comment: "The button text in the Button Toast for switching to a fresh New Tab.")
    public static let ContextMenuButtonToastNewPrivateTabOpenedLabelText = NSLocalizedString("ContextMenu.ButtonToast.NewPrivateTabOpened.LabelText", comment: "The label text in the Button Toast for switching to a fresh New Private Tab.")
    public static let ContextMenuButtonToastNewPrivateTabOpenedButtonText = NSLocalizedString("ContextMenu.ButtonToast.NewPrivateTabOpened.ButtonText", comment: "The button text in the Button Toast for switching to a fresh New Private Tab.")
}

// Page context menu items (i.e. links and images).
extension Strings {
    public static let ContextMenuOpenInNewTab = NSLocalizedString("ContextMenu.OpenInNewTabButtonTitle", comment: "Context menu item for opening a link in a new tab")
    public static let ContextMenuBookmarkLink = NSLocalizedString("ContextMenu.BookmarkLinkButtonTitle", comment: "Context menu item for bookmarking a link URL")
    public static let ContextMenuDownloadLink = NSLocalizedString("ContextMenu.DownloadLinkButtonTitle", comment: "Context menu item for downloading a link URL")
    public static let ContextMenuCopyLink = NSLocalizedString("ContextMenu.CopyLinkButtonTitle", comment: "Context menu item for copying a link URL to the clipboard")
    public static let ContextMenuShareLink = NSLocalizedString("ContextMenu.ShareLinkButtonTitle", comment: "Context menu item for sharing a link URL")
    public static let ContextMenuSaveImage = NSLocalizedString("ContextMenu.SaveImageButtonTitle", comment: "Context menu item for saving an image")
    public static let ContextMenuCopyImage = NSLocalizedString("ContextMenu.CopyImageButtonTitle", comment: "Context menu item for copying an image to the clipboard")
    public static let ContextMenuCopyImageLink = NSLocalizedString("ContextMenu.CopyImageLinkButtonTitle", comment: "Context menu item for copying an image URL to the clipboard")
}

// Photo Library access.
extension Strings {
    public static let PhotoLibraryFirefoxWouldLikeAccessTitle = String(format: NSLocalizedString("PhotoLibrary.AppWouldLikeAccessTitle", comment: "See http://mzl.la/1G7uHo7"), AppInfo.displayName)
    public static let PhotoLibraryFirefoxWouldLikeAccessMessage = NSLocalizedString("PhotoLibrary.AppWouldLikeAccessMessage", comment: "See http://mzl.la/1G7uHo7")
}

// Sent tabs notifications. These are displayed when the app is backgrounded or the device is locked.
extension Strings {
    // Notification Actions
    public static let SentTabViewActionTitle = NSLocalizedString("SentTab.ViewAction.title", comment: "Label for an action used to view one or more tabs from a notification.")
}

// Reader Mode.
extension Strings {
    public static let ReaderModeAvailableVoiceOverAnnouncement = NSLocalizedString("ReaderMode.Available.VoiceOverAnnouncement", comment: "Accessibility message e.g. spoken by VoiceOver when Reader Mode becomes available.")
    public static let ReaderModeResetFontSizeAccessibilityLabel = NSLocalizedString("Reset text size", comment: "Accessibility label for button resetting font size in display settings of reader mode")
}

// QR Code scanner.
extension Strings {
    public static let ScanQRCodeViewTitle = NSLocalizedString("ScanQRCode.View.Title", comment: "Title for the QR code scanner view.")
    public static let ScanQRCodeInstructionsLabel = NSLocalizedString("ScanQRCode.Instructions.Label", comment: "Text for the instructions label, displayed in the QR scanner view")
    public static let ScanQRCodeInvalidDataErrorMessage = NSLocalizedString("ScanQRCode.InvalidDataError.Message", comment: "Text of the prompt that is shown to the user when the data is invalid")
    public static let ScanQRCodePermissionErrorMessage = String(format: NSLocalizedString("ScanQRCode.PermissionError.Message", comment: "Text of the prompt user to setup the camera authorization."), AppInfo.displayName)
    public static let ScanQRCodeErrorOKButton = NSLocalizedString("ScanQRCode.Error.OK.Button", comment: "OK button to dismiss the error prompt.")
}

// App menu.
extension Strings {
    public static let AppMenuShowTabsTitleString = NSLocalizedString("Menu.ShowTabs.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the tabs tray")
    public static let AppMenuSharePageTitleString = NSLocalizedString("Menu.SharePageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the share dialog.")
    public static let AppMenuNewTabTitleString = NSLocalizedString("Menu.NewTabAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open a new tab")
    public static let AppMenuNewPrivateTabTitleString = NSLocalizedString("Menu.NewPrivateTabAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open a new private tab.")
    public static let AppMenuAddBookmarkTitleString = NSLocalizedString("Menu.AddBookmarkAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to create a bookmark for the current website.")
    public static let AppMenuRemoveBookmarkTitleString = NSLocalizedString("Menu.RemoveBookmarkAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to delete an existing bookmark for the current website.")
    public static let AppMenuFindInPageTitleString = NSLocalizedString("Menu.FindInPageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the toolbar to search for text within the current page.")
    public static let AppMenuViewDesktopSiteTitleString = NSLocalizedString("Menu.ViewDekstopSiteAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the desktop version of the current website.")
    public static let AppMenuViewMobileSiteTitleString = NSLocalizedString("Menu.ViewMobileSiteAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the mobile version of the current website.")
    public static let AppMenuReaderModeTitleString = NSLocalizedString("Menu.ReaderMode.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to request the reader mode version of the current website")
    public static let AppMenuScanQRCodeTitleString = NSLocalizedString("Menu.ScanQRCodeAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the QR code scanner.")
    public static let AppMenuSettingsTitleString = NSLocalizedString("Menu.OpenSettingsAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the Settings menu.")
    public static let AppMenuWhatsNewTitleString = NSLocalizedString("Menu.OpenWhatsNewAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the What's new page.")
    public static let AppMenuReloadTitleString = NSLocalizedString("Reload", comment: "Reload")
    public static let AppMenuCloseAllTabsTitleString = NSLocalizedString("Menu.CloseAllTabsAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to close all tabs currently open.")
    public static let AppMenuOpenHomePageTitleString = NSLocalizedString("Menu.OpenHomePageAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to navigate to the home page.")
    public static let AppMenuTopSitesTitleString = NSLocalizedString("Menu.OpenTopSitesAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Top Sites home panel.")
    public static let AppMenuBookmarksTitleString = NSLocalizedString("Menu.OpenBookmarksAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Bbookmarks home panel.")
    public static let AppMenuHistoryTitleString = NSLocalizedString("Menu.OpenHistoryAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the History home panel.")
    public static let AppMenuDownloadsTitleString = NSLocalizedString("Menu.OpenDownloadsAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Downloads home panel.")
    public static let AppMenuButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.AccessibilityLabel", comment: "Accessibility label for the Menu button.")
    public static let TabTrayDeleteMenuButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.CloseAllTabs", comment: "Accessibility label for the Close All Tabs menu button.")
    public static let AppMenuCopyURLConfirmMessage = NSLocalizedString("Menu.CopyURL.Confirm", comment: "Toast displayed to user after copy url pressed.")
    public static let AppMenuAddBookmarkConfirmMessage = NSLocalizedString("Menu.AddBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been added.")
    public static let AppMenuRemoveBookmarkConfirmMessage = NSLocalizedString("Menu.RemoveBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been removed.")
    public static let SendToDeviceTitle = NSLocalizedString("Send to Device", tableName: "3DTouchActions", comment: "Label for preview action on Tab Tray Tab to send the current tab to another device")
    public static let PageActionMenuTitle = NSLocalizedString("Menu.PageActions.Title", comment: "Label for title in page action menu.")
    public static let WhatsNewString = NSLocalizedString("Menu.WhatsNew.Title", comment: "The title for the option to view the What's new page.")
    public static let AppMenuShowPageSourceString = NSLocalizedString("Menu.PageSourceAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to show the html page source")
}

// Snackbar shown when tapping app store link
extension Strings {
    public static let ExternalLinkAppStoreConfirmationTitle = NSLocalizedString("ExternalLink.AppStore.ConfirmationTitle", comment: "Question shown to user when tapping a link that opens the App Store app")
    public static let ExternalLinkGenericConfirmation = NSLocalizedString("ExternalLink.AppStore.GenericConfirmationTitle", comment: "Question shown to user when tapping an SMS or MailTo link that opens the external app for those.")
}

// ContentBlocker/TrackingProtection strings
extension Strings {
    public static let SettingsTrackingProtectionSectionName = NSLocalizedString("Settings.TrackingProtection.SectionName", comment: "Row in top-level of settings that gets tapped to show the tracking protection settings detail view.")
    public static let TrackingProtectionOptionOnInPrivateBrowsing = NSLocalizedString("Settings.TrackingProtectionOption.OnInPrivateBrowsingLabel", comment: "Settings option to specify that Tracking Protection is on only in Private Browsing mode.")
    public static let TrackingProtectionOptionOnInNormalBrowsing = NSLocalizedString("Settings.TrackingProtectionOption.OnInNormalBrowsingLabel", comment: "Settings option to specify that Tracking Protection is on only in Private Browsing mode.")
    public static let TrackingProtectionOptionOnOffHeader = NSLocalizedString("Settings.TrackingProtectionOption.EnabledStateHeaderLabel", comment: "Description label shown at the top of tracking protection options screen.")
    public static let TrackingProtectionOptionOnOffFooter = NSLocalizedString("Settings.TrackingProtectionOption.EnabledStateFooterLabel", comment: "Description label shown on tracking protection options screen.")
    public static let TrackingProtectionReloadWithout = NSLocalizedString("Menu.ReloadWithoutTrackingProtection.Title", comment: "Label for the button, displayed in the menu, used to reload the current website without Tracking Protection")
    public static let TrackingProtectionReloadWith = NSLocalizedString("Menu.ReloadWithTrackingProtection.Title", comment: "Label for the button, displayed in the menu, used to reload the current website with Tracking Protection enabled")
}

// Tracking Protection menu
extension Strings {
    public static let TPMenuTitle = NSLocalizedString("Menu.TrackingProtection.Title", value: "Tracking Protection", comment: "Label for the button, displayed in the menu, used to get more info about Tracking Protection")
    public static let ABMenuTitle = NSLocalizedString("Menu.AdBlocking.Title", value: "Ad-blocking", comment: "Label for the button, displayed in the menu, used to get more info about Ad blocking")
    public static let TPBlockingDescription =  String(format: NSLocalizedString("Menu.TrackingProtectionBlocking.Description", comment: "Description of the Tracking protection menu when TP is blocking parts of the page"), AppInfo.displayName)
    public static let TPNoBlockingDescription = NSLocalizedString("Menu.TrackingProtectionNoBlocking.Description", comment: "The description of the Tracking Protection menu item when no scripts are blocked but tracking protection is enabled.")
    public static let TPBlockingDisabledDescription = NSLocalizedString("Menu.TrackingProtectionBlockingDisabled.Description", comment: "The description of the Tracking Protection menu item when tracking is enabled")
    public static let TPBlockingMoreInfo = NSLocalizedString("Menu.TrackingProtectionMoreInfo.Description", comment: "more info about what tracking protection is about")
    public static let EnableTPBlocking = NSLocalizedString("Menu.TrackingProtectionEnable.Title", comment: "A button to enable tracking protection inside the menu.")
    public static let TrackingProtectionEnabledConfirmed = NSLocalizedString("Menu.TrackingProtectionEnabled.Title", comment: "The confirmation toast once tracking protection has been enabled")
    public static let TrackingProtectionDisabledConfirmed = NSLocalizedString("Menu.TrackingProtectionDisabled.Title", comment: "The confirmation toast once tracking protection has been disabled")
    public static let TrackingProtectionDisableTitle = NSLocalizedString("Menu.TrackingProtectionDisable.Title", comment: "The button that disabled TP for a site.")
    public static let TrackingProtectionTotalBlocked = NSLocalizedString("Menu.TrackingProtectionTotalBlocked.Title", tableName: "Menu", comment: "The title that shows the total number of scripts blocked")
    public static let TrackingProtectionAdsBlocked = NSLocalizedString("Menu.TrackingProtectionAdsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
    public static let TrackingProtectionAnalyticsBlocked = NSLocalizedString("Menu.TrackingProtectionAnalyticsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
    public static let TrackingProtectionSocialBlocked = NSLocalizedString("Menu.TrackingProtectionSocialBlocked.Title", tableName: "Menu", comment: "The title that shows the number of social scripts blocked")
    public static let TrackingProtectionContentBlocked = NSLocalizedString("Menu.TrackingProtectionContentBlocked.Title", tableName: "Menu", comment: "The title that shows the number of content scripts blocked")
    public static let TrackingProtectionWhiteListOn = NSLocalizedString("Menu.TrackingProtectionOption.WhiteListOnDescription", comment: "label for the menu item to show when the website is whitelisted from blocking trackers.")
    public static let TrackingProtectionWhiteListRemove = NSLocalizedString("Menu.TrackingProtectionWhitelistRemove.Title", comment: "label for the menu item that lets you remove a website from the tracking protection whitelist")
    public static let TrackingProtectionEssentialBlocked = NSLocalizedString("Menu.TrackingProtectionEssentialBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionMiscBlocked = NSLocalizedString("Menu.TrackingProtectionEssentialMisc.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionHostingBlocked = NSLocalizedString("Menu.TrackingProtectionHostingBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionPornvertisingBlocked = NSLocalizedString("Menu.TrackingProtectionPornvertisingBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionAudioVideoPlayerBlocked = NSLocalizedString("Menu.TrackingProtectionAVPLayerBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionExtensionsBlocked = NSLocalizedString("Menu.TrackingProtectionExtensionsBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionCustomerInteractionBlocked = NSLocalizedString("Menu.TrackingProtectionCustomerInteractionBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionCommentsBlocked = NSLocalizedString("Menu.TrackingProtectionCommentsBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectionCDNBlocked = NSLocalizedString("Menu.TrackingProtectionCDNBlocked.Title", tableName: "Menu", comment: "")
    public static let TrackingProtectioUnknownBlocked = NSLocalizedString("Menu.TrackingProtectionUnknownBlocked.Title", tableName: "Menu", comment: "")
}

// Location bar long press menu
extension Strings {
    public static let PasteAndGoTitle = NSLocalizedString("Menu.PasteAndGo.Title", comment: "The title for the button that lets you paste and go to a URL")
    public static let PasteTitle = NSLocalizedString("Menu.Paste.Title", comment: "The title for the button that lets you paste into the location bar")
    public static let CopyAddressTitle = NSLocalizedString("Menu.Copy.Title", comment: "The title for the button that lets you copy the url from the location bar.")
}

// Settings Home
extension Strings {
    public static let SendUsageSettingTitle = NSLocalizedString("Settings.SendUsage.Title", comment: "The title for the setting to send usage data.")
    public static let SendUsageSettingMessage = String(format: NSLocalizedString("Settings.SendUsage.Message", comment: "A short description that explains why mozilla collects usage data."), AppInfo.displayName, AppInfo.displayName)
    public static let SettingsSiriSectionName = NSLocalizedString("Settings.Siri.SectionName", comment: "The option that takes you to the siri shortcuts settings page")
    public static let SettingsSiriSectionDescription = String(format: NSLocalizedString("Settings.Siri.SectionDescription", comment: "The description that describes what siri shortcuts are"), AppInfo.displayName)
    public static let SettingsSiriOpenURL = NSLocalizedString("Settings.Siri.OpenTabShortcut", comment: "The description of the open new tab siri shortcut")
}

// Do not track
extension Strings {
    public static let SettingsDoNotTrackTitle = NSLocalizedString("Settings.DNT.Title", comment: "DNT Settings title")
    public static let SettingsDoNotTrackOptionOnWithTP = NSLocalizedString("Settings.DNT.OptionOnWithTP", comment: "DNT Settings option for only turning on when Tracking Protection is also on")
    public static let SettingsDoNotTrackOptionAlwaysOn = NSLocalizedString("Settings.DNT.OptionAlwaysOn", comment: "DNT Settings option for always on")
}

// Intro Onboarding slides
extension Strings {
    public static let SearchCardTitle = NSLocalizedString("Intro.Slides.Search.Title", tableName: "Intro", comment: "Title for the 'Search' panel in the First Run tour.")
    public static let SearchCardDescription = NSLocalizedString("Intro.Slides.Search.Description", tableName: "Intro", comment: "Description for the 'Search' panel in the First Run tour.")
    public static let AntiTrackingCardTitle = NSLocalizedString("Intro.Slides.AntiTracking.Title", tableName: "Intro", comment: "Title for the 'AntiTracking' panel in the First Run tour.")
    public static let AntiTrackingCardDescription = NSLocalizedString("Intro.Slides.AntiTracking.Description", tableName: "Intro", comment: "Description for the 'AntiTracking' panel in the First Run tour.")
    public static let WelcomeCardDescription = NSLocalizedString("Intro.Slides.Welcome.Description", tableName: "Intro", comment: "Description for the 'Welcome' panel in the First Run tour.")
    public static let WelcomeCardButtonTitle = NSLocalizedString("Intro.Slides.Welcome.Button.Title", tableName: "Intro", comment: "Button title for starting browsing.")
    public static let CardSkipButtonTitle = NSLocalizedString("Intro.Slides.Skip.Title", tableName: "Intro", comment: "Button title for skipping tour.")
}

// Keyboard short cuts
extension Strings {
    public static let ShowTabTrayFromTabKeyCodeTitle = NSLocalizedString("Tab.ShowTabTray.KeyCodeTitle", comment: "Hardware shortcut to open the tab tray from a tab. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let CloseTabFromTabTrayKeyCodeTitle = NSLocalizedString("TabTray.CloseTab.KeyCodeTitle", comment: "Hardware shortcut to close the selected tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let CloseAllTabsFromTabTrayKeyCodeTitle = NSLocalizedString("TabTray.CloseAllTabs.KeyCodeTitle", comment: "Hardware shortcut to close all tabs from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let OpenSelectedTabFromTabTrayKeyCodeTitle = NSLocalizedString("TabTray.OpenSelectedTab.KeyCodeTitle", comment: "Hardware shortcut open the selected tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let OpenNewTabFromTabTrayKeyCodeTitle = NSLocalizedString("TabTray.OpenNewTab.KeyCodeTitle", comment: "Hardware shortcut to open a new tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let ReopenClosedTabKeyCodeTitle = NSLocalizedString("ReopenClosedTab.KeyCodeTitle", comment: "Hardware shortcut to reopen the last closed tab, from the tab or the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let SwitchToPBMKeyCodeTitle = NSLocalizedString("SwitchToPBM.KeyCodeTitle", comment: "Hardware shortcut switch to the private browsing tab or tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    public static let SwitchToNonPBMKeyCodeTitle = NSLocalizedString("SwitchToNonPBM.KeyCodeTitle", comment: "Hardware shortcut for non-private tab or tab. Shown in the Discoverability overlay when the hardware Command Key is held down.")
}

// Share extension
extension Strings {
    public static let SendToCancelButton = NSLocalizedString("SendTo.Cancel.Button", bundle: applicationBundle(), comment: "Button title for cancelling share screen")
    public static let SendToErrorOKButton = NSLocalizedString("SendTo.Error.OK.Button", bundle: applicationBundle(), comment: "OK button to dismiss the error prompt.")
    public static let SendToErrorTitle = NSLocalizedString("SendTo.Error.Title", bundle: applicationBundle(), comment: "Title of error prompt displayed when an invalid URL is shared.")
    public static let SendToErrorMessage = NSLocalizedString("SendTo.Error.Message", bundle: applicationBundle(), comment: "Message in error prompt explaining why the URL is invalid.")
    public static let SendToCloseButton = NSLocalizedString("SendTo.Cancel.Button", bundle: applicationBundle(), comment: "Close button in top navigation bar")
    public static let SendToNotSignedInText = NSLocalizedString("SendTo.NotSignedIn.Title", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
    public static let SendToNotSignedInMessage = NSLocalizedString("SendTo.NotSignedIn.Message", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
    public static let SendToNoDevicesFound = NSLocalizedString("SendTo.NoDevicesFound.Message", bundle: applicationBundle(), comment: "Error message shown in the remote tabs panel")
    public static let SendToTitle = NSLocalizedString("SendTo.NavBar.Title", bundle: applicationBundle(), comment: "Title of the dialog that allows you to send a tab to a different device")
    public static let SendToSendButtonTitle = NSLocalizedString("SendTo.SendAction.Text", bundle: applicationBundle(), comment: "Navigation bar button to Send the current page to a device")
    public static let SendToDevicesListTitle = NSLocalizedString("SendTo.DeviceList.Text", bundle: applicationBundle(), comment: "Header for the list of devices table")
    public static let ShareSendToDevice = Strings.SendToDeviceTitle

    // The above items are re-used strings from the old extension. New strings below.

    public static let ShareBookmarkThisPage = NSLocalizedString("ShareExtension.BookmarkThisPageAction.Title", tableName: "ShareTo", comment: "Action label on share extension to bookmark the page in Firefox.")
    public static let ShareBookmarkThisPageDone = NSLocalizedString("ShareExtension.BookmarkThisPageActionDone.Title", comment: "Share extension label shown after user has performed 'Bookmark this Page' action.")

    public static var ShareOpenIn = String(
        format: NSLocalizedString("ShareExtension.OpenInAction.Title", tableName: "ShareTo", comment: "Action label on share extension to immediately open page in \(AppInfo.displayName)."),
        AppInfo.displayName
    )
    public static let ShareSearchIn = String(format: NSLocalizedString("ShareExtension.SeachInUserAgentAction.Title", tableName: "ShareTo", comment: "Action label on share extension to search for the selected text in Firefox."), AppInfo.displayName)

    public static let ShareLoadInBackground = NSLocalizedString("ShareExtension.LoadInBackgroundAction.Title", tableName: "ShareTo", comment: "Action label on share extension to load the page in Firefox when user switches apps to bring it to foreground.")

    public static let ShareLoadInBackgroundDone = String(format: NSLocalizedString("ShareExtension.LoadInBackgroundActionDone.Title", tableName: "ShareTo", comment: "Share extension label shown after user has performed 'Load in Background' action."), AppInfo.displayName)

}

//passwordAutofill extension
extension Strings {
    public static let PasswordAutofillTitle = String(format: NSLocalizedString("PasswordAutoFill.SectionTitle", comment: "Title of the extension that shows firefox passwords"), AppInfo.displayName)
    public static let CredentialProviderNoCredentialError = String(format: NSLocalizedString("PasswordAutoFill.NoPasswordsFoundTitle", comment: "Error message shown in the remote tabs panel"), AppInfo.displayName)
    public static let AvailableCredentialsHeader = NSLocalizedString("PasswordAutoFill.PasswordsListTitle", comment: "Header for the list of credentials table")
}

// translation bar
extension Strings {
    public static let SettingTranslateSnackBarSectionHeader = NSLocalizedString("Settings.TranslateSnackBar.SectionHeader", comment: "Translation settings section title")
    public static let SettingTranslateSnackBarSectionFooter = NSLocalizedString("Settings.TranslateSnackBar.SectionFooter", comment: "Translation settings footer describing how language detection and translation happens.")
    public static let SettingTranslateSnackBarTitle = NSLocalizedString("Settings.TranslateSnackBar.Title", comment: "Title in main app settings for Translation toast settings")
    public static let SettingTranslateSnackBarSwitchTitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchTitle", comment: "Switch to choose if the language of a page is detected and offer to translate.")
    public static let SettingTranslateSnackBarSwitchSubtitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchSubtitle", comment: "Switch to choose if the language of a page is detected and offer to translate.")
}

// InterceptorUI
extension Strings {
    public static let InterceptorUIAntiPhishingTitle = NSLocalizedString("Interceptor.AntiPhishing.UI.Title", tableName: "UserAgent", comment: "Antiphishing alert title")
    public static let InterceptorUIAntiPhishingMessage = String(format: NSLocalizedString("Interceptor.AntiPhishing.UI.Message", tableName: "UserAgent", comment: "Antiphishing alert message"), AppInfo.displayName, "%@")
    public static let InterceptorUIAntiPhishingBack = NSLocalizedString("Interceptor.AntiPhishing.UI.BackButtonLabel", tableName: "UserAgent", comment: "Back to safe site buttun title in antiphishing alert title")
    public static let InterceptorUIAntiPhishingContinue = NSLocalizedString("Interceptor.AntiPhishing.UI.ContinueButtonLabel", tableName: "UserAgent", comment: "Continue despite warning buttun title in antiphishing alert title")
}

// Privacy Dashboard
extension Strings {
    public struct PrivacyDashboard {
        public struct Title {
            public static let BlockingEnabled = NSLocalizedString("PrivacyDashboard.Title.BlockingEnabled", tableName: "UserAgent", comment: "")
            public static let NoTrackersSeen = NSLocalizedString("PrivacyDashboard.Title.NoTrackersSeen", tableName: "UserAgent", comment: "")
            public static let AdBlockWhitelisted = NSLocalizedString("PrivacyDashboard.Title.AdBlockWhitelisted", tableName: "UserAgent", comment: "")
            public static let AntiTrackingWhitelisted = NSLocalizedString("PrivacyDashboard.Title.AntiTrackingWhitelisted", tableName: "UserAgent", comment: "")
            public static let Whitelisted = NSLocalizedString("PrivacyDashboard.Title.Whitelisted", tableName: "UserAgent", comment: "")
        }

        public struct Legend {
            public static let NoTrackersSeen = NSLocalizedString("PrivacyDashboard.Legend.NoTrackersSeen", tableName: "UserAgent", comment: "")
            public static let Whitelisted = NSLocalizedString("PrivacyDashboard.Legend.Whitelisted", tableName: "UserAgent", comment: "")
        }

        public static let ViewFullReport = NSLocalizedString("PrivacyDashboard.ViewFullReport", tableName: "UserAgent", comment: "")

        public struct Switch {
             public static let AntiTracking = NSLocalizedString("PrivacyDashboard.Switch.AntiTracking", tableName: "UserAgent", comment: "")
            public static let AdBlock = NSLocalizedString("PrivacyDashboard.Switch.AdBlock", tableName: "UserAgent", comment: "")
        }
    }
}
