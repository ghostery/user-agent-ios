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
    case messageConversation
    case message

    var numberOfRows: Int {
        switch self {
        case .settings:
            return 1 + (Features.Telemetry.isEnabled ? 1 : 0)
        case .repository, .privacy, .message:
            return 1
        default:
            return 0
        }
    }
}

struct PrivacyStatementProfile {
    let avatar = UIImage(named: "profileIcon")
    let name = Strings.PrivacyStatement.ProfileName
    let title = String(format: Strings.PrivacyStatement.ProfileTitle, AppInfo.displayName)
}

struct PrivacyStatementData {

    let author = PrivacyStatementProfile()

    let title: String
    var sortedSettings: [Setting]
    var settingsConversations: [String]
    var repositoryConversations: [String]
    var privacyConversations: [String]
    var messageConversations: [String]
}
