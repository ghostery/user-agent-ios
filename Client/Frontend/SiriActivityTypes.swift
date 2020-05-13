//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

enum SiriActivityTypes {
    case openURL
    case searchWith

    init?(value: String) {
        switch value {
        case "org.\(AppInfo.displayName).newTab":
            self = .openURL
        case "org.\(AppInfo.displayName).searchWith":
            self = .searchWith
        default:
            return nil
        }
    }

    var value: String {
        switch self {
        case .openURL:
            return "org.\(AppInfo.displayName).newTab"
        case .searchWith:
            return "org.\(AppInfo.displayName).searchWith"
        }
    }
}
