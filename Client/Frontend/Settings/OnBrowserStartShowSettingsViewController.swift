//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class OnBrowserStartShowSettingsViewController: SettingsTableViewController {

    private var selectedStartTab: TabManager.StartTab
    private var availableStartTabs: [TabManager.StartTab]

    init(profile: Profile, selectedStartTab: TabManager.StartTab, availableStartTabs: [TabManager.StartTab]) {
        self.selectedStartTab = selectedStartTab
        self.availableStartTabs = availableStartTabs
        super.init(style: .grouped)
        self.profile = profile
        self.title = Strings.Settings.OnBrowserStartTab.SectionName
        self.hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let searchSettings: [CheckmarkSetting] = self.availableStartTabs.map { startTab in
            return CheckmarkSetting(title: NSAttributedString(string: startTab.title), subtitle: nil, accessibilityIdentifier: "\(startTab.rawValue)", isEnabled: {
                return startTab.rawValue == self.selectedStartTab.rawValue
            }, onChanged: {
                self.selectedStartTab = startTab
                self.profile.prefs.setInt(startTab.rawValue, forKey: PrefsKeys.OnBrowserStartTab)
                self.tableView.reloadData()
            })
        }
        return [SettingSection(children: searchSettings)]
    }

}
