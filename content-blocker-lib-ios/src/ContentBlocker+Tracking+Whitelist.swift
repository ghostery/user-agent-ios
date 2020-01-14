//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

extension ContentBlocker {

    func trackingWhitelistAsJSON() -> String {
        return self.whitelists.trackers.asJSON()
    }

    func trackingWhitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        self.whitelists.trackers.whitelist(enable: enable, url: url, completion: completion)
    }

    func isTrackingWhitelisted(url: URL) -> Bool {
        return self.whitelists.trackers.isWhitelisted(url: url)
    }

}
