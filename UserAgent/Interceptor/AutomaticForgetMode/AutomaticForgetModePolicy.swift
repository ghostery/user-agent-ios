//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class AutomaticForgetModePolicy: NSObject, InterceptorPolicy {
    let type: InterceptorType = .automaticForgetMode

    private var queue = DispatchQueue.global(qos: .background)
    private let detector: AutomaticForgetModeDetector
    private var allowListedURL: URL?

    override init() {
        self.detector = AutomaticForgetModeDetector()
    }

    func canLoad(url: URL, onPostFactumCheck: PostFactumCallback?) -> Bool {
        guard self.allowListedURL?.baseDomain != url.baseDomain else {
            self.allowListedURL = nil
            return true
        }

        if self.detector.isAutomaticForgetURL(url) {
            onPostFactumCheck?(url, self)
            return false
        }

        return true
    }

    func allowListUrl(_ url: URL) {
        self.allowListedURL = url
    }
}
