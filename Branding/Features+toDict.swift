//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

extension Features {
    // For some reason Swift does not apply extensions to Featuers stucts if
    // this function is defined in Shared
    public static func toDict() -> [String: Any] {
        return [
            "BrowserCore": [
                "configUrl": Features.BrowserCore.configUrl,
            ],
            "Search": [
                "AdditionalSearchEngines": [
                    "isEnabled": Features.Search.AdditionalSearchEngines.isEnabled,
                ],
                "QuickSearch": [
                    "isEnabled": Features.Search.QuickSearch.isEnabled,
                ],
            ],
            "ControlCenter": [
                "PrivacyStats": [
                    "SearchStats": [
                        "isEnabled": Features.ControlCenter.PrivacyStats.SearchStats.isEnabled,
                    ],
                ],
            ],
            "Home": [
                "DynamicBackgrounds": [
                    "isEnabled": Features.Home.DynamicBackgrounds.isEnabled,
                ],
            ],
            "Icons": [
                "type": Features.Icons.type.rawValue,
            ],
            "HumanWeb": [
                "collectorDirectUrl": Features.HumanWeb.collectorDirectUrl,
                "collectorProxyUrl": Features.HumanWeb.collectorProxyUrl,
            ],
            "Telemetry": [
                "anolysisUrl": Features.Telemetry.anolysisUrl,
                "anolysisStagingUrl": Features.Telemetry.anolysisStagingUrl,
            ],
        ]
    }
}
