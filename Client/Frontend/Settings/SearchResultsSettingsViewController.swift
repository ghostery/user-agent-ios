//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class SearchResultsSettingsViewController: SettingsTableViewController {

    private let prefs: Prefs

    private var selectedRegion: Search.Region

    init(prefs: Prefs) {
        self.prefs = prefs
        if let regionKey = prefs.stringForKey(PrefsKeys.KeySearchResultsLanguage), let region = Search.Region(rawValue: regionKey) {
            self.selectedRegion = region
        } else {
            self.selectedRegion = Search.defaultConfig.selected
        }
        super.init(style: .grouped)
        self.title = Strings.SettingsSearchResultForLanguage
        self.hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let searchSettings: [CheckmarkSetting] = Search.Region.allCases.map { region in
            return CheckmarkSetting(title: NSAttributedString(string: region.title), subtitle: nil, accessibilityIdentifier: region.rawValue, isEnabled: {
                return region == self.selectedRegion
            }, onChanged: {
                self.selectedRegion = region
                self.prefs.setString(self.selectedRegion.rawValue, forKey: PrefsKeys.KeySearchResultsLanguage)
                Search.setBackendCountry(country: region)
                self.tableView.reloadData()
            })
        }
        return [SettingSection(children: searchSettings)]
    }

}
