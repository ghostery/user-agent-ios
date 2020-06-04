//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

public extension DataAndPrivacy {

    static var isEnabled: Bool {
        return true
    }

    static func presentingViewController(prefs: Prefs, delegate: DataAndPrivacyViewControllerDelegate?) -> UIViewController? {
        let settingsConversations = [
            String(format: Strings.PrivacyStatement.SettingsConversation1, AppInfo.displayName),
            String(format: Strings.PrivacyStatement.SettingsConversation2, AppInfo.displayName),
        ]
        let dataModel = PrivacyStatementData(title: Strings.PrivacyStatement.Title,
                                             sortedSettings: [],
                                             settingsConversations: settingsConversations,
                                             repositoryConversations: [Strings.PrivacyStatement.RepositoryConversation],
                                             privacyConversations: [Strings.PrivacyStatement.PrivacyConversation],
                                             messageConversations: [Strings.PrivacyStatement.MessageConversation])
        let privacyStatementViewController = PrivacyStatementViewController(dataModel: dataModel, prefs: prefs)
        privacyStatementViewController.delegate = delegate
        return UINavigationController(rootViewController: privacyStatementViewController)
    }

}
