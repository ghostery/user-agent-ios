//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class AntiPhishingPolicy: NSObject, InterceptorPolicy {
    let type: InterceptorType = .phishing

    private let detector = AntiPhishingDetector()
    private var whitelistedURL: URL?

    func canLoad(url: URL, onPostFactumCheck: PostFactumCallback?) -> Bool {
        if whitelistedURL == url {
            whitelistedURL = nil
            return true
        }

        let postFactumCheck: AntiPhishingCheck = { (isPhishing) in
            if isPhishing {
                DispatchQueue.main.async(execute: {
                    onPostFactumCheck?(url, self)
                })
            }
        }

        if detector.isPhishingURL(url, completion: postFactumCheck) {
            onPostFactumCheck?(url, self)
            return false
        }

        return true
    }

    func whitelistUrl(_ url: URL) {
        self.whitelistedURL = url
    }
}
