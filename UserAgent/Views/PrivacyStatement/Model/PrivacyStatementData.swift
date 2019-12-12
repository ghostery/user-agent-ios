//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

enum PrivacyStatementSection: Int, CaseIterable {
    case settingsConversation = 0
    case settings
    case repositoryConversation
    case repository
    case privacyConversation
    case privacy
    case message

    var numberOfRows: Int {
        switch self {
        case .settingsConversation:
            return 3
        case .settings:
            return 2
        case .repositoryConversation, .repository, .privacyConversation, .privacy, .message:
            return 1
        }
    }
}

struct PrivacyStatementProfile {
    // TODO: PK Initialize
    let avatar = UIImage(named: "privacyStatementProfile")
    let name = "Krzysztof"
    let title = "Cliqz iOS Team"
}

struct PrivacyStatementData {

    let author = PrivacyStatementProfile()

    let title: String
    var sortedSettings: [Setting]
    var settingsConversations: [String]
    var repositoryConversations: [String]
    var privacyConversations: [String]
}
