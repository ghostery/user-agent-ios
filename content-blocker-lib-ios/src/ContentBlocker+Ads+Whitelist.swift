/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

extension ContentBlocker {

    func adsWhitelistAsJSON() -> String {
        return self.whitelists.ads.asJSON()
    }

    func adsWhitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        self.whitelists.ads.whitelist(enable: enable, url: url, completion: completion)
    }

    func isAdsWhitelisted(url: URL) -> Bool {
        return self.whitelists.ads.isWhitelisted(url: url)
    }

}
