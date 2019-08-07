/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import Storage

class SendToDevice: DevicePickerViewControllerDelegate, InstructionsViewControllerDelegate {
    var sharedItem: ShareItem?
    weak var delegate: ShareControllerDelegate?

    func initialViewController() -> UIViewController {
        if !hasAccount() {
            let instructionsViewController = InstructionsViewController()
            instructionsViewController.delegate = self
            return instructionsViewController
        }

        let devicePickerViewController = DevicePickerViewController()
        devicePickerViewController.pickerDelegate = self
        devicePickerViewController.profile = nil // This means the picker will open and close the default profile
        return devicePickerViewController
    }

    func finish() {
        delegate?.finish(afterDelay: 0)
    }

    func devicePickerViewController(_ devicePickerViewController: DevicePickerViewController, didPickDevices devices: [RemoteDevice]) {

    }

    func devicePickerViewControllerDidCancel(_ devicePickerViewController: DevicePickerViewController) {
        finish()
    }

    func instructionsViewControllerDidClose(_ instructionsViewController: InstructionsViewController) {
        finish()
    }

    private func hasAccount() -> Bool {
        return false
    }
}
