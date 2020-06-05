//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Storage

@objc public class NativeFaviconFetcher: NSObject {

    @objc public class func fetchImage(url: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: url), let profile = (UIApplication.shared.delegate as? AppDelegate)?.profile else {
            return
        }
        profile.favicons.getFaviconImage(forSite: Site(url: url.absoluteString, title: "")).uponQueue(.main) { result in
            guard let image = result.successValue else {
                completion(FaviconFetcher.letter(forUrl: url))
                return
            }
            completion(image)
        }
    }
}
