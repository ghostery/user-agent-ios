//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class Search {

}

extension Search: BrowserCoreClient {
    private static let defaultConfig = Config(selected: "de", available: ["de"])

    public struct Config {
        public var selected: String
        public var available: [String]
    }

    public enum AdultFilterMode: String, CaseIterable {
        case liberal
        case conservative
    }

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

            let config = Config(
                selected: backends.first { ($0.value["selected"] as? Bool) ?? false == true }?.key ?? "de",
                available: Array(backends.keys)
            )

            callback(config)
        }
    }

    public static func setBackendCountry(country: String) {
        browserCore.callAction(
            module: "search",
            action: "getBackendCountries",
            args: [country]
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
}
