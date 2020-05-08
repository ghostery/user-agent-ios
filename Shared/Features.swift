//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct Features {
    public struct Search {
        public enum KeyboardReturnKeyBehavior {
            case dismiss
            case search
        }
        public struct AdditionalSearchEngines {
            public static var isEnabled: Bool {
                get {
                    return true
                }
            }
        }
        public static var keyboardReturnKeyBehavior: KeyboardReturnKeyBehavior {
            get {
                return .dismiss
            }
        }
    }
}
