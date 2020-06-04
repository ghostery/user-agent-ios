//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

public extension Onboarding {

    static var isEnabled: Bool {
        return true
    }

    static func presentingViewController(delegate: OnboardingViewControllerDelegate?) -> UIViewController? {
        let viewController = IntroViewController()
        viewController.delegate = delegate
        return viewController
    }

}
