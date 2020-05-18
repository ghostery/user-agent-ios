/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import LocalAuthentication

// This file contains all of the settings available in the main settings screen of the app.

private var ShowDebugSettings: Bool = false
private var DebugSettingsClickCount: Int = 0

// For great debugging!
class HiddenSetting: Setting {
    unowned let settings: SettingsTableViewController

    init(settings: SettingsTableViewController) {
        self.settings = settings
        super.init(title: nil)
    }

    override var hidden: Bool {
        return !ShowDebugSettings
    }
}

// For great debugging!
class DeleteExportedDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: delete exported databases", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: documentsPath)
            for file in files {
                if file.hasPrefix("browser.") || file.hasPrefix("logins.") {
                    try fileManager.removeItemInDirectory(documentsPath, named: file)
                }
            }
        } catch {
            print("Couldn't delete exported data: \(error).")
        }
    }
}

class ExportBrowserDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: copy databases to app container", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        do {
            let log = Logger.syncLogger
            try self.settings.profile.files.copyMatching(fromRelativeDirectory: "", toAbsoluteDirectory: documentsPath) { file in
                log.debug("Matcher: \(file)")
                return file.hasPrefix("browser.") || file.hasPrefix("logins.") || file.hasPrefix("metadata.")
            }
        } catch {
            print("Couldn't export browser data: \(error).")
        }
    }
}

class ExportLogDataSetting: HiddenSetting {
    override var title: NSAttributedString? {
        // Not localized for now.
        return NSAttributedString(string: "Debug: copy log files to app container", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        Logger.copyPreviousLogsToDocuments()
    }
}

class ForceCrashSetting: HiddenSetting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: "Debug: Force Crash", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        Sentry.shared.crash()
    }
}

class SlowTheDatabase: HiddenSetting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: "Debug: simulate slow database operations", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        debugSimulateSlowDBOperations.toggle()
    }
}

class SentryIDSetting: HiddenSetting {
    let deviceAppHash = UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)?.string(forKey: "SentryDeviceAppHash") ?? "0000000000000000000000000000000000000000"
    override var title: NSAttributedString? {
        return NSAttributedString(string: "Debug: \(deviceAppHash)", attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 10)])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        copyAppDeviceIDAndPresentAlert(by: navigationController)
    }

    func copyAppDeviceIDAndPresentAlert(by navigationController: UINavigationController?) {
        let alertTitle = Strings.Settings.CopyAppVersionAlertTitle
        let alert = AlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        getSelectedCell(by: navigationController)?.setSelected(false, animated: true)
        UIPasteboard.general.string = deviceAppHash
        navigationController?.topViewController?.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }

    func getSelectedCell(by navigationController: UINavigationController?) -> UITableViewCell? {
        let controller = navigationController?.topViewController
        let tableView = (controller as? AppSettingsTableViewController)?.tableView
        guard let indexPath = tableView?.indexPathForSelectedRow else { return nil }
        return tableView?.cellForRow(at: indexPath)
    }
}

// Show the current version of Firefox
class VersionSetting: Setting {
    unowned let settings: SettingsTableViewController

     override var accessibilityIdentifier: String? { return "FxVersion" }

    init(settings: SettingsTableViewController) {
        self.settings = settings
        super.init(title: nil)
    }

    override var title: NSAttributedString? {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let buildNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String
        return NSAttributedString(string: String(format: Strings.Settings.About.Version, appVersion, buildNumber), attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override func onClick(_ navigationController: UINavigationController?) {
        DebugSettingsClickCount += 1
        if DebugSettingsClickCount >= 5 {
            DebugSettingsClickCount = 0
            ShowDebugSettings.toggle()
            settings.tableView.reloadData()
        }
    }

    override func onLongPress(_ navigationController: UINavigationController?) {
        copyAppVersionAndPresentAlert(by: navigationController)
    }

    func copyAppVersionAndPresentAlert(by navigationController: UINavigationController?) {
        let alertTitle = Strings.Settings.CopyAppVersionAlertTitle
        let alert = AlertController(title: alertTitle, message: nil, preferredStyle: .alert)
        getSelectedCell(by: navigationController)?.setSelected(false, animated: true)
        UIPasteboard.general.string = self.title?.string
        navigationController?.topViewController?.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true)
            }
        }
    }

    func getSelectedCell(by navigationController: UINavigationController?) -> UITableViewCell? {
        let controller = navigationController?.topViewController
        let tableView = (controller as? AppSettingsTableViewController)?.tableView
        guard let indexPath = tableView?.indexPathForSelectedRow else { return nil }
        return tableView?.cellForRow(at: indexPath)
    }
}

