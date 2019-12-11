//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

public class News {

    public struct Country {
        public var key: String
        public var name: String
    }

    public struct Config {
        public var selected: Country
        public var available: [Country]
    }

    private static let defaultRegion = Country(key: "de", name: Strings.Settings.News.Language.German)

    static let defaultConfig = Config(selected: News.defaultRegion, available: [News.defaultRegion])

}

extension News: BrowserCoreClient {

    public static func getAvailableLanguages(callback: @escaping (Config) -> Void) {
        self.browserCore.callAction(
            module: "news",
            action: "getAvailableLanguages",
            args: []
        ) { (error, result) in
            if error != nil {
                callback(Self.defaultConfig)
                return
            }
            guard let backends = result as? [[String: Any]] else {
                callback(Self.defaultConfig)
                return
            }
            var selectedRegion: Country = self.defaultRegion
            var availableRegions = [Country]()
            backends.forEach { (language) in
                if let name = language["name"] as? String, let key = language["code"] as? String {
                    let country = Country(key: key, name: name)
                    if let isSelected = language["isSelected"] as? Bool, isSelected {
                        selectedRegion = country
                    }
                    availableRegions.append(country)
                }
            }
            let config = Config(selected: selectedRegion, available: availableRegions)
            callback(config)
        }
    }

    public static func setBackendCountry(country: Country) {
        self.browserCore.callAction(
            module: "news",
            action: "setLanguage",
            args: [country.key]
        )
    }

}
