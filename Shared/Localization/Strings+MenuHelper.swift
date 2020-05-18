//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct MenuHelper {
        public static let PasteGo = NSLocalizedString("MenuHelper.PasteGo", tableName: "MenuHelper", comment: "The menu item that pastes the current contents of the clipboard into the URL bar and navigates to the page")
        public static let Reveal = NSLocalizedString("MenuHelper.Reveal", tableName: "MenuHelper", comment: "Reveal password text selection menu item")
        public static let Hide = NSLocalizedString("MenuHelper.Hide", tableName: "MenuHelper", comment: "Hide password text selection menu item")
        public static let OpenAndFill = NSLocalizedString("MenuHelper.OpenAndFill", tableName: "MenuHelper", comment: "Open and Fill website text selection menu item")
        public static let FindInPage = NSLocalizedString("MenuHelper.FindInPage", tableName: "MenuHelper", comment: "Text selection menu item")
        public static let SearchWithUserAgent = String(format: NSLocalizedString("MenuHelper.SearchWithUserAgent", tableName: "MenuHelper", comment: "Search in New Tab Text selection menu item"), AppInfo.displayName)
    }

}