// Opens the license page in a new tab
class LicenseAndAcknowledgementsSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: Strings.Settings.About.Licenses, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override var url: URL? {
        return URL(string: "\(InternalURL.baseUrl)/\(AboutLicenseHandler.path)")
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
    }
}

// Opens the on-boarding screen again
class ShowIntroductionSetting: Setting {
    let profile: Profile

    override var accessibilityIdentifier: String? { return "ShowTour" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: Strings.Settings.Support.ShowTour, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.dismiss(animated: true, completion: {
            BrowserViewController.foregroundBVC().setPhoneWindowBackground(color: Theme.browser.background)
            BrowserViewController.foregroundBVC().presentOnboarding(true)
        })
    }
}

class SendFeedbackSetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: Strings.Settings.Support.FAQAndSupport, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override var url: URL? {
        return URL(string: Strings.FeedbackWebsite)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
    }
}

// Opens the search settings pane
class SearchSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "Search" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: Strings.Settings.Search.AdditionalSearchEngines.SectionTitle, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = SearchSettingsTableViewController()
        viewController.model = profile.searchEngines
        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// Opens the search results for language settings
class SearchLanguageSetting: Setting {

    private var currentRegion: Search.Country?
    private var availableRegions: [Search.Country]?

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var style: UITableViewCell.CellStyle { return .value1 }

    override var status: NSAttributedString? { return NSAttributedString(string: self.currentRegion?.name ?? "") }

    override var accessibilityIdentifier: String? { return "Search Results" }

