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
    private var bloomFilter: BloomFilter!

    private var domains = [String]()

    init(queue: DispatchQueue) {
        self.queue = queue
        self.queue.async {
            self.load()
        }
    }

    func isAutomaticForgetURL(_ url: URL, completion:@escaping AutomaticForgetModeCheck) -> Bool {
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
        guard self.domains.isEmpty, let path = Bundle.main.path(forResource: "adult-domains", ofType: "bin") else {
            return
        }
        self.bloomFilter = BloomFilter(filePath: path)
    }

    private func scanURL(_ url: URL, completion:@escaping (Bool) -> Void) {
        guard let domain = url.baseDomain, !self.domains.contains(domain), self.bloomFilter != nil else {
            completion(true)
            return
        }
        self.queue.async {
            completion(self.bloomFilter.contains(domain))
        }
    }

}
