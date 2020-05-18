/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Intents
import IntentsUI

@available(iOS 12.0, *)
class SiriSettingsViewController: SettingsTableViewController {
    let prefs: Prefs

    init(prefs: Prefs) {
        self.prefs = prefs
        super.init(style: .grouped)

        self.title = Strings.Settings.General.Siri.SectionName
        hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let setting = SiriOpenURLSetting(settings: self)
        let searchWithQliqzSetting = SiriSearchWithQliqzSetting(settings: self)
        let firstSection = SettingSection(title: nil, footerTitle: NSAttributedString(string: Strings.Settings.General.Siri.SectionDescription), children: [setting, searchWithQliqzSetting])
        return [firstSection]
    }
}

@available(iOS 12.0, *)
class SiriOpenURLSetting: Setting {
    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "SiriSettings" }

    init(settings: SettingsTableViewController) {
        super.init(title: NSAttributedString(string: Strings.Settings.General.Siri.OpenURL, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        if let vc = navigationController?.topViewController {
            SiriShortcuts.manageSiri(for: SiriActivityTypes.openURL, in: vc)
        }
    }
}

@available(iOS 12.0, *)
class SiriSearchWithQliqzSetting: Setting {
    override var accessoryType: UITableViewCell.AccessoryType { return .disclosureIndicator }

    override var accessibilityIdentifier: String? { return "SiriSearchWithQliqzSetting" }

    init(settings: SettingsTableViewController) {
        super.init(title: NSAttributedString(string: Strings.Settings.General.Siri.SearchWith + AppInfo.displayName, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]))
    }

    override func onClick(_ navigationController: UINavigationController?) {
        if let vc = navigationController?.topViewController {
            SiriShortcuts.manageSiri(for: SiriActivityTypes.searchWith, in: vc)
        }
    }
}

@available(iOS 12.0, *)
extension SiriSettingsViewController: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

@available(iOS 12.0, *)
extension SiriSettingsViewController: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }

    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
