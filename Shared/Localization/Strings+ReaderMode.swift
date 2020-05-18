//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct ReaderMode {
        public static let Loading = NSLocalizedString("ReaderMode.Loading", tableName: "ReaderMode", comment: "Message displayed when the reader mode page is loading. This message will appear only when sharing to Firefox reader mode from another app.")
        public static let CouldNotBeDisplayed = NSLocalizedString("ReaderMode.CouldNotBeDisplayed", tableName: "ReaderMode", comment: "Message displayed when the reader mode page could not be loaded. This message will appear only when sharing to Firefox reader mode from another app.")
        public static let OriginalPage = NSLocalizedString("ReaderMode.OriginalPage", tableName: "ReaderMode", comment: "Link for going to the non-reader page when the reader view could not be loaded. This message will appear only when sharing to Firefox reader mode from another app.")
        public static let Error = NSLocalizedString("ReaderMode.Error", tableName: "ReaderMode", comment: "Error displayed when reader mode cannot be enabled")
        public static let SansSerif = NSLocalizedString("ReaderMode.SansSerif", tableName: "ReaderMode", comment: "Font type setting in the reading view settings")
        public static let Serif = NSLocalizedString("ReaderMode.Serif", tableName: "ReaderMode", comment: "Font type setting in the reading view settings")
        public static let Dash = NSLocalizedString("ReaderMode.Dash", tableName: "ReaderMode", comment: "Button for smaller reader font size. Keep this extremely short! This is shown in the reader mode toolbar.")
        public static let Plus = NSLocalizedString("ReaderMode.Plus", tableName: "ReaderMode", comment: "Button for larger reader font size. Keep this extremely short! This is shown in the reader mode toolbar.")
        public static let Aa = NSLocalizedString("ReaderMode.Aa", tableName: "ReaderMode", comment: "Button for reader mode font size. Keep this extremely short! This is shown in the reader mode toolbar.")
        public static let Light = NSLocalizedString("ReaderMode.Light", tableName: "ReaderMode", comment: "Light theme setting in Reading View settings")
        public static let Dark = NSLocalizedString("ReaderMode.Dark", tableName: "ReaderMode", comment: "Dark theme setting in Reading View settings")
        public static let Sepia = NSLocalizedString("ReaderMode.Sepia", tableName: "ReaderMode", comment: "Sepia theme setting in Reading View settings")
    }

}
