//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

struct PrivacyStatementProfile {
    // TODO: PK Initialize
    let avatar = UIImage(named: "")
    let name = "Name"
    let title = "Title"
}

struct PrivacyStatementData {


    let author = PrivacyStatementProfile()
    // TODO: localize

    let title = "Your Privacy is Important to Us"
    var sortedSettings: [Setting]
    var settingsConversations: [String]
    var privacyConversations: [String]
    var footerConversations: [String]
}
