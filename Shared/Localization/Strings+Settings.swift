//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {
    public struct Settings {
        public static let Title = NSLocalizedString("Settings.Title", tableName: "Settings", comment: "Title in the settings view controller title bar")
        public struct Search {
            public static let Title = NSLocalizedString("Settings.Search.Title", tableName: "Settings", comment: "Search settings section title")
            public static let AdultFilterMode = NSLocalizedString("Settings.Search.AdultFilterMode", tableName: "Settings", comment: "Block explicit content")
            public struct SearchResultForLanguage {
                public static let Title = NSLocalizedString("Settings.Search.SearchResultForLanguage.Title", tableName: "Settings", comment: "The button text in Settings that opens the list of supported search languages.")
                public static let German = NSLocalizedString("region-DE", tableName: "Settings", comment: "Localized String for German region")
            }
            public struct AdditionalSearchEngines {
                public static let SectionTitle = NSLocalizedString("Settings.Search.AdditionalSearchEngines.SectionName", tableName: "Settings", comment: "The button text in Search Settings that opens the Additional Search Engines view.")
                public static let DefaultSearchEngine = NSLocalizedString("Settings.Search.AdditionalSearchEngines.DefaultSearchEngine", tableName: "Settings", comment: "Description for choosing search engine")
                public static let ItemDefaultEngine = NSLocalizedString("Settings.Search.AdditionalSearchEngines.ItemDefaultEngine", tableName: "Settings", comment: "Label for show search suggestions setting.")
            }
            public struct AddCustomEngine {
                public static let ButtonTitle = NSLocalizedString("Settings.Search.AddCustomEngine.ButtonTitle", tableName: "Settings", comment: "The button text in Search Settings that opens the Custom Search Engine view.")
                public static let Title = NSLocalizedString("Settings.Search.AddCustomEngine.Title", tableName: "Settings", comment: "The title of the Custom Search Engine view.")
                public static let TitleFieldSectionTitle = NSLocalizedString("Settings.Search.AddCustomEngine.TitleLabel", tableName: "Settings", comment: "The title for the field which sets the title for a custom search engine.")
                public static let URLSectionTitle = NSLocalizedString("Settings.Search.AddCustomEngine.URLLabel", tableName: "Settings", comment: "The title for URL Field")
                public static let TitlePlaceholder = NSLocalizedString("Settings.Search.AddCustomEngine.TitlePlaceholder", tableName: "Settings", comment: "The placeholder for Title Field when saving a custom search engine.")
                public static let URLPlaceholder = NSLocalizedString("Settings.Search.AddCustomEngine.URLPlaceholder", tableName: "Settings", comment: "The placeholder for URL Field when saving a custom search engine")
            }
        }
        public struct Privacy {
            public static let Title = NSLocalizedString("Settings.Privacy.Title", tableName: "Settings", comment: "Privacy section title")
            public static let ClosePrivateTabs = NSLocalizedString("Settings.Privacy.ClosePrivateTabs", tableName: "Settings", comment: "Setting for closing private tabs")
            public struct DataManagement {
                public static let SectionName = NSLocalizedString("Settings.Privacy.DataManagement.SectionName", tableName: "Settings", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
                public static let SearchLabel = NSLocalizedString("Settings.Privacy.DataManagement.SearchLabel", tableName: "Settings", comment: "Default text in search bar for Data Management")
                public static let Title = NSLocalizedString("Settings.Privacy.DataManagement.Title", tableName: "Settings", comment: "Title displayed in header of the setting panel.")
                public struct WebsiteData {
                    public static let Title = NSLocalizedString("Settings.Privacy.WebsiteData.Title", tableName: "Settings", comment: "Title displayed in header of the Data Management panel.")
                    public static let ShowMoreButton = NSLocalizedString("Settings.Privacy.WebsiteData.ButtonShowMore", tableName: "Settings", comment: "Button shows all websites on website data tableview")
                    public static let ClearWebsiteDataMessage = NSLocalizedString("Settings.Privacy.WebsiteData.ConfirmPrompt", tableName: "Settings", comment: "Description of the confirmation dialog shown when a user tries to clear their private data.")
                    public static let ClearAll = NSLocalizedString("Settings.Privacy.WebsiteData.ClearAll", tableName: "Settings", comment: "Button in Data Management that clears private data for the selected items.")
                }
                public struct PrivateData {
                    public static let PrivacyStats = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.PrivacyStats", tableName: "Settings", comment: "Settings item for clearing privacy stats")
                    public static let DownloadedFiles = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.DownloadedFiles", tableName: "Settings", comment: "Settings item for deleting downloaded files")
                    public static let Cookies = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.Cookies", tableName: "Settings", comment: "Settings item for clearing cookies")
                    public static let OfflineWebsiteData = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.OfflineWebsiteData", tableName: "Settings", comment: "Settings item for clearing website data")
                    public static let Cache = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.Cache", tableName: "Settings", comment: "Settings item for clearing the cache")
                    public static let BrowsingHistory = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.BrowsingHistory", tableName: "Settings", comment: "Settings item for clearing browsing history")
                    public static let BrowsingStorage = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.BrowsingStorage", tableName: "Settings", comment: "Settings item for clearing browsing storage")
                    public static let AllTabs = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.AllTabs", tableName: "Settings", comment: "Settings item for closing all tabs")
                    public static let Bookmarks = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.Bookmarks", tableName: "Settings", comment: "Settings item for clear all bookmarks")
                    public static let TopAndPinnedSites = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.TopSites", tableName: "Settings", comment: "Settings item for clear all TopSites")
                    public static let SearchHistory = NSLocalizedString("Settings.Privacy.DataManagement.PrivateData.SearchHistory", tableName: "Settings", comment: "Settings item for removing search history")
                }
                public struct ClearPrivateData {
                    public static let Title = NSLocalizedString("Settings.Privacy.ClearPrivateData.Title", tableName: "Settings", comment: "Title displayed in header of the setting panel.")
                    public static let ClearButton = NSLocalizedString("Settings.Privacy.ClearPrivateData.ClearButton", tableName: "Settings", comment: "Button in settings that clears private data for the selected items.")
                    public static let SectionName = NSLocalizedString("Settings.Privacy.ClearPrivateData.SectionName", tableName: "Settings", comment: "Label used as an item in Settings. When touched it will open a dialog prompting the user to make sure they want to clear all of their private data.")
                }
            }
        }
        public struct PrivacyDashboard {
            public static let Title = NSLocalizedString("Settings.PrivacyDashboard.Title", tableName: "Settings", comment: "Privacy Dashboard Title")
            public static let AdBlockingTitle = NSLocalizedString("Settings.PrivacyDashboard.AdBlockingTitle", tableName: "Settings", comment: "Ad-blocking setting")
            public static let AntiTrackingTitle = NSLocalizedString("Settings.PrivacyDashboard.AntiTrackingTitle", tableName: "Settings", comment: "Anti-tracking setting")
            public static let PopupBlockerTitle = NSLocalizedString("Settings.PrivacyDashboard.PopupBlockerTitle", tableName: "Settings", comment: "Pop-up Blocker setting")
        }
        public struct TodayWidget {
            public static let SectionName = NSLocalizedString("Settings.TodayWidget.SectionName", tableName: "Settings", comment: "Label used as an item in Settings.")
            public static let Title = NSLocalizedString("Settings.TodayWidget.Title", tableName: "Settings", comment: "Title displayed in header of the setting panel.")
            public static let SearchLabel = NSLocalizedString("Settings.TodayWidget.SearchLabel", tableName: "Settings", comment: "Default text in search bar for Today Widget Setting")
        }
        public struct General {
            public static let SectionTitle = NSLocalizedString("Settings.General.SectionName", tableName: "Settings", comment: "General settings section title")
            public struct OpenWith {
                public static let SectionName = NSLocalizedString("Settings.General.OpenWith.SectionName", tableName: "Settings", comment: "Label used as an item in Settings. When touched it will open a dialog to configure the open with (mail links) behaviour.")
                public static let PageTitle = NSLocalizedString("Settings.General.OpenWith.PageTitle", tableName: "Settings", comment: "Title for Open With Settings")
            }
            public struct Siri {
                public static let SectionName = NSLocalizedString("Settings.General.Siri.SectionName", tableName: "Settings", comment: "The option that takes you to the siri shortcuts settings page")
                public static let SectionDescription = String(format: NSLocalizedString("Settings.General.Siri.SectionDescription", tableName: "Settings", comment: "The description that describes what siri shortcuts are"), AppInfo.displayName)
                public static let OpenURL = NSLocalizedString("Settings.General.Siri.OpenTabShortcut", tableName: "Settings", comment: "The description of the open new tab siri shortcut")
                public static let SearchWith = NSLocalizedString("Settings.General.Siri.SearchWith", tableName: "Settings", comment: "The description of the search with siri shortcut")
            }
            public struct NewTabPageDefaultView {
                public static let SectionName = NSLocalizedString("Settings.General.NewTabPageDefaultView.SectionName", tableName: "Settings", comment: "The option in settings to configure default selected view in new tab")
            }
            public struct OnBrowserStartTab {
                public static let SectionName = NSLocalizedString("Settings.General.OnBrowserStartTab.SectionName", tableName: "Settings", comment: "The option in settings to configure first launch tab")
                public static let LastOpenedTab = NSLocalizedString("Settings.General.OnBrowserStartTab.LastOpenedTab", tableName: "Settings", comment: "The option in settings to configure first launch to open last opened tab")
                public static let NewTab = NSLocalizedString("Settings.General.OnBrowserStartTab.NewTab", tableName: "Settings", comment: "The option in settings to configure first launch to open new tab")
            }
            public static let RefreshControl = NSLocalizedString("Settings.General.RefreshControl.SectionName", tableName: "Settings", comment: "The option in settings to enable/disable Refresh Control.")
            public static let BlockPopUpWindows = NSLocalizedString("Settings.General.BlockPopUpWindows", tableName: "Settings", comment: "Block pop-up windows setting")
            public static let OfferClipboardBarTitle = NSLocalizedString("Settings.General.OfferClipboardBarTitle", tableName: "Settings", comment: "Title of setting to enable the Go to Copied URL feature. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349")
            public static let OfferClipboardBarStatus = String(format: NSLocalizedString("Settings.General.OfferClipboardBarStatus", tableName: "Settings", comment: "Description displayed under the ”Offer to Open Copied Link” option. See https://bug1223660.bmoattachments.org/attachment.cgi?id=8898349"), AppInfo.displayName)
            public static let ShowLinkPreviewsTitle = NSLocalizedString("Settings.General.ShowLinkPreivewsTitle", tableName: "Settings", comment: "Title of setting to enable link previews when long-pressing links.")
            public static let ShowLinkPreviewsStatus = NSLocalizedString("Settings.General.ShowLinkPreviewsStatus", tableName: "Settings", comment: "Description displayed under the ”Show Link Previews” option")
        }
        public struct News {
            public static let SectionTitle = NSLocalizedString("Settings.News.SectionName", tableName: "Settings", comment: "News settings section title")
            public static let NewsFromNewTabPage = NSLocalizedString("Settings.News.NewsFromNewTabPage", tableName: "Settings", comment: "Disable news from new tab page")
            public static let NewsImages = NSLocalizedString("Settings.News.NewsImages", tableName: "Settings", comment: "Disable load of news images")
            public struct Language {
                public static let Title = NSLocalizedString("Settings.News.Language", tableName: "Settings", comment: "The button text in Settings that opens the list of supported news languages.")
                public static let German = NSLocalizedString("region-DE", tableName: "Settings", comment: "Localized String for German region")
            }
        }
        public struct Support {
            public static let SectionTitle = NSLocalizedString("Settings.Support.SectionTitle", tableName: "Settings", comment: "Support section title")
            public static let HumanWebTitle = NSLocalizedString("Settings.Support.HumanWebTitle", tableName: "Settings", comment: "The title for the human web setting")
            public static let FAQAndSupport = NSLocalizedString("Settings.Support.FAQAndSupport", tableName: "Settings", comment: "Menu item in settings used to open https://cliqz.com/support")
            public static let ShowTour = NSLocalizedString("Settings.Support.ShowTour", tableName: "Settings", comment: "Show the on-boarding screen again from the settings")
            public static let PrivacyPolicy = NSLocalizedString("Settings.Support.PrivacyPolicy", tableName: "Settings", comment: "Show Firefox Browser Privacy Policy page from the Privacy section in the settings. See https://www.mozilla.org/privacy/firefox/")
            public static let SendUsageTitle = NSLocalizedString("Settings.Support.SendUsageTitle", tableName: "Settings", comment: "The title for the setting to send usage data.")
            public static let SendUsageStatus = String(format: NSLocalizedString("Settings.Support.SendUsageStatus", tableName: "Settings", comment: "A short description that explains why mozilla collects usage data."), AppInfo.displayName, AppInfo.displayName)
        }
        public struct About {
            public static let SectionTitle = NSLocalizedString("Settings.About.SectionTitle", tableName: "Settings", comment: "About settings section title")
            public static let Version = NSLocalizedString("Settings.About.Version", tableName: "Settings", comment: "Version number of Firefox shown in settings")
            public static let Licenses = NSLocalizedString("Settings.About.Licenses", tableName: "Settings", comment: "Settings item that opens a tab containing the licenses. See http://mzl.la/1NSAWCG")
        }
        public struct NewTab {
            public static let TopSites = String(format: NSLocalizedString("Settings.NewTab.Option.Home", tableName: "Settings", comment: "Option in settings to show Firefox Home when you open a new tab"), AppInfo.displayName)
        }
        public struct TrackingProtection {
            public static let SectionName = NSLocalizedString("Settings.TrackingProtection.SectionName", tableName: "Settings", comment: "Row in top-level of settings that gets tapped to show the tracking protection settings detail view.")
        }
        public struct TranslateSnackBar {
            public static let SectionHeader = NSLocalizedString("Settings.TranslateSnackBar.SectionHeader", tableName: "Settings", comment: "Translation settings section title")
            public static let SectionFooter = NSLocalizedString("Settings.TranslateSnackBar.SectionFooter", tableName: "Settings", comment: "Translation settings footer describing how language detection and translation happens.")
            public static let Title = NSLocalizedString("Settings.TranslateSnackBar.Title", tableName: "Settings", comment: "Title in main app settings for Translation toast settings")
            public static let SwitchTitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchTitle", tableName: "Settings", comment: "Switch to choose if the language of a page is detected and offer to translate.")
            public static let SwitchSubtitle = NSLocalizedString("Settings.TranslateSnackBar.SwitchSubtitle", tableName: "Settings", comment: "Switch to choose if the language of a page is detected and offer to translate.")
        }
        public static let CopyAppVersionAlertTitle = NSLocalizedString("Settings.CopyAppVersion.Title", tableName: "Settings", comment: "Copy app version alert shown in settings.")
    }
}
