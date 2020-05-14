//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

enum SiriActivityTypes {
    case openURL
    case searchWith

    init?(value: String) {
        switch value {
        case "\(Self.baseBundleIdentifier).newTab":
            self = .openURL
        case "\(Self.baseBundleIdentifier).searchWith":
            self = .searchWith
        default:
            return nil
        }
    }

    var value: String {
        switch self {
        case .openURL:
            return "\(Self.baseBundleIdentifier).newTab"
        case .searchWith:
            return "\(Self.baseBundleIdentifier).searchWith"
        }
    }

    // MARK: - Private methods

    private static var baseBundleIdentifier: String {
        let bundle = Bundle.main
        let packageType = bundle.object(forInfoDictionaryKey: "CFBundlePackageType") as! String
        let baseBundleIdentifier = bundle.bundleIdentifier!
        if packageType == "XPC!" {
            let components = baseBundleIdentifier.components(separatedBy: ".")
            return components[0..<components.count-1].joined(separator: ".")
        }
        return baseBundleIdentifier
    }

}
