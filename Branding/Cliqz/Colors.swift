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
    static let Grey40 = DarkRain * 0.4 + White * 0.6
}
