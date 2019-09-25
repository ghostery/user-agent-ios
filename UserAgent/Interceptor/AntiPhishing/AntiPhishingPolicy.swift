//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class AntiPhishingPolicy: NSObject, InterceptorPolicy {
    let detector = AntiPhishingDetector()
    var whiteListedURL: URL?

    var type: InterceptorType {
        return .phishing
    }

    func canProcessWith(url: URL, riskDetected: ((URL, InterceptorPolicy) -> Void)?) -> Bool {
        if whiteListedURL == url {
            whiteListedURL = nil
            return true
        }

        if detector.isPhishingURL(url, completion: { (isPhishing) in
            if isPhishing {
                riskDetected?(url, self)
            }
        }) {
            riskDetected?(url, self)
            return false
        }

        return true
    }

    func whiteListUrl(url: URL) {
        self.whiteListedURL = url
    }
}
