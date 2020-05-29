//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

extension Features.Search.AdditionalSearchEngines {
    public static var isEnabled: Bool {
        return true
    }
}

extension Features.Search {
    public static var keyboardReturnKeyBehavior: Features.Search.KeyboardReturnKeyBehavior {
        return .search
    }
    public static var defaultEngineName: String {
        return "google"
    }
}

extension Features.Search.QuickSearch {
    public static var isEnabled: Bool {
        return false
    }
}

extension Features.ControlCenter.PrivacyStats.SearchStats {
    public static var isEnabled: Bool {
        return false
    }
}

extension Features.Home.DynamicBackgrounds {
    public static var isEnabled: Bool {
        return false
    }
}
