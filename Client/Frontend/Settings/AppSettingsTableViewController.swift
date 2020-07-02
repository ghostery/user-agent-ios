/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

/// App Settings Screen (triggered by tapping the 'Gear' in the Tab Tray Controller)
class AppSettingsTableViewController: SettingsTableViewController {

    private var searchCurrentRegion: Search.Country?
    private var searchAvailableRegions: [Search.Country]?
    private var currentAdultFilterMode: Search.AdultFilterMode?
    private var newsCurrentRegion: News.Country?
    private var newsAvailableRegions: [News.Country]?

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = Strings.Settings.Title
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

    }

    override func viewWillAppear(_ animated: Bool) {
        self.resetBrowserCoreValues()
        super.viewWillAppear(animated)
        self.fetchBrowserCoreValus()
    }

    override func generateSettings() -> [SettingSection] {
        var settings = [SettingSection]()
        if Features.Search.QuickSearch.isEnabled || Features.Search.AdditionalSearchEngines.isEnabled {
            settings.append(self.searchSettingSection())
        }
        settings.append(contentsOf: [
            self.privacySettingSection(),
            self.privacyDashboardSettingSection(),
        ])
        if Features.TodayWidget.isEnabled {
            settings.append(self.todayWidgetSettingSection())
        }
        settings.append(self.generalSettingSection())
        if Features.News.isEnabled {
            settings.append(self.newsSettingSection())
        }
        settings.append(contentsOf: [
            self.supportSettingSection(),
            self.aboutSettingSection(),
        ])
        return settings
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = super.tableView(tableView, viewForHeaderInSection: section) as! ThemedTableSectionHeaderFooterView
        // Prevent the top border from showing for the General section.
        switch section {
        case 1:
            headerView.showTopBorder = false
        default:
            break
        }

        return headerView
    }

    // MARK: - Private methods

    private func searchSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        var searchSettings: [Setting] = []

        if Features.Search.QuickSearch.isEnabled {
            searchSettings.append(SearchLanguageSetting(currentRegion: self.searchCurrentRegion, availableRegions: self.searchAvailableRegions))
            searchSettings.append(BoolSetting(prefs: prefs, defaultValue: self.currentAdultFilterMode == .conservative, titleText: Strings.Settings.Search.AdultFilterMode, enabled: self.currentAdultFilterMode != nil) { (value) in
                Search.setAdultFilter(filter: value ? .conservative : .liberal)
            })
        }
        if Features.Search.AdditionalSearchEngines.isEnabled {
            searchSettings.append(SearchSetting(settings: self))
        }
        return SettingSection(title: NSAttributedString(string: Strings.Settings.Search.Title), children: searchSettings)
    }

    private func privacySettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let privacyTitle = Strings.Settings.Privacy.Title
        let privacySettings = [
            ClearPrivateDataSetting(settings: self),
            BoolSetting(
                prefs: prefs,
                prefKey: "settings.closePrivateTabs",
                defaultValue: false,
                titleText: Strings.Settings.Privacy.ClosePrivateTabs,
                statusText: Strings.ForgetMode.ClosePrivateTabsDescription),
        ]
        return SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)
    }

    private func privacyDashboardSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let privacyTitle = Strings.Settings.PrivacyDashboard.Title
        let privacySettings = [
            BoolSetting(
                prefs: prefs,
                defaultValue: FirefoxTabContentBlocker.isAntiTrackingEnabled(tabManager: self.tabManager),
                titleText: Strings.Settings.PrivacyDashboard.AntiTrackingTitle) { _ in
                    FirefoxTabContentBlocker.toggleAntiTrackingEnabled(prefs: self.profile.prefs, tabManager: self.tabManager)
            },
            BoolSetting(
                prefs: prefs,
                defaultValue: FirefoxTabContentBlocker.isAdBlockingEnabled(tabManager: self.tabManager),
                titleText: Strings.Settings.PrivacyDashboard.AdBlockingTitle) { _ in
                    FirefoxTabContentBlocker.toggleAdBlockingEnabled(prefs: self.profile.prefs, tabManager: self.tabManager)
            },
            BoolSetting(
                prefs: prefs,
                defaultValue: FirefoxTabContentBlocker.isPopupBlockerEnabled(tabManager: self.tabManager),
                titleText: Strings.Settings.PrivacyDashboard.PopupBlockerTitle) { _ in
                    FirefoxTabContentBlocker.togglePopupBlockerEnabled(prefs: self.profile.prefs, tabManager: self.tabManager)
            },
        ]
        return SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)
    }

    private func todayWidgetSettingSection() -> SettingSection {
        let privacyTitle = Strings.Settings.TodayWidget.SectionName
        var privacySettings = [Setting]()
        privacySettings.append(TodayWidgetSetting(settings: self))
        return SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)
    }

    private func generalSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        var generalSettings: [Setting] = [
            OpenWithSetting(settings: self),
            NewTabPageDefaultViewSetting(settings: self),
            OpenLinkSetting(settings: self),
            OnBrowserStartShowSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.RefreshControlEnabled, defaultValue: true,
                        titleText: Strings.Settings.General.RefreshControl),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.KeyBlockPopups, defaultValue: true,
                        titleText: Strings.Settings.General.BlockPopUpWindows),
        ]

        if #available(iOS 12.0, *) {
            generalSettings.insert(SiriPageSetting(settings: self), at: 1)
        }

        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.
        generalSettings += [
            BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                        titleText: Strings.Settings.General.OfferClipboardBarTitle,
                        statusText: Strings.Settings.General.OfferClipboardBarStatus),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.ContextMenuShowLinkPreviews, defaultValue: true,
                        titleText: Strings.Settings.General.ShowLinkPreviewsTitle,
                        statusText: Strings.Settings.General.ShowLinkPreviewsStatus),
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.General.SectionTitle), children: generalSettings)
    }

    private func newsSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let newsSettigns = [
            BoolSetting(
                prefs: prefs,
                prefKey: PrefsKeys.NewTabNewsEnabled,
                defaultValue: true,
                titleText: Strings.Settings.News.NewsFromNewTabPage
            ) { (_) in
                NotificationCenter.default.post(name: .NewsSettingsDidChange, object: nil)
                self.reloadData()
            },
            NewsLanguageSetting(
                currentRegion: self.newsCurrentRegion,
                availableRegions: self.newsAvailableRegions
            ),
            BoolSetting(
                prefs: prefs,
                prefKey: PrefsKeys.NewTabNewsImagesEnabled,
                defaultValue: true,
                titleText: Strings.Settings.News.NewsImages,
                enabled: prefs.boolForKey(PrefsKeys.NewTabNewsEnabled) ?? true
            ) { (_) in
                NotificationCenter.default.post(name: .NewsSettingsDidChange, object: nil)
            },
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.News.SectionTitle), children: newsSettigns)
    }

    private func supportSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        var supportSettigns = [Setting]()
        if Onboarding.isEnabled {
            supportSettigns.insert(ShowIntroductionSetting(settings: self), at: 0)
        }
        supportSettigns.append(SendFeedbackSetting())
        if Features.HumanWeb.isEnabled {
            supportSettigns.append(HumanWebSetting(prefs: prefs))
        }
        if Features.Telemetry.isEnabled {
            let telemetrySetting = TelemetrySetting(prefs: prefs, attributedStatusText: NSAttributedString(string: Strings.Settings.Support.SendUsageStatus, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.headerTextLight]))
            supportSettigns.append(telemetrySetting)
        }
        supportSettigns.append(PrivacyPolicySetting())
        return SettingSection(title: NSAttributedString(string: Strings.Settings.Support.SectionTitle), children: supportSettigns)
    }

    private func aboutSettingSection() -> SettingSection {
        let aboutSettings = [
            VersionSetting(settings: self),
            LicenseAndAcknowledgementsSetting(),
            ExportBrowserDataSetting(settings: self),
            ExportLogDataSetting(settings: self),
            DeleteExportedDataSetting(settings: self),
            ForceCrashSetting(settings: self),
            SlowTheDatabase(settings: self),
            SentryIDSetting(settings: self),
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.About.SectionTitle), children: aboutSettings)
    }

    // MARK: - Private methods

    private func resetBrowserCoreValues() {
        self.searchCurrentRegion = nil
        self.searchAvailableRegions = nil
        self.currentAdultFilterMode = nil
        self.newsCurrentRegion = nil
        self.newsAvailableRegions = nil
    }

    private func fetchBrowserCoreValus() {
        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        Search.getBackendCountries { (config) in
            self.searchCurrentRegion = config.selected
            self.searchAvailableRegions = config.available
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        Search.getAdultFilter { (mode) in
            self.currentAdultFilterMode = mode
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        News.getAvailableLanguages { (config) in
            self.newsCurrentRegion = config.selected
            self.newsAvailableRegions = config.available
            dispatchGroup.leave()
        }

        dispatchGroup.notify(queue: .main) {
             self.reloadData()
        }
    }

}
