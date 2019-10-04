//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import React

@objc(AutoCompletion)
class AutoCompletion: NSObject {
    @objc(autoComplete:)
    func autoComplete(suggestion: NSString) {
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            appDel.browserViewController.urlBar.setAutocompleteSuggestion(suggestion as String)
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
