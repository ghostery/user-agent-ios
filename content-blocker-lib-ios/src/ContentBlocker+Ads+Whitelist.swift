/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

extension ContentBlocker {

    func adsAllowListAsJSON() -> String {
        return self.allowLists.ads.asJSON()
    }

    func adsAllowList(enable: Bool, url: URL, completion: (() -> Void)?) {
        self.allowLists.ads.allowList(enable: enable, url: url, completion: completion)
    }

    func isAdsAllowListed(url: URL) -> Bool {
        return self.allowLists.ads.isAllowListed(url: url)
    }

}
