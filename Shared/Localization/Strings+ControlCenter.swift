//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// MARK: - Control Center
extension Strings {
    public struct ControlCenter {
        public struct PrivacyProtection {
            public static let Title = NSLocalizedString("ControlCenter.PrivacyProtection.Title", tableName: "ControlCenter", comment: "Title")
            public static let AdsBlocked = NSLocalizedString("ControlCenter.PrivacyProtection.AdsBlocked", tableName: "ControlCenter", comment: "Ads Blocked label")
            public static let TrackersBlocked = NSLocalizedString("ControlCenter.PrivacyProtection.TrackersBlocked", tableName: "ControlCenter", comment: "Trackers Blocked label")
        }
        public struct SearchStats {
            public static let Title = NSLocalizedString("ControlCenter.SearchStats.Title", tableName: "ControlCenter", comment: "Title")
            public static let CliqzSearch = NSLocalizedString("ControlCenter.SearchStats.CliqzSearch", tableName: "ControlCenter", comment: "Cliqz Search")
            public static let OtherSearch = NSLocalizedString("ControlCenter.SearchStats.OtherSearch", tableName: "ControlCenter", comment: "Other Search")
        }
    }
}
