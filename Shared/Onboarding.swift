//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

public protocol OnboardingViewController: UIViewController {
    var delegate: OnboardingViewControllerDelegate? { get set }
}

public protocol OnboardingViewControllerDelegate: class {
    func onboardingViewControllerDidFinish(_ onboardingViewController: OnboardingViewController)
}

public class Onboarding {

    public static var isEnabled: Bool {
        return false
    }

    public static func presentingViewController() -> OnboardingViewController? {
        return nil
    }

}