    init(currentRegion: Search.Country?, availableRegions: [Search.Country]?) {
        self.currentRegion = currentRegion
        self.availableRegions = availableRegions
        super.init(title: NSAttributedString(string: Strings.Settings.Search.SearchResultForLanguage.Title, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        guard let region = self.currentRegion, let regions = self.availableRegions else {
            return
        }
        let viewController = SearchResultsSettingsViewController(selectedRegion: region, availableRegions: regions)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// Opens the News for language settings
class NewsLanguageSetting: Setting {

    private var currentRegion: News.Country?
    private var availableRegions: [News.Country]?

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var style: UITableViewCell.CellStyle { return .value1 }

    override var status: NSAttributedString? { return NSAttributedString(string: self.currentRegion?.name ?? "") }

    override var accessibilityIdentifier: String? { return "News" }

    init(currentRegion: News.Country?, availableRegions: [News.Country]?) {
        self.currentRegion = currentRegion
        self.availableRegions = availableRegions
        super.init(title: NSAttributedString(string: Strings.Settings.News.Language.Title, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        guard let region = self.currentRegion, let regions = self.availableRegions else {
            return
        }
        let viewController = NewsLanguagesSettingsViewController(selectedRegion: region, availableRegions: regions)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class ClearPrivateDataSetting: Setting {
    let profile: Profile
    var tabManager: TabManager!

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "ClearPrivateData" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        self.tabManager = settings.tabManager

        let clearTitle = Strings.Settings.Privacy.DataManagement.SectionName
        super.init(title: NSAttributedString(string: clearTitle, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = ClearPrivateDataTableViewController()
        viewController.profile = profile
        viewController.tabManager = tabManager
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class TodayWidgetSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var style: UITableViewCell.CellStyle { return .value1 }

    override var status: NSAttributedString? {
        guard let name = self.profile.prefs.stringForKey(PrefsKeys.TodayWidgetWeatherLocation) else {
            return nil
        }
        return NSAttributedString(string: name)
    }

    override var accessibilityIdentifier: String? { return "TodayWidgetSetting" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        let clearTitle = Strings.Settings.TodayWidget.Title
        super.init(title: NSAttributedString(string: clearTitle, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = TodayWidgetViewController()
        viewController.profile = self.profile
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class PrivacyPolicySetting: Setting {
    override var title: NSAttributedString? {
        return NSAttributedString(string: Strings.Settings.Support.PrivacyPolicy, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText])
    }

    override var url: URL? {
        return URL(string: Strings.PrivacyPolicyWebsite)
    }

    override func onClick(_ navigationController: UINavigationController?) {
        setUpAndPushSettingsContentViewController(navigationController)
    }
}

@available(iOS 12.0, *)
class SiriPageSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "SiriSettings" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.Settings.General.Siri.SectionName, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = SiriSettingsViewController(prefs: profile.prefs)
        viewController.profile = profile
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class OpenWithSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "OpenWith.Setting" }

    override var status: NSAttributedString {
        guard let provider = self.profile.prefs.stringForKey(PrefsKeys.KeyMailToOption), provider != "mailto:" else {
            return NSAttributedString(string: "")
        }
        if let path = Bundle.main.path(forResource: "MailSchemes", ofType: "plist"), let dictRoot = NSArray(contentsOfFile: path) {
            let mailProvider = dictRoot.compactMap({$0 as? NSDictionary }).first { (dict) -> Bool in
                return (dict["scheme"] as? String) == provider
            }
            return NSAttributedString(string: (mailProvider?["name"] as? String) ?? "")
        }
        return NSAttributedString(string: "")
    }

    override var style: UITableViewCell.CellStyle { return .value1 }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.Settings.General.OpenWith.SectionName, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        let viewController = OpenWithSettingsViewController(prefs: profile.prefs)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class NewTabPageDefaultViewSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "DefaultView.Setting" }

    override var status: NSAttributedString {
        guard let segment = self.profile.prefs.intForKey(PrefsKeys.NewTabPageDefaultView) else {
            return NSAttributedString(string: HomeViewController.Segment.defaultValue.title)
        }
        let title = HomeViewController.Segment(rawValue: segment)?.title ?? ""
        return NSAttributedString(string: title)
    }

    override var style: UITableViewCell.CellStyle { return .value1 }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.Settings.General.NewTabPageDefaultView.SectionName, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        var selectedSegment: HomeViewController.Segment!
        if let segment = self.profile.prefs.intForKey(PrefsKeys.NewTabPageDefaultView) {
            selectedSegment = HomeViewController.Segment(rawValue: segment)
        } else {
            selectedSegment = HomeViewController.Segment.defaultValue
        }
        let availableSegments: [HomeViewController.Segment] = [.topSites, .bookmarks, .history]
        let viewController = NewTabDefaultViewSettingsViewController(profile: self.profile, selectedSegment: selectedSegment, availableSegments: availableSegments)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class OnBrowserStartShowSetting: Setting {
    let profile: Profile

    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "OnBrowserStartShow.Setting" }

    override var status: NSAttributedString {
        guard let segment = self.profile.prefs.intForKey(PrefsKeys.OnBrowserStartTab) else {
            return NSAttributedString(string: TabManager.StartTab.defaultValue.title)
        }
        let title = TabManager.StartTab(rawValue: segment)?.title ?? ""
        return NSAttributedString(string: title)
    }

    override var style: UITableViewCell.CellStyle { return .value1 }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile

        super.init(title: NSAttributedString(string: Strings.Settings.General.OnBrowserStartTab.SectionName, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        var selectedStartTab: TabManager.StartTab!
        if let startTab = self.profile.prefs.intForKey(PrefsKeys.OnBrowserStartTab) {
            selectedStartTab = TabManager.StartTab(rawValue: startTab)
        } else {
            selectedStartTab = TabManager.StartTab.defaultValue
        }
        let availableStartTabs: [TabManager.StartTab] = [.lastOpenedTab, .newTab]
        let viewController = OnBrowserStartShowSettingsViewController(profile: self.profile, selectedStartTab: selectedStartTab, availableStartTabs: availableStartTabs)
        navigationController?.pushViewController(viewController, animated: true)
    }
}

class TranslationSetting: Setting {
    let profile: Profile
    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }
    override var style: UITableViewCell.CellStyle { return .value1 }
    override var accessibilityIdentifier: String? { return "TranslationOption" }

    init(settings: SettingsTableViewController) {
        self.profile = settings.profile
        super.init(title: NSAttributedString(string: Strings.Settings.TranslateSnackBar.Title, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        navigationController?.pushViewController(TranslationSettingsController(profile), animated: true)
    }
}
