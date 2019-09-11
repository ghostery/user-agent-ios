//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

extension UIColor {
    // Primary Colors
    static let CliqzBlue = UIColor(rgb: 0x00AEF0)
    static let CliqzBlack = UIColor(rgb: 0x1A1A25)
    static let White = UIColor(rgb: 0xFFFFFF)

    // Secondary Colors
    static let DarkRain = UIColor(rgb: 0x607c85)
    static let CloudySky = UIColor(rgb: 0xBFCBD6)
    static let LightSky = UIColor(rgb: 0xE7ECEE)
    static let BrightBlue = UIColor(rgb: 0x0078CA)
    static let DarkBlue = UIColor(rgb: 0x2B5993)

    // Functional Colors
    static let Purple = UIColor(rgb: 0x930194)
    static let LightGreen = UIColor(rgb: 0x9ECC42)
    static let DarkGreen = UIColor(rgb: 0x67A73A)
    static let BrightRed = UIColor(rgb: 0xFF7E74)
    static let NeutralGrey = UIColor(rgb: 0x97A4AE)
}

extension UIColor {
    static let Blue40 = CliqzBlue * 0.4 + White * 0.6
    static let Blue50 = CliqzBlue * 0.5 + White * 0.5
    static let Blue60 = CliqzBlue * 0.6 + White * 0.4

    static let Grey10 = DarkRain * 0.1 + White * 0.9
    static let Grey20 = DarkRain * 0.2 + White * 0.2
    static let Grey25 = DarkRain * 0.25 + White * 0.75
    static let Grey30 = DarkRain * 0.3 + White * 0.7
    static let Grey40 = DarkRain * 0.4 + White * 0.6
    static let Grey50 = DarkRain * 0.5 + White * 0.5
    static let Grey60 = DarkRain * 0.6 + White * 0.4
    static let Grey70 = DarkRain * 0.7 + White * 0.3
    static let Grey80 = DarkRain * 0.8 + White * 0.2
    static let Grey90 = DarkRain * 0.9 + White * 0.1
}
