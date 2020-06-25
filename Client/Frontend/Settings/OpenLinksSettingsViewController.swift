//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class OpenLinksSettingsViewController: SettingsTableViewController {

    private var selectedSetting: TabManager.OpenLinks

    init(profile: Profile, selectedSetting: TabManager.OpenLinks) {
        self.selectedSetting = selectedSetting
        super.init(style: .grouped)
        self.profile = profile
        self.title = Strings.Settings.General.OpenLinks.SectionName
        self.hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let searchSettings: [CheckmarkSetting] = TabManager.OpenLinks.allCases.map { seting in
            return CheckmarkSetting(title: NSAttributedString(string: seting.title), subtitle: nil, accessibilityIdentifier: "\(seting.rawValue)", isEnabled: {
                return seting.rawValue == self.selectedSetting.rawValue
            }, onChanged: {
                self.selectedSetting = seting
                self.profile.prefs.setInt(seting.rawValue, forKey: PrefsKeys.OpenLinks)
                self.tableView.reloadData()
            })
        }
        return [SettingSection(children: searchSettings)]
    }

}
