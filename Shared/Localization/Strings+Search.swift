//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {
    public struct Search {
         // MARK: - Third Party Search Engines
        public struct ThirdPartyEngines {
            public static let EngineAdded = NSLocalizedString("Search.ThirdPartyEngines.AddSuccess", tableName: "Search", comment: "The success message that appears after a user sucessfully adds a new search engine")
            public static let AddTitle = NSLocalizedString("Search.ThirdPartyEngines.AddTitle", tableName: "Search", comment: "The title that asks the user to Add the search provider")
            public static let AddMessage = NSLocalizedString("Search.ThirdPartyEngines.AddMessage", tableName: "Search", comment: "The message that asks the user to Add the search provider explaining where the search engine will appear")
            public static let CancelButton = NSLocalizedString("Search.ThirdPartyEngines.Cancel", tableName: "Search", comment: "The cancel button if you do not want to add a search engine.")
            public static let OkayButton = NSLocalizedString("Search.ThirdPartyEngines.OK", tableName: "Search", comment: "The confirmation button")
            public static let FailedTitle = NSLocalizedString("Search.ThirdPartyEngines.FailedTitle", tableName: "Search", comment: "A title explaining that we failed to add a search engine")
            public static let FailedMessage = NSLocalizedString("Search.ThirdPartyEngines.FailedMessage", tableName: "Search", comment: "A title explaining that we failed to add a search engine")
            public static let FormErrorTitle = NSLocalizedString("Search.ThirdPartyEngines.FormErrorTitle", tableName: "Search", comment: "A title stating that we failed to add custom search engine.")
            public static let FormErrorMessage = NSLocalizedString("Search.ThirdPartyEngines.FormErrorMessage", tableName: "Search", comment: "A message explaining fault in custom search engine form.")
            public static let DuplicateErrorTitle = NSLocalizedString("Search.ThirdPartyEngines.DuplicateErrorTitle", tableName: "Search", comment: "A title stating that we failed to add custom search engine.")
            public static let DuplicateErrorMessage = NSLocalizedString("Search.ThirdPartyEngines.DuplicateErrorMessage", tableName: "Search", comment: "A message explaining fault in custom search engine form.")
        }
        public static let Visit = NSLocalizedString("Search.Visit", tableName: "Search", comment: "Shown next to navigate-to result")
    }
}
