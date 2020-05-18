/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared

typealias UIAlertActionCallback = (UIAlertAction) -> Void

// MARK: - Extension methods for building specific UIAlertController instances used across the app
extension UIAlertController {

    /**
    Builds the Alert view that asks the user if they wish to restore their tabs after a crash.

    - parameter okayCallback: Okay option handler
    - parameter noCallback:   No option handler

    - returns: UIAlertController for asking the user to restore tabs after a crash
    */
    class func restoreTabsAlert(okayCallback: @escaping UIAlertActionCallback, noCallback: @escaping UIAlertActionCallback) -> UIAlertController {
        let alert = UIAlertController(
            title: Strings.AlertController.RestoreTabs.Title,
            message: Strings.AlertController.RestoreTabs.Message,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: Strings.General.NoString,
            style: .cancel,
            handler: noCallback
        )

        let okayOption = UIAlertAction(
            title: Strings.General.OKString,
            style: .default,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

    class func clearPrivateDataAlert(okayCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: Strings.AlertController.ClearPrivateData.Message,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: Strings.General.CancelString,
            style: .cancel,
            handler: nil
        )

        let okayOption = UIAlertAction(
            title: Strings.General.OKString,
            style: .destructive,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

    class func clearWebsiteDataAlert(okayCallback: @escaping (UIAlertAction) -> Void) -> UIAlertController {
        let alert = UIAlertController(
            title: "",
            message: Strings.Settings.Privacy.DataManagement.ClearPrivateData.Title,
            preferredStyle: .alert
        )

        let noOption = UIAlertAction(
            title: Strings.General.CancelString,
            style: .cancel,
            handler: nil
        )

        let okayOption = UIAlertAction(
            title: Strings.General.OKString,
            style: .destructive,
            handler: okayCallback
        )

        alert.addAction(okayOption)
        alert.addAction(noOption)
        return alert
    }

}
