//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

typealias AutomaticForgetModeCheck = (Bool) -> Void

class AutomaticForgetModeDetector {

    private let queue: DispatchQueue

    private var domains = [String]()

    init(queue: DispatchQueue) {
        self.queue = queue
        self.queue.async {
            self.load()
        }
    }

    func shouldBlockURL(_ url: URL, completion:@escaping AutomaticForgetModeCheck) -> Bool {
        guard url.host != "localhost" && url.host != "local" else {
            completion(false)
            return false
        }

        self.queue.async {
            self.scanURL(url, completion: completion)
        }

        return false
    }

    // MARK: - Private methods

    private func load() {
        
    }

    private func scanURL(_ url: URL, completion:@escaping (Bool) -> Void) {
        guard let domain = url.baseDomain, !self.domains.contains(domain) else {
            completion(true)
            return
        }
        completion(false)
    }
}
