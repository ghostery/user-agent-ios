//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

extension ContentBlocker {

    func popupsWhitelistAsJSON() -> String {
        return self.whitelists.popups.asJSON()
    }

    func popupsWhitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        self.whitelists.popups.whitelist(enable: enable, url: url, completion: completion)
    }

    func isPopupsWhitelisted(url: URL) -> Bool {
        return self.whitelists.popups.isWhitelisted(url: url)
    }

}
