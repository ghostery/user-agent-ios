//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class HumanWebSetting: BoolSetting {
    convenience init(prefs: Prefs, attributedStatusText: NSAttributedString? = nil) {
        self.init(
            prefs: prefs,
            defaultValue: false,
            attributedTitleText: NSAttributedString(string: Strings.Settings.Support.HumanWebTitle, attributes: [NSAttributedString.Key.foregroundColor: Theme.tableView.rowText]),
            attributedStatusText: attributedStatusText,
            enabled: false
        ) { (value) in
            if value {
                HumanWebFeature.enable()
            } else {
                HumanWebFeature.disable()
            }
        }
    }

    override func displayBool(_ control: UISwitch) {
        HumanWebFeature.isEnabled { (isEnabled) in
            DispatchQueue.main.async {
                control.isEnabled = true
                control.isOn = isEnabled
            }
        }
    }
}
