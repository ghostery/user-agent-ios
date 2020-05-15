//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {
    public struct AlertController {
        public struct RestoreTabs {
            public static let Title = NSLocalizedString("AlertController.RestoreTabs.Title", tableName: "AlertController", comment: "Restore Tabs Prompt Title")
            public static let Message = String(format: NSLocalizedString("AlertController.RestoreTabs.Message", tableName: "AlertController", comment: "Restore Tabs Prompt Description"), AppInfo.displayName)
        }
        public struct ClearPrivateData {
            public static let Message = NSLocalizedString("AlertController.ClearPrivateData.Message", tableName: "AlertController", comment: "Description of the confirmation dialog shown when a user tries to clear their private data.")
        }
    }
}
