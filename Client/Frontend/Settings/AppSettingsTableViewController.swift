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

        navigationItem.title = NSLocalizedString("Settings", comment: "Title in the settings view controller title bar")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: NSLocalizedString("Done", comment: "Done button on left side of the Settings view controller title bar"),
            style: .done,
            target: navigationController, action: #selector((navigationController as! ThemedNavigationController).done))
        navigationItem.rightBarButtonItem?.accessibilityIdentifier = "AppSettingsTableViewController.navigationItem.leftBarButtonItem"

        tableView.accessibilityIdentifier = "AppSettingsTableViewController.tableView"

    }

    override func viewWillAppear(_ animated: Bool) {
        self.resetSearchValues()
        self.resetNewsValues()
        super.viewWillAppear(animated)
        self.updateSearchValues()
        self.updateNewsValues()
    }

    override func generateSettings() -> [SettingSection] {
        return [
            self.searchSettingSection(),
            self.privacySettingSection(),
            self.generalSettingSection(),
            self.newsSettingSection(),
            self.supportSettingSection(),
            self.aboutSettingSection(),
        ]
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

    private func resetSearchValues() {
        self.searchCurrentRegion = nil
        self.searchAvailableRegions = nil
        self.currentAdultFilterMode = nil
    }

    private func updateSearchValues() {
        Search.getBackendCountries { (config) in
            DispatchQueue.main.async {
                self.searchCurrentRegion = config.selected
                self.searchAvailableRegions = config.available
                self.reloadData()
            }
        }
        Search.getAdultFilter { (mode) in
            DispatchQueue.main.async {
                self.currentAdultFilterMode = mode
                self.reloadData()
            }
        }
    }

    private func resetNewsValues() {
        self.newsCurrentRegion = nil
        self.newsAvailableRegions = nil
    }

    private func updateNewsValues() {
        News.getBackendCountries { (config) in
            DispatchQueue.main.async {
                self.newsCurrentRegion = config.selected
                self.newsAvailableRegions = config.available
                self.reloadData()
            }
        }
    }
    private func searchSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let searchSettings: [Setting] = [
            SearchLanguageSetting(currentRegion: self.searchCurrentRegion, availableRegions: self.searchAvailableRegions),
            BoolSetting(prefs: prefs, defaultValue: self.currentAdultFilterMode == .conservative, titleText: Strings.Settings.AdultFilterMode, enabled: self.currentAdultFilterMode != nil) { (value) in
                Search.setAdultFilter(filter: value ? .conservative : .liberal)
            },
            // Temporarily disabling additional search engines setting.
//            SearchSetting(settings: self),
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.Search.SectionTitle), children: searchSettings)
    }

    private func privacySettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let privacyTitle = NSLocalizedString("Privacy", comment: "Privacy section title")
        var privacySettings = [Setting]()
        privacySettings.append(ClearPrivateDataSetting(settings: self))
        privacySettings += [
            BoolSetting(
                prefs: prefs,
                prefKey: "settings.closePrivateTabs",
                defaultValue: false,
                titleText: Strings.ClosePrivateTabsLabel,
                statusText: Strings.ClosePrivateTabsDescription),
            BoolSetting(
                prefs: prefs,
                defaultValue: FirefoxTabContentBlocker.isPrivacyDashboardEnabled(tabManager: self.tabManager),
                titleText: Strings.Settings.PrivacyDashboard.Title,
                statusText: Strings.Settings.PrivacyDashboard.Description,
                enabled: true) { _ in
                    FirefoxTabContentBlocker.togglePrivacyDashboardEnabled(prefs: self.profile.prefs, tabManager: self.tabManager)
            },
        ]
        privacySettings += [PrivacyPolicySetting()]
        return SettingSection(title: NSAttributedString(string: privacyTitle), children: privacySettings)
    }

    private func generalSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        var generalSettings: [Setting] = [
            OpenWithSetting(settings: self),
            BoolSetting(prefs: prefs, prefKey: "blockPopups", defaultValue: true,
                        titleText: NSLocalizedString("Block Pop-up Windows", comment: "Block pop-up windows setting")),
        ]

        if #available(iOS 12.0, *) {
            generalSettings.insert(SiriPageSetting(settings: self), at: 1)
        }

        // There is nothing to show in the Customize section if we don't include the compact tab layout
        // setting on iPad. When more options are added that work on both device types, this logic can
        // be changed.
        generalSettings += [
            BoolSetting(prefs: prefs, prefKey: "showClipboardBar", defaultValue: false,
                        titleText: Strings.Toast.SettingsOfferClipboardBarTitle,
                        statusText: Strings.Toast.SettingsOfferClipboardBarStatus),
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.General.SectionTitle), children: generalSettings)
    }

    private func newsSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let newsSettigns = [
            NewsLanguageSetting(currentRegion: self.newsCurrentRegion, availableRegions: self.newsAvailableRegions),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.NewTabNewsEnabled, defaultValue: true, titleText: Strings.Settings.News.NewsFromNewTabPage),
            BoolSetting(prefs: prefs, prefKey: PrefsKeys.NewTabNewsImagesEnabled, defaultValue: true, titleText: Strings.Settings.News.NewsImages),
        ]
        return SettingSection(title: NSAttributedString(string: Strings.Settings.News.SectionTitle), children: newsSettigns)
    }

    private func supportSettingSection() -> SettingSection {
        let prefs = self.profile.prefs
        let supportSettigns = [
            ShowIntroductionSetting(settings: self),
            SendFeedbackSetting(),
            BoolSetting(prefs: prefs, prefKey: AppConstants.PrefSendUsageData, defaultValue: true, attributedTitleText: NSAttributedString(string: Strings.Settings.SendUsage.Title), attributedStatusText: NSAttributedString(string: Strings.Settings.SendUsage.Message, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.headerTextLight])),
        ]
        return SettingSection(title: NSAttributedString(string: NSLocalizedString("Support", comment: "Support section title")), children: supportSettigns)
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
        return SettingSection(title: NSAttributedString(string: NSLocalizedString("About", comment: "About settings section title")), children: aboutSettings)
    }

}
