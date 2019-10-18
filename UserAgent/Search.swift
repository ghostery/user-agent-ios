//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

class Search {

    enum Region: String {
        case de = "de"
        case fr = "fr"
        case us = "us"
        case it = "it"
        case es = "es"
        case gb = "gb"

        var title: String {
            switch self {
            case .de:
                return Strings.SettingsSearchResultForGerman
            case .fr:
                return Strings.SettingsSearchResultForFrance
            case .us:
                return Strings.SettingsSearchResultForUnitedStates
            case .it:
                return Strings.SettingsSearchResultForItaly
            case .es:
                return Strings.SettingsSearchResultForSpain
            case .gb:
                return Strings.SettingsSearchResultForUnitedKingdom
            }
        }

        static var allCases: [Region] {
            return [.de, .fr, .us, .it, .es, .gb]
        }
    }

    public enum AdultFilterMode: String, CaseIterable {
        case liberal
        case conservative
    }

    public struct Config {
        public var selected: Search.Region
        public var available: [Search.Region]
    }

    static let defaultConfig = Config(selected: Search.Region.de, available: [Search.Region.de])

}

extension Search: BrowserCoreClient {

    public static func getBackendCountries(callback: @escaping (Config) -> Void) {
        browserCore.callAction(
            module: "search",
            action: "getBackendCountries",
            args: []
        ) { (error, result) in
            if error != nil {
                callback(Self.defaultConfig)
                return
            }

            guard let backends = result as? [String: [String: Any]] else {
                callback(Self.defaultConfig)
                return
            }
            let selectedKey = backends.first { ($0.value["selected"] as? Bool) ?? false == true }?.key ?? ""
            let selected = Search.Region(rawValue: selectedKey) ?? Search.Region(rawValue: "de")!
            var available = [Search.Region]()
            for item in backends.keys {
                if let region = Search.Region(rawValue: item) {
                    available.append(region)
                }
            }
            let config = Config(
                selected: selected,
                available: available
            )

            callback(config)
        }
    }

    public static func setBackendCountry(country: Search.Region) {
        browserCore.callAction(
            module: "search",
            action: "setBackendCountries",
            args: [country.rawValue]
        )
    }

    public static func getAduleFilter(callback: @escaping (AdultFilterMode) -> Void) {
        browserCore.callAction(
            module: "search",
            action: "getAduleFilter",
            args: []
        ) { (error, result) in
            guard error == nil, let mode = result as? String else {
                callback(.conservative)
                return
            }
            callback(AdultFilterMode(rawValue: mode) ?? .conservative)
        }
    }

    public static func setAduleFilter(filter: AdultFilterMode) {
        browserCore.callAction(
            module: "search",
            action: "setAduleFilter",
            args: [filter.rawValue]
        )
    }

}
