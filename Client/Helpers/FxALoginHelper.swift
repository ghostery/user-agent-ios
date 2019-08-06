/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import SwiftyJSON
import UserNotifications
import XCGLogger

private let applicationDidRequestUserNotificationPermissionPrefKey = "applicationDidRequestUserNotificationPermissionPrefKey"

private let log = Logger.browserLogger

private let verificationPollingInterval = DispatchTimeInterval.seconds(3)
private let verificationMaxRetries = 100 // Poll every 3 seconds for 5 minutes.

protocol FxAPushLoginDelegate: AnyObject {
    func accountLoginDidFail()

    func accountLoginDidSucceed(withFlags flags: FxALoginFlags)
}

/// Small struct to keep together the immediately actionable flags that the UI is likely to immediately
/// following a successful login. This is not supposed to be a long lived object.
struct FxALoginFlags {
    let pushEnabled: Bool
    let verified: Bool
}

enum PushNotificationError: MaybeErrorType {
    case registrationFailed
    case userDisallowed
    case wrongOSVersion

    var description: String {
        switch self {
        case .registrationFailed:
            return "The OS was unable to complete APNS registration"
        case .userDisallowed:
            return "User refused permission for notifications"
        case .wrongOSVersion:
            return "The version of iOS is not recent enough"
        }
    }
}

/// This class manages the from successful login for FxAccounts to
/// asking the user for notification permissions, registering for
/// remote push notifications (APNS), then creating an account and
/// storing it in the profile.
class FxALoginHelper {
    static var sharedInstance: FxALoginHelper = {
        return FxALoginHelper()
    }()

    weak var delegate: FxAPushLoginDelegate?

    fileprivate weak var profile: Profile?

    fileprivate var accountVerified = false

    fileprivate var apnsTokenDeferred: Deferred<Maybe<String>>?

    // This should be called when the application has started.
    // This configures the helper for logging into Firefox Accounts, and
    // if already logged in, checking if anything needs to be done in response
    // to changing of user settings and push notifications.
    func application(_ application: UIApplication, didLoadProfile profile: Profile) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }

    // This is called when the user logs into a new FxA account.
    // It manages the asking for user permission for notification and registration
    // for APNS and WebPush notifications.
    func application(_ application: UIApplication, didReceiveAccountJSON data: JSON) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }

    func requestUserNotifications(_ application: UIApplication) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }

    fileprivate func requestUserNotificationsMainThreadOnly(_ application: UIApplication) {
        assert(Thread.isMainThread, "requestAuthorization should be run on the main thread")
        let center = UNUserNotificationCenter.current()
        return center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            guard error == nil else {
                return self.application(application, canDisplayUserNotifications: false)
            }
            self.application(application, canDisplayUserNotifications: granted)
        }
    }

    func application(_ application: UIApplication, canDisplayUserNotifications allowed: Bool) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }

    func apnsRegisterDidSucceed(_ deviceToken: Data) {
        // This method stub is a leftover from when we removed the Account and Sync modules
    }

    func apnsRegisterDidFail() {
        // This method stub is a leftover from when we removed the Account and Sync modules
    }

    fileprivate func pushRegistrationDidFail() {
        // This method stub is a leftover from when we removed the Account and Sync modules
    }

    fileprivate func awaitVerification(_ attemptsLeft: Int = verificationMaxRetries) {
        // This method stub is a leftover from when we removed the Account and Sync modules
        return
    }
}
