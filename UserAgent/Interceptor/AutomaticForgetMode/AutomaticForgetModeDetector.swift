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

    private var bloomFilter: BloomFilter!

    init() {
        self.load()
    }

    func isAutomaticForgetURL(_ url: URL) -> Bool {
        guard url.host != "localhost" && url.host != "local", let domain = url.baseDomain else {
            return false
        }
        return self.bloomFilter?.contains(domain) ?? false
    }

    // MARK: - Private methods

    private func load() {
        guard let path = Bundle.main.path(forResource: "adult-domains", ofType: "bin") else {
            return
        }
        self.bloomFilter = BloomFilter(filePath: path)
    }

}
