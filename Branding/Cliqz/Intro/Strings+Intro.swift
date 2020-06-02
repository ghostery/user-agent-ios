//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

extension Strings {
    // MARK: - Intro
    public struct Intro {
        public struct Slides {
            public struct Search {
                public static let Title = NSLocalizedString("Intro.Slides.Search.Title", tableName: "Intro", comment: "Title for the 'Search' panel in the First Run tour.")
                public static let Description = NSLocalizedString("Intro.Slides.Search.Description", tableName: "Intro", comment: "Description for the 'Search' panel in the First Run tour.")
            }
            public struct AntiTracking {
                public static let Title = NSLocalizedString("Intro.Slides.AntiTracking.Title", tableName: "Intro", comment: "Title for the 'AntiTracking' panel in the First Run tour.")
                public static let Description = NSLocalizedString("Intro.Slides.AntiTracking.Description", tableName: "Intro", comment: "Description for the 'AntiTracking' panel in the First Run tour.")
            }
            public struct Welcome {
                public static let ButtonTitle = NSLocalizedString("Intro.Slides.Welcome.Button.Title", tableName: "Intro", comment: "Button title for starting browsing.")
                public static let Description = NSLocalizedString("Intro.Slides.Welcome.Description", tableName: "Intro", comment: "Description for the 'Welcome' panel in the First Run tour.")
            }
            public static let SkipButtonTitle = NSLocalizedString("Intro.Slides.Skip.Title", tableName: "Intro", comment: "Button title for skipping tour.")
        }
    }
}
