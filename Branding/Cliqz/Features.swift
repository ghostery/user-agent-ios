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
        return .dismiss
    }
    public static var defaultEngineName: String {
        return "Cliqz"
    }
}

extension Features.Search.QuickSearch {
    public static var isEnabled: Bool {
        return true
    }
}

extension Features.PrivacyDashboard {
    public static var isAntiTrackingEnabled: Bool {
        return true
    }
    public static var isAdBlockingEnabled: Bool {
        return true
    }
    public static var isPopupBlockerEnabled: Bool {
        return true
    }
}

extension Features.News {
    public static var isEnabled: Bool {
        return false
    }
}

extension Features.Icons {
    public static var type: IconType {
        return .cliqz
    }
}

extension Features.AntiPhishing {
    public static var isEnabled: Bool {
        return false
    }
}

extension Features.ControlCenter.PrivacyStats.SearchStats {
    public static var isEnabled: Bool {
        return false
    }
}

extension Features.Telemetry {
    public static var isEnabled: Bool {
        return true
    }
}

extension Features.TodayWidget {
    public static var isEnabled: Bool {
        return true
    }
}
