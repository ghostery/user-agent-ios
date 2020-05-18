//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class NewTabDefaultViewSettingsViewController: SettingsTableViewController {

    private var selectedSegment: HomeViewController.Segment
    private var availableSegments: [HomeViewController.Segment]

    init(profile: Profile, selectedSegment: HomeViewController.Segment, availableSegments: [HomeViewController.Segment]) {
        self.selectedSegment = selectedSegment
        self.availableSegments = availableSegments
        super.init(style: .grouped)
        self.profile = profile
        self.title = Strings.Settings.General.NewTabPageDefaultView.SectionName
        self.hasSectionSeparatorLine = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func generateSettings() -> [SettingSection] {
        let searchSettings: [CheckmarkSetting] = self.availableSegments.map { segment in
            return CheckmarkSetting(title: NSAttributedString(string: segment.title), subtitle: nil, accessibilityIdentifier: "\(segment.rawValue)", isEnabled: {
                return segment.rawValue == self.selectedSegment.rawValue
            }, onChanged: {
                self.selectedSegment = segment
                self.profile.prefs.setInt(segment.rawValue, forKey: PrefsKeys.NewTabPageDefaultView)
                self.tableView.reloadData()
                NotificationCenter.default.post(name: .NewTabPageDefaultViewSettingsDidChange, object: nil)
            })
        }
        return [SettingSection(children: searchSettings)]
    }

}
