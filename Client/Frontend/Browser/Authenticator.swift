/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage

private let CancelButtonTitle = NSLocalizedString("Cancel", comment: "Label for Cancel button")
private let LogInButtonTitle  = NSLocalizedString("Log in", comment: "Authentication prompt log in button")
private let log = Logger.browserLogger

class LoginRecord {
    var credentials: URLCredential?
    var protectionSpace: URLProtectionSpace?

    init(credentials: URLCredential, protectionSpace: URLProtectionSpace) {
        self.credentials = credentials
        self.protectionSpace = protectionSpace
    }
}

public class LoginRecordError: MaybeErrorType {
    public let description: String
    public init(description: String) {
        self.description = description
    }
}

class Authenticator {
    fileprivate static let MaxAuthenticationAttempts = 3

    static func handleAuthRequest(_ viewController: UIViewController, challenge: URLAuthenticationChallenge) -> Deferred<Maybe<LoginRecord>> {
        // If there have already been too many login attempts, we'll just fail.
        if challenge.previousFailureCount >= Authenticator.MaxAuthenticationAttempts {
            return deferMaybe(LoginRecordError(description: "Too many attempts to open site"))
        }

        var credential = challenge.proposedCredential

        // If we were passed an initial set of credentials from iOS, try and use them.
        if let proposed = credential {
            if !(proposed.user?.isEmpty ?? true) {
                if challenge.previousFailureCount == 0 {
                    return deferMaybe(LoginRecord(credentials: proposed, protectionSpace: challenge.protectionSpace))
                }
            } else {
                credential = nil
            }
        }

        // If we have some credentials, we'll show a prompt with them.
        if let credential = credential {
            return promptForUsernamePassword(viewController, credentials: credential, protectionSpace: challenge.protectionSpace)
        }

        // No credentials, so show an empty prompt.
        return self.promptForUsernamePassword(viewController, credentials: nil, protectionSpace: challenge.protectionSpace)
    }

    fileprivate static func promptForUsernamePassword(_ viewController: UIViewController, credentials: URLCredential?, protectionSpace: URLProtectionSpace) -> Deferred<Maybe<LoginRecord>> {
        if protectionSpace.host.isEmpty {
            print("Unable to show a password prompt without a hostname")
            return deferMaybe(LoginRecordError(description: "Unable to show a password prompt without a hostname"))
        }

        let deferred = Deferred<Maybe<LoginRecord>>()
        let alert: AlertController
        let title = NSLocalizedString("Authentication required", comment: "Authentication prompt title")
        if !(protectionSpace.realm?.isEmpty ?? true) {
            let msg = NSLocalizedString("A username and password are being requested by %@. The site says: %@", comment: "Authentication prompt message with a realm. First parameter is the hostname. Second is the realm string")
            let formatted = NSString(format: msg as NSString, protectionSpace.host, protectionSpace.realm ?? "") as String
            alert = AlertController(title: title, message: formatted, preferredStyle: .alert)
        } else {
            let msg = NSLocalizedString("A username and password are being requested by %@.", comment: "Authentication prompt message with no realm. Parameter is the hostname of the site")
            let formatted = NSString(format: msg as NSString, protectionSpace.host) as String
            alert = AlertController(title: title, message: formatted, preferredStyle: .alert)
        }

        // Add a button to log in.
        let action = UIAlertAction(title: LogInButtonTitle,
                                   style: .default) { (action) -> Void in
                                    guard let user = alert.textFields?[0].text, let pass = alert.textFields?[1].text else { deferred.fill(Maybe(failure: LoginRecordError(description: "Username and Password required"))); return }

                                    let login = LoginRecord(credentials: URLCredential(user: user, password: pass, persistence: .forSession), protectionSpace: protectionSpace)
                                    deferred.fill(Maybe(success: login))
        }
        alert.addAction(action, accessibilityIdentifier: "authenticationAlert.loginRequired")

        // Add a cancel button.
        let cancel = UIAlertAction(title: CancelButtonTitle, style: .cancel) { (action) -> Void in
            deferred.fill(Maybe(failure: LoginRecordError(description: "Save password cancelled")))
        }
        alert.addAction(cancel, accessibilityIdentifier: "authenticationAlert.cancel")

        // Add a username textfield.
        alert.addTextField { (textfield) -> Void in
            textfield.placeholder = NSLocalizedString("Username", comment: "Username textbox in Authentication prompt")
            textfield.text = credentials?.user
        }

        // Add a password textfield.
        alert.addTextField { (textfield) -> Void in
            textfield.placeholder = NSLocalizedString("Password", comment: "Password textbox in Authentication prompt")
            textfield.isSecureTextEntry = true
            textfield.text = credentials?.password
        }

        viewController.present(alert, animated: true) { () -> Void in }
        return deferred
    }

}
