//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

private let log = Logger.browserLogger

typealias AntiPhishingCheck = (Bool) -> Void

class AntiPhishingDetector: NSObject {
    private let antiPhishingAPIURL = "https://antiphishing.cliqz.com/api/bwlist?md5="
    private var detectedPhishingURLs = [URL]()
    private let queue: DispatchQueue

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    // MARK: - public APIs
    func isPhishingURL(_ url: URL, completion:@escaping AntiPhishingCheck) -> Bool {
        guard url.host != "localhost" && url.host != "local" else {
            completion(false)
            return false
        }
        guard !self.isDetectedPhishingURL(url) else {
            return true
        }

        queue.async {
            self.scanURL(url, completion: completion)
        }

        return false
    }

    // MARK: private methods

    private func isDetectedPhishingURL(_ url: URL) -> Bool {
        return detectedPhishingURLs.contains(url)
    }

    private func scanURL(_ url: URL, completion:@escaping (Bool) -> Void) {
        guard let host = url.host else {
            completion(false)
            return
        }

        let md5 = MD5(host)
        let (md5Prefix, md5Suffix) = splitBy(md5, offset: 16)

        guard let antiPhishhingURL = URL(string: (antiPhishingAPIURL + md5Prefix)) else {
            completion(false)
            return
        }

        var urlRequest = URLRequest(url: antiPhishhingURL)
        urlRequest.httpMethod = "GET"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let data = data else {
                log.error(error!)
                completion(false)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])

                guard let result = json as? [String: Any] else { return }
                guard let blocklist = result["blacklist"] as? [Any] else { return }

                for suffixTuples in blocklist {
                    let suffixTuplesArray = suffixTuples as! [AnyObject]
                    if
                        let suffix = suffixTuplesArray.first as? String,
                        md5Suffix == suffix
                    {
                        self.detectedPhishingURLs.append(url)
                        completion(true)
                        return
                    }
                }
                completion(false)
            } catch {
                log.error(error)
                completion(false)
            }
        }

        dataTask.resume()
    }
}

private func splitBy(_ string: String, offset: Int) -> (Substring, Substring) {
    let middelIndex = string.index(string.startIndex, offsetBy: offset)
    return (string[..<middelIndex], string[middelIndex...])
}
