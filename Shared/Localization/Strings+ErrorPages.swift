//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct ErrorPages {
        public static let AdvancedButton = NSLocalizedString("ErrorPages.Advanced.Button", tableName: "ErrorPages", comment: "Label for button to perform advanced actions on the error page")
        public static let AdvancedWarning1 = NSLocalizedString("ErrorPages.AdvancedWarning1.Text", tableName: "ErrorPages", comment: "Warning text when clicking the Advanced button on error pages")
        public static let AdvancedWarning2 = NSLocalizedString("ErrorPages.AdvancedWarning2.Text", tableName: "ErrorPages", comment: "Additional warning text when clicking the Advanced button on error pages")
        public static let CertWarningDescription = NSLocalizedString("ErrorPages.CertWarning.Description", tableName: "ErrorPages", comment: "Warning text on the certificate error page. First argument 'Error Domain', Second - 'App name'")
        public static let CertWarningTitle = NSLocalizedString("ErrorPages.CertWarning.Title", tableName: "ErrorPages", comment: "Title on the certificate error page")
        public static let GoBackButton = NSLocalizedString("ErrorPages.GoBack.Button", tableName: "ErrorPages", comment: "Label for button to go back from the error page")
        public static let VisitOnceButton = NSLocalizedString("ErrorPages.VisitOnce.Button", tableName: "ErrorPages", comment: "Button label to temporarily continue to the site from the certificate error page")
        public static let TryAgain = NSLocalizedString("ErrorPages.TryAgain", tableName: "ErrorPages", comment: "Shown in error pages on a button that will try to load the page again")
        public static let OpenInSafari = NSLocalizedString("ErrorPages.OpenInSafari", tableName: "ErrorPages", comment: "Shown in error pages for files that can't be shown and need to be downloaded.")
        public static let CouldNotLoadPage = NSLocalizedString("ErrorPages.CouldNotLoadPage", tableName: "ErrorPages", comment: "Error message that is shown in settings when there was a problem loading")
    }

}
