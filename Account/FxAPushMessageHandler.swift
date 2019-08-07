/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared
import SwiftyJSON

private let log = Logger.syncLogger

let PendingAccountDisconnectedKey = "PendingAccountDisconnect"

enum PushMessageType: String {
    case commandReceived = "fxaccounts:command_received"
    case deviceConnected = "fxaccounts:device_connected"
    case deviceDisconnected = "fxaccounts:device_disconnected"
    case profileUpdated = "fxaccounts:profile_updated"
    case passwordChanged = "fxaccounts:password_changed"
    case passwordReset = "fxaccounts:password_reset"
    case collectionChanged = "sync:collection_changed"

    // This isn't a real message type, just the absence of one.
    case accountVerified = "account_verified"
}

enum PushMessage: Equatable {
    case commandReceived(tab: [String : String])
    case deviceConnected(String)
    case deviceDisconnected(String?)
    case profileUpdated
    case passwordChanged
    case passwordReset
    case collectionChanged(collections: [String])
    case accountVerified

    // This is returned when we detect that it is us that has been disconnected.
    case thisDeviceDisconnected

    var messageType: PushMessageType {
        switch self {
        case .commandReceived(_):
            return .commandReceived
        case .deviceConnected(_):
            return .deviceConnected
        case .deviceDisconnected(_):
            return .deviceDisconnected
        case .thisDeviceDisconnected:
            return .deviceDisconnected
        case .profileUpdated:
            return .profileUpdated
        case .passwordChanged:
            return .passwordChanged
        case .passwordReset:
            return .passwordReset
        case .collectionChanged(collections: _):
            return .collectionChanged
        case .accountVerified:
            return .accountVerified
        }
    }
}

typealias PushMessageResult = Deferred<Maybe<PushMessage>>

enum PushMessageError: MaybeErrorType {
    case notDecrypted
    case messageIncomplete
    case unimplemented(PushMessageType)
    case timeout
    case accountError
    case noProfile

    public var description: String {
        switch self {
        case .notDecrypted: return "notDecrypted"
        case .messageIncomplete: return "messageIncomplete"
        case .unimplemented(let what): return "unimplemented=\(what)"
        case .timeout: return "timeout"
        case .accountError: return "accountError"
        case .noProfile: return "noProfile"
        }
    }
}
