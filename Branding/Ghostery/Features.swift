//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

extension Features.BrowserCore {
    public static var configUrl: String {
        return "https://api.ghostery.net/api/v1/config"
    }
}

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
        return "GhosteryGlow"
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

extension Features.HumanWeb {
    public static var isEnabled: Bool {
        return true
    }
    public static var collectorDirectUrl: String {
        return "https://collector-hpn.ghostery.net"
    }
    public static var collectorProxyUrl: String {
        return "https://collector-hpn.ghostery.net"
    }
}

extension Features.Telemetry {
    public static var brand: String {
        return "ghostery"
    }
    public static var anolysisUrl: String {
        return "https://anolysis.privacy.ghostery.net"
    }
    public static var anolysisStagingUrl: String {
        return "https://anolysis-staging.privacy.ghostery.net"
    }
}

extension Features.PrivacyDashboard.ReportPage {
    public static var isEnabled: Bool {
        return false
    }
}
