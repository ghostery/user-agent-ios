/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import Storage

public enum SyncDisplayState {
    case inProgress
    case good
    case bad(message: String?)
    case warning(message: String)

    func asObject() -> [String: String]? {
        switch self {
        case .bad(let msg):
            guard let message = msg else {
                return ["state": "Error"]
            }
            return ["state": "Error",
                    "message": message]
        case .warning(let message):
            return ["state": "Warning",
                    "message": message]
        default:
            break
        }
        return nil
    }
}

public func ==(a: SyncDisplayState, b: SyncDisplayState) -> Bool {
    switch (a, b) {
    case (.inProgress, .inProgress):
        return true
    case (.good, .good):
        return true
    case (.bad(let a), .bad(let b)) where a == b:
        return true
    case (.warning(let a), .warning(let b)) where a == b:
        return true
    default:
        return false
    }
}
