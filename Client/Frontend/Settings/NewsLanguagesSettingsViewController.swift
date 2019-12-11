//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class NewsLanguagesSettingsViewController: SettingsTableViewController {

    private var selectedRegion: News.Country
    private var availableRegions: [News.Country]

    init(selectedRegion: News.Country, availableRegions: [News.Country]) {
        self.selectedRegion = selectedRegion
        self.availableRegions = availableRegions
        super.init(style: .grouped)
        self.title = Strings.Settings.News.Language.Title
        self.hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let newsLanguagesSettings: [CheckmarkSetting] = self.availableRegions.map { region in
            return CheckmarkSetting(title: NSAttributedString(string: region.name), subtitle: nil, accessibilityIdentifier: region.key, isEnabled: {
                return region.key == self.selectedRegion.key
            }, onChanged: {
                self.selectedRegion = region
                News.setBackendCountry(country: region)
                NotificationCenter.default.post(name: .NewsSettingsDidChange, object: nil)
                self.tableView.reloadData()
            })
        }
        return [SettingSection(children: newsLanguagesSettings)]
    }

}
