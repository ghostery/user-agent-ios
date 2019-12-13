//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

protocol NativeModuleBase {

}

extension NativeModuleBase {
    func withAppDelegate(completion: @escaping (AppDelegate) -> Void) {
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else { return }
            completion(appDel)
        }
    }
}
