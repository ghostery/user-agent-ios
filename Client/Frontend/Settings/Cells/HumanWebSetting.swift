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
    convenience init(prefs: Prefs) {
        self.init(
            prefs: prefs,
            defaultValue: false,
            titleText: Strings.Settings.HumanWebTitle,
            enabled: true
        ) { (value) in
            if value {
                HumanWebFeature.enable()
            } else {
                HumanWebFeature.disable()
            }
        }

        HumanWebFeature.isEnabled { (isEnabled) in
            self.setState(isEnabled)
        }
    }
}
