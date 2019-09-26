//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension BrowserViewController: InterceptorUI {
    func showAntiPhishingAlert(tab: Tab, url: URL, policy: InterceptorPolicy) {
        let domainName = url.normalizedHost ?? ""
        let title = NSLocalizedString("Warning: deceptive website!", tableName: "Cliqz", comment: "Antiphishing alert title")
        let message = NSLocalizedString("CLIQZ has blocked access to %1$ because it has been reported as a phishing website.Phishing websites disguise as other sites you may trust in order to trick you into disclosing your login, password or other sensitive information", tableName: "Cliqz", comment: "Antiphishing alert message")
        let personnalizedMessage = message.replace("%1$", replacement: domainName)

        let alert = UIAlertController(title: title, message: personnalizedMessage, preferredStyle: .alert)

        let backToSafeSiteButtonTitle = NSLocalizedString("Back to safe site", tableName: "Cliqz", comment: "Back to safe site buttun title in antiphishing alert title")
        alert.addAction(UIAlertAction(title: backToSafeSiteButtonTitle, style: .default, handler: { (action) in
            if tab.url == url {
                self.tabManager.selectedTab?.goBack()
            }
        }))

        let continueDespiteWarningButtonTitle = NSLocalizedString("Continue despite warning", tableName: "Cliqz", comment: "Continue despite warning buttun title in antiphishing alert title")
        alert.addAction(UIAlertAction(title: continueDespiteWarningButtonTitle, style: .destructive, handler: { (action) in
            policy.whitelistUrl(url)
            // TODO: reload works only after second try. Same bug we have in old Cliqz. We need to investigate.
            self.tabManager.selectedTab?.loadRequest(PrivilegedRequest(url: url) as URLRequest)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
