//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct Authenticator {
        public static let LogIn = NSLocalizedString("Authenticator.LogIn", tableName: "Authenticator", comment: "Authentication prompt log in button")
        public static let AuthenticationRequired = NSLocalizedString("Authenticator.AuthenticationRequired", tableName: "Authenticator", comment: "Authentication prompt title")
        public static let WithSiteMessage = NSLocalizedString("Authenticator.WithSiteMessage", tableName: "Authenticator", comment: "Authentication prompt message with a realm. First parameter is the hostname. Second is the realm string")
        public static let WithoutSiteMessage = NSLocalizedString("Authenticator.WithoutSiteMessage", tableName: "Authenticator", comment: "Authentication prompt message with no realm. Parameter is the hostname of the site")
        public static let Username = NSLocalizedString("Authenticator.Username", tableName: "Authenticator", comment: "Username textbox in Authentication prompt")
        public static let Password = NSLocalizedString("Authenticator.Password", tableName: "Authenticator", comment: "Password textbox in Authentication prompt")
    }

}
