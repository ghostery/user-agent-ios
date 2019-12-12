//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class TelemetrySetting: BoolSetting {
    convenience init(prefs: Prefs, attributedStatusText: NSAttributedString) {
        self.init(
            prefs: prefs,
            prefKey: AppConstants.PrefSendUsageData,
            defaultValue: true,
            attributedTitleText:
                NSAttributedString(string: Strings.Settings.SendUsage.Title),
            attributedStatusText: attributedStatusText
        )
    }
}
