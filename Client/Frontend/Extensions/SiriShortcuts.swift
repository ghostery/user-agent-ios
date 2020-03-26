/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Intents
import IntentsUI
import Shared

@available(iOS 12.0, *)
class SiriShortcuts {

    func getActivity(for type: SiriActivityTypes) -> NSUserActivity? {
        switch type {
        case .openURL:
            return openUrlActivity
        default:
            return nil
        }
    }

    private var openUrlActivity: NSUserActivity? = {
        let activity = NSUserActivity(activityType: SiriActivityTypes.openURL.rawValue)
        activity.title = Strings.Settings.Siri.OpenURL
        activity.isEligibleForPrediction = true
        activity.suggestedInvocationPhrase = Strings.Settings.Siri.OpenURL
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(SiriActivityTypes.openURL.rawValue)
        return activity
    }()

    static func displayAddToSiri(for activityType: SiriActivityTypes, in viewController: UIViewController) {
        let shortcut: INShortcut
        switch activityType {
        case .openURL:
            guard let activity = SiriShortcuts().getActivity(for: activityType) else {
                return
            }
            shortcut = INShortcut(userActivity: activity)
        case .searchWith:
            let intent = SearchWithIntent()
            intent.suggestedInvocationPhrase = Strings.Settings.Siri.SearchWith + AppInfo.displayName
            guard let intentShortcut = INShortcut(intent: intent) else {
                return
            }
            shortcut = intentShortcut
        }
        let addViewController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
        addViewController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        addViewController.delegate = viewController as? INUIAddVoiceShortcutViewControllerDelegate
        viewController.present(addViewController, animated: true, completion: nil)
    }

    static func displayEditSiri(for shortcut: INVoiceShortcut, in viewController: UIViewController) {
        let editViewController = INUIEditVoiceShortcutViewController(voiceShortcut: shortcut)
        editViewController.modalPresentationStyle = UIDevice.current.isPhone ? .fullScreen : .formSheet
        editViewController.delegate = viewController as? INUIEditVoiceShortcutViewControllerDelegate
        viewController.present(editViewController, animated: true, completion: nil)
    }

    static func manageSiri(for activityType: SiriActivityTypes, in viewController: UIViewController) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { (voiceShortcuts, error) in
            DispatchQueue.main.async {
                guard let voiceShortcuts = voiceShortcuts else { return }
                let foundShortcut = voiceShortcuts.filter { (attempt) in
                    attempt.shortcut.userActivity?.activityType == activityType.rawValue
                    }.first
                if let foundShortcut = foundShortcut {
                    self.displayEditSiri(for: foundShortcut, in: viewController)
                } else {
                    self.displayAddToSiri(for: activityType, in: viewController)
                }
            }
        }
    }
}
