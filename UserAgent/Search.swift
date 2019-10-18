//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

public class Search {

    public enum AdultFilterMode: String, CaseIterable {
        case liberal
        case conservative
    }

    public struct Region {
        public var key: String
        public var name: String
    }

    public struct Config {
        public var selected: Region
        public var available: [Region]
    }

    private static let defaultRegion = Region(key: "de", name: Strings.SettingsSearchResultForGerman)

    static let defaultConfig = Config(selected: Search.defaultRegion, available: [Search.defaultRegion])

}

extension Search: BrowserCoreClient {

    public static func getBackendCountries(callback: @escaping (Config) -> Void) {
        self.browserCore.callAction(
            module: "search",
            action: "getBackendCountries",
            args: []
        ) { (error, result) in
            if error != nil {
                DispatchQueue.main.async {
                    callback(Self.defaultConfig)
                }
                return
            }

            guard let backends = result as? [String: [String: Any]] else {
                DispatchQueue.main.async {
                    callback(Self.defaultConfig)
                }
                return
            }
            var selectedRegion: Region!
            let selectedKey = backends.first { ($0.value["selected"] as? Bool) ?? false }?.key
            if let key = selectedKey, let selected = backends[key], let name = selected["name"] as? String {
                selectedRegion = Region(key: key, name: name)
            } else {
                selectedRegion = self.defaultRegion
            }
            var availableRegions = [Region]()
            for key in backends.keys.sorted() {
                if let name = backends[key]?["name"] as? String {
                    let region = Region(key: key, name: name)
                    availableRegions.append(region)
                }
            }
            let config = Config(selected: selectedRegion, available: availableRegions)
            DispatchQueue.main.async {
                callback(config)
            }
        }
    }

    public static func setBackendCountry(country: Region) {
        self.browserCore.callAction(
            module: "search",
            action: "setBackendCountry",
            args: [country.key]
        )
    }

    public static func getAdultFilter(callback: @escaping (AdultFilterMode) -> Void) {
        self.browserCore.callAction(
            module: "search",
            action: "getAduleFilter",
            args: []
        ) { (error, result) in
            guard error == nil, let mode = result as? String else {
                DispatchQueue.main.async {
                    callback(.conservative)
                }
                return
            }
            DispatchQueue.main.async {
                callback(AdultFilterMode(rawValue: mode) ?? .conservative)
            }
        }
    }

    public static func setAdultFilter(filter: AdultFilterMode) {
        self.browserCore.callAction(
            module: "search",
            action: "setAduleFilter",
            args: [filter.rawValue]
        )
    }

}
