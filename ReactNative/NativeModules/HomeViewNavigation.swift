//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

@objc(HomeViewNavigation)
class HomeViewNavigation: NSObject, NativeModuleBase {
    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }

    @objc(showDomainDetails:toolbarHeight:)
    func showDomainDetails(domain: NSString, toolbarHeight: NSNumber) {
        self.withAppDelegate { appDel in
            guard let navigation = appDel.browserViewController.homeViewController as? UINavigationController else {
                return
            }
            let nestedController = BrowserCoreViewController("DomainDetails", withArgs: [
                "domain": domain,
                "toolbarHeight": toolbarHeight,
            ])
            nestedController.title = domain as String
            nestedController.navigationItem.backBarButtonItem?.title = ""
            navigation.pushViewController(nestedController, animated: true)
        }
    }
}
