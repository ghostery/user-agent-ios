//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct AccessibilityLabels {
        public struct Intro {
            public static let TourCarousel = NSLocalizedString("AccessibilityLabels.Intro.TourCarousel", tableName: "AccessibilityLabels", comment: "Accessibility label for the introduction tour carousel")
        }
        public struct FindInPage {
            public static let Previous = NSLocalizedString("AccessibilityLabels.FindInPage.Previous", tableName: "AccessibilityLabels", comment: "Accessibility label for previous result button in Find in Page Toolbar.")
            public static let Next = NSLocalizedString("AccessibilityLabels.FindInPage.Next", tableName: "AccessibilityLabels", comment: "Accessibility label for next result button in Find in Page Toolbar.")
        }
        public struct ReaderMode {
            public static let DisplaySettings = NSLocalizedString("AccessibilityLabels.ReaderMode.DisplaySettings", tableName: "AccessibilityLabels", comment: "Name for display settings button in reader mode. Display in the meaning of presentation, not monitor.")
        }
        public static let WebContent = NSLocalizedString("AccessibilityLabels.WebContent", tableName: "AccessibilityLabels", comment: "Accessibility label for the main web content view")
    }

}
