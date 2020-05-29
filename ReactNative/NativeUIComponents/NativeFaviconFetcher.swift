//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

@objc public class NativeFaviconFetcher: NSObject {

    @objc public class func fetchImage(url: String, completion: @escaping (UIImage) -> Void) {
        guard let url = URL(string: url), let profile = (UIApplication.shared.delegate as? AppDelegate)?.profile else {
            return
        }
        FaviconFetcher.fetchFavImageForURL(forURL: url, profile: profile).uponQueue(.main) { result in
            let image = result.successValue ?? FaviconFetcher.letter(forUrl: url)
            completion(image)
        }
    }
}
