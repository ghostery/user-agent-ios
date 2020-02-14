//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

extension ContentBlocker {

    func trackingAllowListAsJSON() -> String {
        return self.allowLists.trackers.asJSON()
    }

    func trackingAllowList(enable: Bool, url: URL, completion: (() -> Void)?) {
        self.allowLists.trackers.allowList(enable: enable, url: url, completion: completion)
    }

    func isTrackingAllowListed(url: URL) -> Bool {
        return self.allowLists.trackers.isAllowListed(url: url)
    }

}
