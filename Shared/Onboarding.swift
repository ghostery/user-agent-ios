//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

public protocol OnboardingViewControllerDelegate: AnyObject {
    func onboardingViewControllerDidFinish(_ onboardingViewController: UIViewController)
}

public class Onboarding {

    public static var isEnabled: Bool {
        return false
    }

    public static func presentingViewController(delegate: OnboardingViewControllerDelegate?) -> UIViewController? {
        return nil
    }

}
