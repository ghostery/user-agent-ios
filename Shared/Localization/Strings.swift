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
    // MARK: - General
    public struct General {
        public static let OKString = NSLocalizedString("OK", comment: "OK button")
        public static let CancelString = NSLocalizedString("Cancel", comment: "Label for Cancel button")
        public static let OpenSettingsString = NSLocalizedString("Open Settings", comment: "See http://mzl.la/1G7uHo7")
        public static let CloseString = NSLocalizedString("Close", comment: "Label for Close button")
        public static let DoneString = NSLocalizedString("Done", comment: "Label for Done button")
        public static let SendString = NSLocalizedString("Send", comment: "Label for Send button")
    }

    // MARK: - Table date section titles
    public struct TableDateSection {
        public static let TitleToday = NSLocalizedString("Today", comment: "History tableview section header")
        public static let TitleYesterday = NSLocalizedString("Yesterday", comment: "History tableview section header")
        public static let TitleLastWeek = NSLocalizedString("Last week", comment: "History tableview section header")
        public static let TitleLastMonth = NSLocalizedString("Last month", comment: "History tableview section header")
    }

    // MARK: - Top Sites
    public struct TopSites {
        public static let RemoveButtonAccessibilityLabel = NSLocalizedString("TopSites.RemovePage.Button", comment: "Button shown in editing mode to remove this site from the top sites panel.")
    }

    // MARK: - Refresh Control
    public struct RefreshControl {
        public static let ReloadLabel = NSLocalizedString("RefreshControl.Reload", comment: "Refresh title for Refresh Control.")
    }

    // MARK: - Activity Stream.
    public struct ActivityStream {
        public struct News {
            public static let BreakingLabel = NSLocalizedString("ActivityStream.News.BreakingLabel", comment: "")
            public static let Header = NSLocalizedString("ActivityStream.News.Header", comment: "News section header")
        }
        public struct TopSites {
            public static let Title =  NSLocalizedString("ActivityStream.TopSites.SectionTitle", comment: "Section title label for Top Sites")
            public static let RowSettingFooter = NSLocalizedString("ActivityStream.TopSites.RowSettingFooter", comment: "The title for the setting page which lets you select the number of top site rows")
            public static let RowCount = NSLocalizedString("ActivityStream.TopSites.RowCount", comment: "label showing how many rows of topsites are shown. %d represents a number")
        }
        public struct ContextMenu {
            public static let PinTopsite = NSLocalizedString("ActivityStream.ContextMenu.PinTopsite", comment: "The title for the pinning a topsite action")
            public static let RemovePinTopsite = NSLocalizedString("ActivityStream.ContextMenu.RemovePinTopsite", comment: "The title for removing a pinned topsite action")
        }
        public static let PinnedSitesTitle =  NSLocalizedString("ActivityStream.PinnedSites.SectionTitle", comment: "Section title label for Pinned Sites")
        public static let HighlightVistedText = NSLocalizedString("ActivityStream.Highlights.Visited", comment: "The description of a highlight if it is a site the user has visited")
        public static let HighlightBookmarkText = NSLocalizedString("ActivityStream.Highlights.Bookmark", comment: "The description of a highlight if it is a site the user has bookmarked")
        public static let RecentlyBookmarkedTitle = NSLocalizedString("ActivityStream.NewRecentBookmarks.Title", comment: "Section title label for recently bookmarked websites")
        public static let RecentlyVisitedTitle = NSLocalizedString("ActivityStream.RecentHistory.Title", comment: "Section title label for recently visited websites")
    }

    // MARK: - Home Panel Context Menu
    public struct HomePanel {
        public struct ContextMenu {
            public static let OpenInNewTab = NSLocalizedString("HomePanel.ContextMenu.OpenInNewTab", comment: "The title for the Open in New Tab context menu action for sites in Home Panels")
            public static let OpenInNewPrivateTab = NSLocalizedString("HomePanel.ContextMenu.OpenInNewPrivateTab", comment: "The title for the Open in New Private Tab context menu action for sites in Home Panels")
            public static let Bookmark = NSLocalizedString("HomePanel.ContextMenu.Bookmark", comment: "The title for the Bookmark context menu action for sites in Home Panels")
            public static let RemoveBookmark = NSLocalizedString("HomePanel.ContextMenu.RemoveBookmark", comment: "The title for the Remove Bookmark context menu action for sites in Home Panels")
            public static let DeleteFromHistory = NSLocalizedString("HomePanel.ContextMenu.DeleteFromHistory", comment: "The title for the Delete from History context menu action for sites in Home Panels")
            public static let DeleteAllTraces = NSLocalizedString("HomePanel.ContextMenu.DeleteAllTraces", comment: "The title for the Delete all traces context menu action for sites in Home Panels")
            public static let Share = NSLocalizedString("HomePanel.ContextMenu.Share", comment: "The title for the Share context menu action for sites in Home Panels")
            public static let Remove = NSLocalizedString("HomePanel.ContextMenu.Remove", comment: "The title for the Remove context menu action for sites in Home Panels")
        }
        public struct ReopenAlert {
            public static let Title = NSLocalizedString("ReopenAlert.Title", comment: "Reopen alert title shown at home page.")
            public static let ActionsReopen = NSLocalizedString("ReopenAlert.Actions.Reopen", comment: "Reopen button text shown in reopen-alert at home page.")
            public static let ActionsCancel = NSLocalizedString("ReopenAlert.Actions.Cancel", comment: "Cancel button text shown in reopen-alert at home page.")
        }
    }

    // MARK: - PhotonActionSheet Strings
    public struct PhotonMenu {
        public static let Close = NSLocalizedString("PhotonMenu.close", comment: "Button for closing the menu action sheet")
    }

    // MARK: - Home View
    public struct HomeView {
        public struct SegmentedControl {
            public static let TopSitesTitle = NSLocalizedString("HomeView.SegmentedControl.TopSites.Title", tableName: "UserAgent", comment: "")
            public static let BookmarksTitle = NSLocalizedString("HomeView.SegmentedControl.Bookmarks.Title", tableName: "UserAgent", comment: "")
            public static let HistoryTitle = NSLocalizedString("HomeView.SegmentedControl.History.Title", tableName: "UserAgent", comment: "")
            public static let DownloadsTitle = NSLocalizedString("HomeView.SegmentedControl.Downloads.Title", tableName: "UserAgent", comment: "")
        }
        public static let emptyBookmarksText = NSLocalizedString("Bookmarks you save will show up here.", comment: "Status label for the empty Bookmarks state.")
        public static let deleteBookmark = NSLocalizedString("Delete", tableName: "HistoryPanel", comment: "Action button for deleting history entries in the history panel.")
    }

    // MARK: - Settings
    public struct Settings {
        public struct PrivacyDashboard {
            public static let Title = NSLocalizedString("Settings.PrivacyDashboard.Title", comment: "Privacy Dashboard Title")
            public static let Description = NSLocalizedString("Settings.PrivacyDashboard.Description", comment: "Privacy Dashboard Description")
        }
        public struct General {
            public static let SectionTitle = NSLocalizedString("Settings.General.SectionName", comment: "General settings section title")
        }
        public struct News {
            public struct Language {
                public static let Title = NSLocalizedString("Settings.News.Language", comment: "The button text in Settings that opens the list of supported news languages.")
                public static let German = NSLocalizedString("region-DE", comment: "Localized String for German region")
            }
            public static let SectionTitle = NSLocalizedString("Settings.News.SectionName", comment: "News settings section title")
            public static let NewsFromNewTabPage = NSLocalizedString("Settings.News.NewsFromNewTabPage", comment: "Disable news from new tab page")
            public static let NewsImages = NSLocalizedString("Settings.News.NewsImages", comment: "Disable load of news images")
        }
        public struct ClearPrivateData {
            public static let Title = NSLocalizedString("Settings.ClearPrivateData.Title", comment: "Title displayed in header of the setting panel.")
            public static let ClearButton = NSLocalizedString("Settings.ClearPrivateData.Clear.Button", comment: "Button in settings that clears private data for the selected items.")
            public static let ClearAllWebsiteDataButton = NSLocalizedString("Settings.ClearAllWebsiteData.Clear.Button", comment: "Button in Data Management that clears private data for the selected items.")
            public static let SectionName = NSLocalizedString("Settings.ClearPrivateData.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
        }
        public struct DataManagement {
            public static let SectionName = NSLocalizedString("Settings.DataManagement.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
            public static let SearchLabel = NSLocalizedString("Settings.DataManagement.SearchLabel", comment: "Default text in search bar for Data Management")
            public static let Title = NSLocalizedString("Settings.DataManagement.Title", comment: "Title displayed in header of the setting panel.")
            public struct PrivateData {
                public static let PrivacyStats = NSLocalizedString("Settings.DataManagement.PrivateData.PrivacyStats", tableName: "ClearPrivateData", comment: "Settings item for clearing privacy stats")
                public static let TrackingProtection = NSLocalizedString("Settings.DataManagement.PrivateData.TrackingProtection", tableName: "ClearPrivateData", comment: "Settings item for clearing tracking protection")
                public static let DownloadedFiles = NSLocalizedString("Settings.DataManagement.PrivateData.DownloadedFiles", tableName: "ClearPrivateData", comment: "Settings item for deleting downloaded files")
                public static let Cookies = NSLocalizedString("Settings.DataManagement.PrivateData.Cookies", tableName: "ClearPrivateData", comment: "Settings item for clearing cookies")
                public static let OfflineWebsiteData = NSLocalizedString("Settings.DataManagement.PrivateData.OfflineWebsiteData", tableName: "ClearPrivateData", comment: "Settings item for clearing website data")
                public static let Cache = NSLocalizedString("Settings.DataManagement.PrivateData.Cache", tableName: "ClearPrivateData", comment: "Settings item for clearing the cache")
                public static let BrowsingHistory = NSLocalizedString("Settings.DataManagement.PrivateData.BrowsingHistory", tableName: "ClearPrivateData", comment: "Settings item for clearing browsing history")
                public static let BrowsingStorage = NSLocalizedString("Settings.DataManagement.PrivateData.BrowsingStorage", tableName: "ClearPrivateData", comment: "Settings item for clearing browsing storage")
                public static let AllTabs = NSLocalizedString("Settings.DataManagement.PrivateData.AllTabs", tableName: "ClearPrivateData", comment: "Settings item for closing all tabs")
                public static let Bookmarks = NSLocalizedString("Settings.DataManagement.PrivateData.Bookmarks", tableName: "ClearPrivateData", comment: "Settings item for clear all bookmarks")
                public static let TopAndPinnedSites = NSLocalizedString("Settings.DataManagement.PrivateData.TopSites", tableName: "ClearPrivateData", comment: "Settings item for clear all TopSites")
                public static let SearchHistory = NSLocalizedString("Settings.DataManagement.PrivateData.SearchHistory", tableName: "ClearPrivateData", comment: "Settings item for removing search history")
            }
        }
        public struct TodayWidget {
            public static let SectionName = NSLocalizedString("Settings.TodayWidget.SectionName", comment: "Label used as an item in Settings.")
            public static let Title = NSLocalizedString("Settings.TodayWidget.Title", comment: "Title displayed in header of the setting panel.")
            public static let SearchLabel = NSLocalizedString("Settings.TodayWidget.SearchLabel", comment: "Default text in search bar for Today Widget Setting")
        }
        public struct WebsiteData {
            public static let Title = NSLocalizedString("Settings.WebsiteData.Title", comment: "Title displayed in header of the Data Management panel.")
            public static let ShowMoreButton = NSLocalizedString("Settings.WebsiteData.ButtonShowMore", comment: "Button shows all websites on website data tableview")
            public static let ClearWebsiteDataMessage = NSLocalizedString("Settings.WebsiteData.ConfirmPrompt", comment: "Description of the confirmation dialog shown when a user tries to clear their private data.")
            public static let EditWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonEdit", comment: "Button to edit website search results")
            public static let DeleteWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonDelete", comment: "Button to delete website in search results")
            public static let DoneWebsiteSearchButton = NSLocalizedString("Settings.WebsiteData.ButtonDone", comment: "Button to exit edit website search results")
        }
        public struct Search {
            public static let SectionTitle = NSLocalizedString("Settings.Search.SectionName", comment: "Search settings section title")
            public static let DoneButton = NSLocalizedString("Settings.Search.Done.Button", comment: "Button displayed at the top of the search settings.")
            public static let EditButton = NSLocalizedString("Settings.Search.Edit.Button", comment: "Button displayed at the top of the search settings.")
        }
        public struct AdditionalSearchEngines {
            public static let SectionTitle = NSLocalizedString("Settings.AdditionalSearchEngines.SectionName", comment: "The button text in Search Settings that opens the Additional Search Engines view.")
        }
        public struct AddCustomEngine {
            public static let ButtonTitle = NSLocalizedString("Settings.AddCustomEngine", comment: "The button text in Search Settings that opens the Custom Search Engine view.")
            public static let Title = NSLocalizedString("Settings.AddCustomEngine.Title", comment: "The title of the Custom Search Engine view.")
            public static let TitleFieldSectionTitle = NSLocalizedString("Settings.AddCustomEngine.TitleLabel", comment: "The title for the field which sets the title for a custom search engine.")
            public static let URLSectionTitle = NSLocalizedString("Settings.AddCustomEngine.URLLabel", comment: "The title for URL Field")
            public static let TitlePlaceholder = NSLocalizedString("Settings.AddCustomEngine.TitlePlaceholder", comment: "The placeholder for Title Field when saving a custom search engine.")
            public static let URLPlaceholder = NSLocalizedString("Settings.AddCustomEngine.URLPlaceholder", comment: "The placeholder for URL Field when saving a custom search engine")
            public static let SaveButtonText = NSLocalizedString("Settings.AddCustomEngine.SaveButtonText", comment: "The text on the Save button when saving a custom search engine")
        }
        public struct SearchResultForLanguage {
            public static let Title = NSLocalizedString("Settings.SearchResultForLanguage", comment: "The button text in Settings that opens the list of supported search languages.")
            public static let German = NSLocalizedString("region-DE", comment: "Localized String for German region")
        }
        public struct NewTab {
            public static let TopSites = String(format: NSLocalizedString("Settings.NewTab.Option.Home", comment: "Option in settings to show Firefox Home when you open a new tab"), AppInfo.displayName)
        }
        public struct OnBrowserStartTab {
            public static let SectionName = NSLocalizedString("Settings.OnBrowserStartTab.SectionName", comment: "The option in settings to configure first launch tab")
            public static let LastOpenedTab = NSLocalizedString("Settings.OnBrowserStartTab.LastOpenedTab", comment: "The option in settings to configure first launch to open last opened tab")
            public static let NewTab = NSLocalizedString("Settings.OnBrowserStartTab.NewTab", comment: "The option in settings to configure first launch to open new tab")
        }
        public struct RefreshControl {
            public static let SectionName = NSLocalizedString("Settings.RefreshControl.SectionName", comment: "The option in settings to enable/disable Refresh Control.")
        }
        public struct OpenWith {
            public static let SectionName = NSLocalizedString("Settings.OpenWith.SectionName", comment: "Label used as an item in Settings. When touched it will open a dialog to configure the open with (mail links) behaviour.")
            public static let PageTitle = NSLocalizedString("Settings.OpenWith.PageTitle", comment: "Title for Open With Settings")
        }
        public struct TrackingProtection {
            public static let SectionName = NSLocalizedString("Settings.TrackingProtection.SectionName", comment: "Row in top-level of settings that gets tapped to show the tracking protection settings detail view.")
        }
        public struct SendUsage {
            public static let Title = NSLocalizedString("Settings.SendUsage.Title", comment: "The title for the setting to send usage data.")
            public static let Message = String(format: NSLocalizedString("Settings.SendUsage.Message", comment: "A short description that explains why mozilla collects usage data."), AppInfo.displayName, AppInfo.displayName)
        }
        public struct Siri {
            public static let SectionName = NSLocalizedString("Settings.Siri.SectionName", comment: "The option that takes you to the siri shortcuts settings page")
            public static let SectionDescription = String(format: NSLocalizedString("Settings.Siri.SectionDescription", comment: "The description that describes what siri shortcuts are"), AppInfo.displayName)
            public static let OpenURL = NSLocalizedString("Settings.Siri.OpenTabShortcut", comment: "The description of the open new tab siri shortcut")
            public static let SearchWith = NSLocalizedString("Settings.Siri.SearchWith", comment: "The description of the search with siri shortcut")
        }
        public struct NewTabPageDefaultView {
            public static let SectionName = NSLocalizedString("Settings.NewTabPageDefaultView.SectionName", comment: "The option in settings to configure default selected view in new tab")
        }
        public struct DNT {
            public static let NotTrackTitle = NSLocalizedString("Settings.DNT.Title", comment: "DNT Settings title")
            public static let OptionOnWithTP = NSLocalizedString("Settings.DNT.OptionOnWithTP", comment: "DNT Settings option for only turning on when Tracking Protection is also on")
            public static let OptionAlwaysOn = NSLocalizedString("Settings.DNT.OptionAlwaysOn", comment: "DNT Settings option for always on")
        }
        public struct TranslateSnackBar {
            public static let SectionHeader = NSLocalizedString("Settings.TranslateSnackBar.SectionHeader", comment: "Translation settings section title")
            public static let SectionFooter = NSLocalizedString("Settings.TranslateSnackBar.SectionFooter", comment: "Translation settings footer describing how language detection and translation happens.")
            public static let Title = NSLocalizedString("Settings.TranslateSnackBar.Title", comment: "Title in main app settings for Translation toast settings")
            public static let SwitchTitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchTitle", comment: "Switch to choose if the language of a page is detected and offer to translate.")
            public static let SwitchSubtitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchSubtitle", comment: "Switch to choose if the language of a page is detected and offer to translate.")
        }
        public static let CopyAppVersionAlertTitle = NSLocalizedString("Settings.CopyAppVersion.Title", comment: "Copy app version alert shown in settings.")
        public static let AdultFilterMode = NSLocalizedString("Settings.AdultFilterMode", comment: "Block explicit content")
        public static let HumanWebTitle = NSLocalizedString("Settings.HumanWeb.Title", comment: "The title for the human web setting")
        public static let FAQAndSupport = NSLocalizedString("FAQ & Support", comment: "Menu item in settings used to open https://cliqz.com/support")
    }

    // MARK: - Error Pages
    public struct ErrorPages {
        public static let AdvancedButton = NSLocalizedString("ErrorPages.Advanced.Button", comment: "Label for button to perform advanced actions on the error page")
        public static let AdvancedWarning1 = NSLocalizedString("ErrorPages.AdvancedWarning1.Text", comment: "Warning text when clicking the Advanced button on error pages")
        public static let AdvancedWarning2 = NSLocalizedString("ErrorPages.AdvancedWarning2.Text", comment: "Additional warning text when clicking the Advanced button on error pages")
        public static let CertWarningDescription = NSLocalizedString("ErrorPages.CertWarning.Description", comment: "Warning text on the certificate error page. First argument 'Error Domain', Second - 'App name'")
        public static let CertWarningTitle = NSLocalizedString("ErrorPages.CertWarning.Title", comment: "Title on the certificate error page")
        public static let GoBackButton = NSLocalizedString("ErrorPages.GoBack.Button", comment: "Label for button to go back from the error page")
        public static let VisitOnceButton = NSLocalizedString("ErrorPages.VisitOnce.Button", comment: "Button label to temporarily continue to the site from the certificate error page")
    }

    // MARK: - Downloads Panel
    public struct DownloadsPanel {
        public static let EmptyStateTitle = NSLocalizedString("DownloadsPanel.EmptyState.Title", comment: "Title for the Downloads Panel empty state.")
        public static let DeleteTitle = NSLocalizedString("Delete", comment: "Action button for deleting downloaded files in the Downloads panel.")
        public static let ShareTitle = NSLocalizedString("Share", comment: "Action button for sharing downloaded files in the Downloads panel.")
        public static let DoneTitle = NSLocalizedString("Done", comment: "Done button on right side of the Downloads view controller title bar")
    }

    // MARK: - History Panel
    public struct HistoryPanel {
        public struct ClearHistoryMenu {
            public static let Title = NSLocalizedString("HistoryPanel.ClearHistoryMenuTitle", comment: "Title for popup action menu to clear recent history.")
            public static let OptionTheLastHour = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionTheLastHour", comment: "Button to perform action to clear history for the last hour")
            public static let OptionToday = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionToday", comment: "Button to perform action to clear history for today only")
            public static let OptionTodayAndYesterday = NSLocalizedString("HistoryPanel.ClearHistoryMenuOptionTodayAndYesterday", comment: "Button to perform action to clear history for yesterday and today")
        }
        public static let BackButtonTitle = NSLocalizedString("HistoryPanel.HistoryBackButton.Title", comment: "Title for the Back to History button in the History Panel")
        public static let EmptyStateTitle = NSLocalizedString("HistoryPanel.EmptyState.Title", comment: "Title for the History Panel empty state.")
        public static let ClearHistoryButtonTitle = NSLocalizedString("HistoryPanel.ClearHistoryButtonTitle", comment: "Title for button in the history panel to clear recent history")
        public static let RecentlyClosedTabsButtonTitle = NSLocalizedString("HistoryPanel.RecentlyClosedTabsButton.Title", comment: "Title for the Recently Closed button in the History Panel")
        public static let RecentlyClosedTabsPanelTitle = NSLocalizedString("RecentlyClosedTabsPanel.Title", comment: "Title for the Recently Closed Tabs Panel")
        public static let BrowserHomePage = String(format: NSLocalizedString("UserAgent.HomePage.Title", comment: "Title for firefox about:home page in tab history list"), AppInfo.displayName)
        public static let DeleteTitle = NSLocalizedString("Delete", tableName: "HistoryPanel", comment: "Action button for deleting history entries in the history panel.")
    }

    // MARK: - Hotkeys
    public struct Hotkeys {
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

    // MARK: - Bookmark Management
    public struct Bookmarks {
        public static let Title = NSLocalizedString("Bookmarks.Title.Label", comment: "The label for the title of a bookmark")
        public static let PanelEmptyStateTitle = NSLocalizedString("BookmarksPanel.EmptyState.Title", comment: "Status label for the empty Bookmarks state.")
        public static let BookmarksEditBookmark = NSLocalizedString("Bookmarks.EditBookmark.Label", comment: "The label to edit a bookmark")
        public static let BookmarkDetailFieldTitle = NSLocalizedString("Bookmark.DetailFieldTitle.Label", comment: "The label for the Title field when editing a bookmark")
        public static let BookmarkDetailFieldURL = NSLocalizedString("Bookmark.DetailFieldURL.Label", comment: "The label for the URL field when editing a bookmark")
    }

    // MARK: - Tabs
    public struct Toast {
        public static let DeleteAllUndoTitle = NSLocalizedString("Tabs.DeleteAllUndo.Title", comment: "The label indicating that all the tabs were closed")
        public static let DeleteAllUndoAction = NSLocalizedString("Tabs.DeleteAllUndo.Button", comment: "The button to undo the delete all tabs")
        public static let GoToCopiedLink = NSLocalizedString("ClipboardToast.GoToCopiedLink.Title", comment: "Message displayed when the user has a copied link on the clipboard")
        public static let GoButtonTittle = NSLocalizedString("ClipboardToast.GoToCopiedLink.Button", comment: "The button to open a new tab with the copied link")
        public static let SettingsOfferClipboardBarTitle = NSLocalizedString("Settings.OfferClipboardBar.Title", comment: "Title of setting to enable the Go to Copied URL feature. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349")
        public static let SettingsOfferClipboardBarStatus = String(format: NSLocalizedString("Settings.OfferClipboardBar.Status", comment: "Description displayed under the ”Offer to Open Copied Link” option. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349"), AppInfo.displayName)
        public static let NotNowString = NSLocalizedString("Toasts.NotNow", comment: "label for Not Now button")
        public static let AppStoreString = NSLocalizedString("Toasts.OpenAppStore", comment: "Open App Store button")
    }

    // MARK: - Errors
    public struct Errors {
        public struct Downloads {
            public static let Message = String(format: NSLocalizedString("Downloads.Error.Message", comment: "The message displayed to a user when they try and perform the download of an asset that Firefox cannot currently handle."), AppInfo.displayName)
        }
        public struct AddPass {
            public static let Title = NSLocalizedString("AddPass.Error.Title", comment: "Title of the 'Add Pass Failed' alert. See https://support.apple.com/HT204003 for context on Wallet.")
            public static let Message = NSLocalizedString("AddPass.Error.Message", comment: "Text of the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
            public static let Dismiss = NSLocalizedString("AddPass.Error.Dismiss", comment: "Button to dismiss the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
        }
        public struct OpenURL {
            public static let Title = NSLocalizedString("OpenURL.Error.Title", comment: "Title of the message shown when the user attempts to navigate to an invalid link.")
            public static let Message = String(format: NSLocalizedString("OpenURL.Error.Message", comment: "The message displayed to a user when they try to open a URL that cannot be handled by Firefox, or any external app."), AppInfo.displayName)
        }
        public struct App {
            public static let RestoreTabsAfterCrashMessage = String(format: NSLocalizedString("Restore.Tabs.After.Crash", comment: "Restore Tabs Prompt Description"), AppInfo.displayName)
            public static let CrashedMessage = String(format: NSLocalizedString("App.Crashed", comment: "App crashed"), AppInfo.displayName)
        }
    }

    // MARK: - Download Helper
    public struct Downloads {
        public struct Alert {
            public static let DownloadNowButtonTitle = NSLocalizedString("Downloads.Alert.DownloadNow", comment: "The label of the button the user will press to start downloading a file")
        }
        public struct Toast {
            public static let GoToDownloadsButtonTitle = NSLocalizedString("Downloads.Toast.GoToDownloads.Button", comment: "The button to open a new tab with the Downloads home panel")
            public static let Cancelled = NSLocalizedString("Downloads.Toast.Cancelled.LabelText", comment: "The label text in the Download Cancelled toast for showing confirmation that the download was cancelled.")
            public static let Failed = NSLocalizedString("Downloads.Toast.Failed.LabelText", comment: "The label text in the Download Failed toast for showing confirmation that the download has failed.")
            public static let FailedRetryButton = NSLocalizedString("Downloads.Toast.Failed.RetryButton", comment: "The button to retry a failed download from the Download Failed toast.")
            public static let MultipleFilesDescription = NSLocalizedString("Downloads.Toast.MultipleFiles.DescriptionText", comment: "The description text in the Download progress toast for showing the number of files when multiple files are downloading.")
            public static let ProgressDescription = NSLocalizedString("Downloads.Toast.Progress.DescriptionText", comment: "The description text in the Download progress toast for showing the downloaded file size (1$) out of the total expected file size (2$).")
            public static let MultipleFilesAndProgressDescription = NSLocalizedString("Downloads.Toast.MultipleFilesAndProgress.DescriptionText", comment: "The description text in the Download progress toast for showing the number of files (1$) and download progress (2$). This string only consists of two placeholders for purposes of displaying two other strings side-by-side where 1$ is Downloads.Toast.MultipleFiles.DescriptionText and 2$ is Downloads.Toast.Progress.DescriptionText. This string should only consist of the two placeholders side-by-side separated by a single space and 1$ should come before 2$ everywhere except for right-to-left locales.")
        }
        public struct CancelDialog {
            public static let Title = NSLocalizedString("Downloads.CancelDialog.Title", comment: "Alert dialog title when the user taps the cancel download icon.")
            public static let Message = NSLocalizedString("Downloads.CancelDialog.Message", comment: "Alert dialog body when the user taps the cancel download icon.")
            public static let Resume = NSLocalizedString("Downloads.CancelDialog.Resume", comment: "Button declining the cancellation of the download.")
            public static let Cancel = NSLocalizedString("Downloads.CancelDialog.Cancel", comment: "Button confirming the cancellation of the download.")
        }
    }

    // MARK: - Context Menu
    public struct ContextMenu {
        public struct ButtonToast {
            public struct NewTabOpened {
                public static let LabelText = NSLocalizedString("ContextMenu.ButtonToast.NewTabOpened.LabelText", comment: "The label text in the Button Toast for switching to a fresh New Tab.")
                public static let ButtonText = NSLocalizedString("ContextMenu.ButtonToast.NewTabOpened.ButtonText", comment: "The button text in the Button Toast for switching to a fresh New Tab.")
            }
        }
        public static let OpenInNewTab = NSLocalizedString("ContextMenu.OpenInNewTabButtonTitle", comment: "Context menu item for opening a link in a new tab")
        public static let BookmarkLink = NSLocalizedString("ContextMenu.BookmarkLinkButtonTitle", comment: "Context menu item for bookmarking a link URL")
        public static let DownloadLink = NSLocalizedString("ContextMenu.DownloadLinkButtonTitle", comment: "Context menu item for downloading a link URL")
        public static let CopyLink = NSLocalizedString("ContextMenu.CopyLinkButtonTitle", comment: "Context menu item for copying a link URL to the clipboard")
        public static let ShareLink = NSLocalizedString("ContextMenu.ShareLinkButtonTitle", comment: "Context menu item for sharing a link URL")
        public static let SaveImage = NSLocalizedString("ContextMenu.SaveImageButtonTitle", comment: "Context menu item for saving an image")
        public static let CopyImage = NSLocalizedString("ContextMenu.CopyImageButtonTitle", comment: "Context menu item for copying an image to the clipboard")
        public static let CopyImageLink = NSLocalizedString("ContextMenu.CopyImageLinkButtonTitle", comment: "Context menu item for copying an image URL to the clipboard")
    }

    // MARK: - Photo Library
    public struct PhotoLibrary {
        public static let AppWouldLikeAccessTitle = String(format: NSLocalizedString("PhotoLibrary.AppWouldLikeAccessTitle", comment: "See http://mzl.la/1G7uHo7"), AppInfo.displayName)
        public static let AppWouldLikeAccessMessage = NSLocalizedString("PhotoLibrary.AppWouldLikeAccessMessage", comment: "See http://mzl.la/1G7uHo7")
    }

    // MARK: - Sent Tab
    public struct SentTab {
        public struct ViewAction {
            public static let Title = NSLocalizedString("SentTab.ViewAction.title", comment: "Label for an action used to view one or more tabs from a notification.")
        }
    }

    // MARK: - Reader Mode
    public struct ReaderMode {
        public struct Available {
            public static let VoiceOverAnnouncement = NSLocalizedString("ReaderMode.Available.VoiceOverAnnouncement", comment: "Accessibility message e.g. spoken by VoiceOver when Reader Mode becomes available.")
        }
        public static let ResetFontSizeAccessibilityLabel = NSLocalizedString("ReaderMode.ResetFontSizeAccessibilityLabel", comment: "Accessibility label for button resetting font size in display settings of reader mode")
    }

    // MARK: - Privacy Dashboard
    public struct PrivacyDashboard {
        public struct Title {
            public static let BlockingEnabled = NSLocalizedString("PrivacyDashboard.Title.BlockingEnabled", tableName: "UserAgent", comment: "")
            public static let NoTrackersSeen = NSLocalizedString("PrivacyDashboard.Title.NoTrackersSeen", tableName: "UserAgent", comment: "")
            public static let AdBlockAllowListed = NSLocalizedString("PrivacyDashboard.Title.AdBlockAllowListed", tableName: "UserAgent", comment: "")
            public static let AntiTrackingAllowListed = NSLocalizedString("PrivacyDashboard.Title.AntiTrackingAllowListed", tableName: "UserAgent", comment: "")
            public static let AllowListed = NSLocalizedString("PrivacyDashboard.Title.AllowListed", tableName: "UserAgent", comment: "")
        }
        public struct Legend {
            public static let NoTrackersSeen = NSLocalizedString("PrivacyDashboard.Legend.NoTrackersSeen", tableName: "UserAgent", comment: "")
            public static let AllowListed = NSLocalizedString("PrivacyDashboard.Legend.AllowListed", tableName: "UserAgent", comment: "")
        }
        public struct Switch {
             public static let AntiTracking = NSLocalizedString("PrivacyDashboard.Switch.AntiTracking", tableName: "UserAgent", comment: "")
            public static let AdBlock = NSLocalizedString("PrivacyDashboard.Switch.AdBlock", tableName: "UserAgent", comment: "")
            public static let PopupsBlocking = NSLocalizedString("PrivacyDashboard.Switch.PopupsBlocking", tableName: "UserAgent", comment: "")
        }
        public static let ViewFullReport = NSLocalizedString("PrivacyDashboard.ViewFullReport", tableName: "UserAgent", comment: "")
        public struct ReportPage {
            public static let SectionTitle = NSLocalizedString("PrivacyDashboard.ReportPage.SectionTitle", tableName: "UserAgent", comment: "")
            public static let AlertTitle = NSLocalizedString("PrivacyDashboard.ReportPage.AlertTitle", tableName: "UserAgent", comment: "")
            public static let AlertMessage = NSLocalizedString("PrivacyDashboard.ReportPage.AlertMessage", tableName: "UserAgent", comment: "")
        }
    }

    // MARK: - Contextual Onboarding
    public struct ContextualOnboarding {
        public static let DontShowAgain = NSLocalizedString("ContextualOnboarding.DontShowAgain", tableName: "ContextualOnboarding", comment: "Don't show agian button title")
        public struct WipeAllTraces {
            public static let Title = NSLocalizedString("ContextualOnboarding.WipeAllTraces.Title", tableName: "ContextualOnboarding", comment: "Title for Wipe All Traces screen")
            public static let Description = NSLocalizedString("ContextualOnboarding.WipeAllTraces.Description", tableName: "ContextualOnboarding", comment: "Description for Wipe All Traces screen")
        }
        public struct AutomaticForgetMode {
            public static let Title = NSLocalizedString("ContextualOnboarding.AutomaticForgotMode.Title", tableName: "ContextualOnboarding", comment: "Title for Automatic forget mode screen")
            public static let Description = NSLocalizedString("ContextualOnboarding.AutomaticForgotMode.Description", tableName: "ContextualOnboarding", comment: "Description for Automatic forget mode screen")
        }
    }

    // MARK: - Menu
    public struct Menu {
        public static let ShowTabsTitleString = NSLocalizedString("Menu.ShowTabs.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to open the tabs tray")
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
        public static let TopSitesTitleString = NSLocalizedString("Menu.OpenTopSitesAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Top Sites home panel.")
        public static let BookmarksTitleString = NSLocalizedString("Menu.OpenBookmarksAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Bbookmarks home panel.")
        public static let HistoryTitleString = NSLocalizedString("Menu.OpenHistoryAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the History home panel.")
        public static let DownloadsTitleString = NSLocalizedString("Menu.OpenDownloadsAction.AccessibilityLabel", tableName: "Menu", comment: "Accessibility label for the button, displayed in the menu, used to open the Downloads home panel.")
        public static let ButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.AccessibilityLabel", comment: "Accessibility label for the Menu button.")
        public static let TabTrayDeleteMenuButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.CloseAllTabs", comment: "Accessibility label for the Close All Tabs menu button.")
        public static let CopyURLConfirmMessage = NSLocalizedString("Menu.CopyURL.Confirm", comment: "Toast displayed to user after copy url pressed.")
        public static let AddBookmarkConfirmMessage = NSLocalizedString("Menu.AddBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been added.")
        public static let RemoveBookmarkConfirmMessage = NSLocalizedString("Menu.RemoveBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been removed.")
        public static let SendToDeviceTitle = NSLocalizedString("Send to Device", tableName: "3DTouchActions", comment: "Label for preview action on Tab Tray Tab to send the current tab to another device")
        public static let PageActionMenuTitle = NSLocalizedString("Menu.PageActions.Title", comment: "Label for title in page action menu.")
        public static let WhatsNewString = NSLocalizedString("Menu.WhatsNew.Title", comment: "The title for the option to view the What's new page.")
        public static let ShowPageSourceString = NSLocalizedString("Menu.PageSourceAction.Title", tableName: "Menu", comment: "Label for the button, displayed in the menu, used to show the html page source")
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
        public static let TrackingProtectionAllowListOn = NSLocalizedString("Menu.TrackingProtectionOption.AllowListOnDescription", comment: "label for the menu item to show when the website is allowListed from blocking trackers.")
        public static let TrackingProtectionAllowListRemove = NSLocalizedString("Menu.TrackingProtectionAllowListRemove.Title", comment: "label for the menu item that lets you remove a website from the tracking protection allowList")
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
        public static let TrackingProtectionReloadWithout = NSLocalizedString("Menu.ReloadWithoutTrackingProtection.Title", comment: "Label for the button, displayed in the menu, used to reload the current website without Tracking Protection")
        public static let TrackingProtectionReloadWith = NSLocalizedString("Menu.ReloadWithTrackingProtection.Title", comment: "Label for the button, displayed in the menu, used to reload the current website with Tracking Protection enabled")
        public static let PasteAndGoTitle = NSLocalizedString("Menu.PasteAndGo.Title", comment: "The title for the button that lets you paste and go to a URL")
        public static let PasteTitle = NSLocalizedString("Menu.Paste.Title", comment: "The title for the button that lets you paste into the location bar")
        public static let CopyAddressTitle = NSLocalizedString("Menu.Copy.Title", comment: "The title for the button that lets you copy the url from the location bar.")
    }

    // MARK: - External Link
    public struct ExternalLink {
        public struct AppStore {
            public static let ConfirmationTitle = NSLocalizedString("ExternalLink.AppStore.ConfirmationTitle", comment: "Question shown to user when tapping a link that opens the App Store app")
            public static let GenericConfirmation = NSLocalizedString("ExternalLink.AppStore.GenericConfirmationTitle", comment: "Question shown to user when tapping an SMS or MailTo link that opens the external app for those.")
        }
    }

    // MARK: - Intro
    public struct Intro {
        public struct Slides {
            public struct Search {
                public static let Title = NSLocalizedString("Intro.Slides.Search.Title", tableName: "Intro", comment: "Title for the 'Search' panel in the First Run tour.")
                public static let Description = NSLocalizedString("Intro.Slides.Search.Description", tableName: "Intro", comment: "Description for the 'Search' panel in the First Run tour.")
            }
            public struct AntiTracking {
                public static let Title = NSLocalizedString("Intro.Slides.AntiTracking.Title", tableName: "Intro", comment: "Title for the 'AntiTracking' panel in the First Run tour.")
                public static let Description = NSLocalizedString("Intro.Slides.AntiTracking.Description", tableName: "Intro", comment: "Description for the 'AntiTracking' panel in the First Run tour.")
            }
            public struct Welcome {
                public static let ButtonTitle = NSLocalizedString("Intro.Slides.Welcome.Button.Title", tableName: "Intro", comment: "Button title for starting browsing.")
                public static let Description = NSLocalizedString("Intro.Slides.Welcome.Description", tableName: "Intro", comment: "Description for the 'Welcome' panel in the First Run tour.")
            }
            public static let SkipButtonTitle = NSLocalizedString("Intro.Slides.Skip.Title", tableName: "Intro", comment: "Button title for skipping tour.")
        }
    }

    // MARK: - Send To
    public struct SendTo {
        public static let CancelButton = NSLocalizedString("SendTo.Cancel.Button", bundle: applicationBundle(), comment: "Button title for cancelling share screen")
        public static let ErrorOKButton = NSLocalizedString("SendTo.Error.OK.Button", bundle: applicationBundle(), comment: "OK button to dismiss the error prompt.")
        public static let ErrorTitle = NSLocalizedString("SendTo.Error.Title", bundle: applicationBundle(), comment: "Title of error prompt displayed when an invalid URL is shared.")
        public static let ErrorMessage = NSLocalizedString("SendTo.Error.Message", bundle: applicationBundle(), comment: "Message in error prompt explaining why the URL is invalid.")
        public static let CloseButton = NSLocalizedString("SendTo.Cancel.Button", bundle: applicationBundle(), comment: "Close button in top navigation bar")
        public static let NotSignedInText = NSLocalizedString("SendTo.NotSignedIn.Title", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
        public static let NotSignedInMessage = NSLocalizedString("SendTo.NotSignedIn.Message", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
        public static let NoDevicesFound = NSLocalizedString("SendTo.NoDevicesFound.Message", bundle: applicationBundle(), comment: "Error message shown in the remote tabs panel")
        public static let NavBarTitle = NSLocalizedString("SendTo.NavBar.Title", bundle: applicationBundle(), comment: "Title of the dialog that allows you to send a tab to a different device")
        public static let SendButtonTitle = NSLocalizedString("SendTo.SendAction.Text", bundle: applicationBundle(), comment: "Navigation bar button to Send the current page to a device")
        public static let DevicesListTitle = NSLocalizedString("SendTo.DeviceList.Text", bundle: applicationBundle(), comment: "Header for the list of devices table")
    }

    // MARK: - Share Extension
    public struct ShareExtension {
        public static let BookmarkThisPage = NSLocalizedString("ShareExtension.BookmarkThisPageAction.Title", tableName: "ShareTo", comment: "Action label on share extension to bookmark the page in Firefox.")
        public static let BookmarkThisPageDone = NSLocalizedString("ShareExtension.BookmarkThisPageActionDone.Title", comment: "Share extension label shown after user has performed 'Bookmark this Page' action.")
        public static var OpenIn = String(format: NSLocalizedString("ShareExtension.OpenInAction.Title", tableName: "ShareTo", comment: "Action label on share extension to immediately open page in \(AppInfo.displayName)."), AppInfo.displayName)
        public static var OpenInPrivateTab = NSLocalizedString("ShareExtension.OpenInPrivateTabAction.Title", tableName: "ShareTo", comment: "Action label on share extension to immediately open page in Private.")
        public static let SearchIn = String(format: NSLocalizedString("ShareExtension.SeachInUserAgentAction.Title", tableName: "ShareTo", comment: "Action label on share extension to search for the selected text in Firefox."), AppInfo.displayName)
        public static let LoadInBackground = NSLocalizedString("ShareExtension.LoadInBackgroundAction.Title", tableName: "ShareTo", comment: "Action label on share extension to load the page in Firefox when user switches apps to bring it to foreground.")
        public static let LoadInBackgroundDone = String(format: NSLocalizedString("ShareExtension.LoadInBackgroundActionDone.Title", tableName: "ShareTo", comment: "Share extension label shown after user has performed 'Load in Background' action."), AppInfo.displayName)
    }

    // MARK: - Interceptor
    public struct Interceptor {
        public struct AntiPhishing {
            public struct UI {
                public static let Title = NSLocalizedString("Interceptor.AntiPhishing.UI.Title", tableName: "UserAgent", comment: "Antiphishing alert title")
                public static let Message = String(format: NSLocalizedString("Interceptor.AntiPhishing.UI.Message", tableName: "UserAgent", comment: "Antiphishing alert message"), AppInfo.displayName, "%@")
                public static let BackButton = NSLocalizedString("Interceptor.AntiPhishing.UI.BackButtonLabel", tableName: "UserAgent", comment: "Back to safe site buttun title in antiphishing alert title")
                public static let ContinueButton = NSLocalizedString("Interceptor.AntiPhishing.UI.ContinueButtonLabel", tableName: "UserAgent", comment: "Continue despite warning buttun title in antiphishing alert title")
            }
        }
    }

    // MARK: - Tab Tray
    public struct TabTray {
        public static let CloseTabKeyCodeTitle = NSLocalizedString("TabTray.CloseTab.KeyCodeTitle", comment: "Hardware shortcut to close the selected tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let CloseAllTabsKeyCodeTitle = NSLocalizedString("TabTray.CloseAllTabs.KeyCodeTitle", comment: "Hardware shortcut to close all tabs from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let OpenSelectedTabKeyCodeTitle = NSLocalizedString("TabTray.OpenSelectedTab.KeyCodeTitle", comment: "Hardware shortcut open the selected tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let OpenNewTabKeyCodeTitle = NSLocalizedString("TabTray.OpenNewTab.KeyCodeTitle", comment: "Hardware shortcut to open a new tab from the tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let ShowTabTrayKeyCodeTitle = NSLocalizedString("TabTray.ShowTabTray.KeyCodeTitle", comment: "Hardware shortcut to open the tab tray from a tab. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let SwitchToNonPBMKeyCodeTitle = NSLocalizedString("TabTray.SwitchToNonPBM.KeyCodeTitle", comment: "Hardware shortcut for non-private tab or tab. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        public static let SwitchToPBMKeyCodeTitle = NSLocalizedString("TabTray.SwitchToPBM.KeyCodeTitle", comment: "Hardware shortcut switch to the private browsing tab or tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
    }

}
