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
        public static let NoString = NSLocalizedString("No", comment: "Label for No button")
        public static let CopyString = NSLocalizedString("Copy", comment: "Label for Copy button")
        public static let DeleteString = NSLocalizedString("Delete", comment: "Label for Copy button")
        public static let EditString = NSLocalizedString("Edit", comment: "Label for Edit button")
        public static let SaveString = NSLocalizedString("Save", comment: "Label for Edit button")
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
        }
        public struct ContextMenu {
            public static let PinTopsite = NSLocalizedString("ActivityStream.ContextMenu.PinTopsite", comment: "The title for the pinning a topsite action")
            public static let RemovePinTopsite = NSLocalizedString("ActivityStream.ContextMenu.RemovePinTopsite", comment: "The title for removing a pinned topsite action")
        }
        public static let PinnedSitesTitle =  NSLocalizedString("ActivityStream.PinnedSites.SectionTitle", comment: "Section title label for Pinned Sites")
    }

    // MARK: - Home Panel Context Menu
    public struct HomePanel {
        public struct ContextMenu {
            public static let OpenInNewTab = NSLocalizedString("HomePanel.ContextMenu.OpenInNewTab", comment: "The title for the Open in New Tab context menu action for sites in Home Panels")
            public static let RemoveBookmark = NSLocalizedString("HomePanel.ContextMenu.RemoveBookmark", comment: "The title for the Remove Bookmark context menu action for sites in Home Panels")
            public static let DeleteFromHistory = NSLocalizedString("HomePanel.ContextMenu.DeleteFromHistory", comment: "The title for the Delete from History context menu action for sites in Home Panels")
            public static let DeleteAllTraces = NSLocalizedString("HomePanel.ContextMenu.DeleteAllTraces", comment: "The title for the Delete all traces context menu action for sites in Home Panels")
            public static let Remove = NSLocalizedString("HomePanel.ContextMenu.Remove", comment: "The title for the Remove context menu action for sites in Home Panels")
        }
        public struct ReopenAlert {
            public static let Title = NSLocalizedString("ReopenAlert.Title", comment: "Reopen alert title shown at home page.")
            public static let ActionsReopen = NSLocalizedString("ReopenAlert.Actions.Reopen", comment: "Reopen button text shown in reopen-alert at home page.")
            public static let ActionsCancel = NSLocalizedString("ReopenAlert.Actions.Cancel", comment: "Cancel button text shown in reopen-alert at home page.")
        }
    }

    // MARK: - Home View
    public struct HomeView {
        public struct SegmentedControl {
            public static let TopSitesTitle = NSLocalizedString("HomeView.SegmentedControl.TopSites.Title", tableName: "UserAgent", comment: "")
            public static let BookmarksTitle = NSLocalizedString("HomeView.SegmentedControl.Bookmarks.Title", tableName: "UserAgent", comment: "")
            public static let HistoryTitle = NSLocalizedString("HomeView.SegmentedControl.History.Title", tableName: "UserAgent", comment: "")
        }
    }

    // MARK: - Downloads Panel
    public struct DownloadsPanel {
        public static let EmptyStateTitle = NSLocalizedString("DownloadsPanel.EmptyState.Title", comment: "Title for the Downloads Panel empty state.")
        public static let ShareTitle = NSLocalizedString("Share", comment: "Action button for sharing downloaded files in the Downloads panel.")
    }

    // MARK: - History Panel
    public struct HistoryPanel {
        public static let BrowserHomePage = String(format: NSLocalizedString("UserAgent.HomePage.Title", comment: "Title for firefox about:home page in tab history list"), AppInfo.displayName)
        public static let BackButtonTitle = NSLocalizedString("HistoryPanel.HistoryBackButton.Title", comment: "Title for the Back to History button in the History Panel")
    }

    // MARK: - Hotkeys
    public struct Hotkeys {
        public static let ReloadPageTitle = NSLocalizedString("Hotkeys.Reload.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
        public static let BackTitle = NSLocalizedString("Hotkeys.Back.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
        public static let ForwardTitle = NSLocalizedString("Hotkeys.Forward.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
        public static let FindTitle = NSLocalizedString("Hotkeys.Find.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
        public static let SelectLocationBarTitle = NSLocalizedString("Hotkeys.SelectLocationBar.DiscoveryTitle", comment: "Label to display in the Discoverability overlay for keyboard shortcuts")
        public static let NormalBrowsingModeTitle = NSLocalizedString("Hotkeys.NormalMode.DiscoveryTitle", comment: "Label to switch to normal browsing mode")
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
        public static let NotNowString = NSLocalizedString("Toasts.NotNow", comment: "label for Not Now button")
        public static let AppStoreString = NSLocalizedString("Toasts.OpenAppStore", comment: "Open App Store button")
    }

    // MARK: - Errors
    public struct Errors {
        public struct AddPass {
            public static let Title = NSLocalizedString("AddPass.Error.Title", comment: "Title of the 'Add Pass Failed' alert. See https://support.apple.com/HT204003 for context on Wallet.")
            public static let Message = NSLocalizedString("AddPass.Error.Message", comment: "Text of the 'Add Pass Failed' alert.  See https://support.apple.com/HT204003 for context on Wallet.")
        }
        public struct OpenURL {
            public static let Title = NSLocalizedString("OpenURL.Error.Title", comment: "Title of the message shown when the user attempts to navigate to an invalid link.")
            public static let Message = String(format: NSLocalizedString("OpenURL.Error.Message", comment: "The message displayed to a user when they try to open a URL that cannot be handled by Firefox, or any external app."), AppInfo.displayName)
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
    }

    // MARK: - Menu
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
        public static let ButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.AccessibilityLabel", comment: "Accessibility label for the Menu button.")
        public static let TabTrayDeleteMenuButtonAccessibilityLabel = NSLocalizedString("Toolbar.Menu.CloseAllTabs", comment: "Accessibility label for the Close All Tabs menu button.")
        public static let CopyURLConfirmMessage = NSLocalizedString("Menu.CopyURL.Confirm", comment: "Toast displayed to user after copy url pressed.")
        public static let AddBookmarkConfirmMessage = NSLocalizedString("Menu.AddBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been added.")
        public static let RemoveBookmarkConfirmMessage = NSLocalizedString("Menu.RemoveBookmark.Confirm", comment: "Toast displayed to the user after a bookmark has been removed.")
        public static let PageActionMenuTitle = NSLocalizedString("Menu.PageActions.Title", comment: "Label for title in page action menu.")
        public static let TPNoBlockingDescription = NSLocalizedString("Menu.TrackingProtectionNoBlocking.Description", comment: "The description of the Tracking Protection menu item when no scripts are blocked but tracking protection is enabled.")
        public static let TPBlockingMoreInfo = NSLocalizedString("Menu.TrackingProtectionMoreInfo.Description", comment: "more info about what tracking protection is about")
        public static let TrackingProtectionAdsBlocked = NSLocalizedString("Menu.TrackingProtectionAdsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
        public static let TrackingProtectionAnalyticsBlocked = NSLocalizedString("Menu.TrackingProtectionAnalyticsBlocked.Title", tableName: "Menu", comment: "The title that shows the number of Analytics scripts blocked")
        public static let TrackingProtectionSocialBlocked = NSLocalizedString("Menu.TrackingProtectionSocialBlocked.Title", tableName: "Menu", comment: "The title that shows the number of social scripts blocked")
        public static let TrackingProtectionContentBlocked = NSLocalizedString("Menu.TrackingProtectionContentBlocked.Title", tableName: "Menu", comment: "The title that shows the number of content scripts blocked")
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
        public static let PasteAndGoTitle = NSLocalizedString("Menu.PasteAndGo.Title", comment: "The title for the button that lets you paste and go to a URL")
        public static let PasteTitle = NSLocalizedString("Menu.Paste.Title", comment: "The title for the button that lets you paste into the location bar")
        public static let CopyAddressTitle = NSLocalizedString("Menu.Copy.Title", comment: "The title for the button that lets you copy the url from the location bar.")
        public static let ClearSearchHistory = NSLocalizedString("Menu.ClearSearchHistory", comment: "Action item that deletes all queries from database, shown on long press on search icon")
        public static let ShowQueryHistoryTitle = NSLocalizedString("Menu.QueryHistory.Title", comment: "The title for the button that query history list")
    }

    // MARK: - External Link
    public struct ExternalLink {
        public struct AppStore {
            public static let ConfirmationTitle = NSLocalizedString("ExternalLink.AppStore.ConfirmationTitle", comment: "Question shown to user when tapping a link that opens the App Store app")
            public static let GenericConfirmation = NSLocalizedString("ExternalLink.AppStore.GenericConfirmationTitle", comment: "Question shown to user when tapping an SMS or MailTo link that opens the external app for those.")
        }
    }

    // MARK: - Send To
    public struct SendTo {
        public static let ErrorTitle = NSLocalizedString("SendTo.Error.Title", bundle: applicationBundle(), comment: "Title of error prompt displayed when an invalid URL is shared.")
        public static let ErrorMessage = NSLocalizedString("SendTo.Error.Message", bundle: applicationBundle(), comment: "Message in error prompt explaining why the URL is invalid.")
        public static let NotSignedInText = NSLocalizedString("SendTo.NotSignedIn.Title", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
        public static let NotSignedInMessage = NSLocalizedString("SendTo.NotSignedIn.Message", bundle: applicationBundle(), comment: "See http://mzl.la/1ISlXnU")
    }

    // MARK: - Share Extension
    public struct ShareExtension {
        public static let BookmarkThisPage = NSLocalizedString("ShareExtension.BookmarkThisPageAction.Title", tableName: "ShareTo", comment: "Action label on share extension to bookmark the page in Firefox.")
        public static let BookmarkThisPageDone = NSLocalizedString("ShareExtension.BookmarkThisPageActionDone.Title", comment: "Share extension label shown after user has performed 'Bookmark this Page' action.")
        public static var OpenIn = String(format: NSLocalizedString("ShareExtension.OpenInAction.Title", tableName: "ShareTo", comment: "Action label on share extension to immediately open page in \(AppInfo.displayName)."), AppInfo.displayName)
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
    }
}
