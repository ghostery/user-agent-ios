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

class AntiPhishingDetector: NSObject {
    private let antiPhishingAPIURL = "https://antiphishing.cliqz.com/api/bwlist?md5="
    private var detectedPhishingURLs = [URL]()

    //MARK: - public APIs
    func isPhishingURL(_ url: URL, completion:@escaping (Bool) -> Void) -> Bool {
        guard url.host != "localhost" else {
            completion(false)
            return false
        }
        guard !self.isDetectedPhishingURL(url) else {
            return true
        }

        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            self.scanURL(url, queue: queue, completion: completion)
        }

        return false
    }

    //MARK: private methods

    private func isDetectedPhishingURL(_ url: URL) -> Bool {
        return detectedPhishingURLs.contains(url)
    }

    private func scanURL(_ url: URL, queue: DispatchQueue, completion:@escaping (Bool) -> Void) {
        guard let host = url.host else {
            DispatchQueue.main.async(execute: {
                completion(false)
            })
            return
        }

        let md5Prefix = self.prefix(url: host)
        let md5Suffix = self.suffix(url: host)

        guard let antiPhishhingURL = URL(string: (antiPhishingAPIURL + md5Prefix)) else {
            DispatchQueue.main.async(execute: {
                completion(false)
            })
            return
        }

        var urlRequest = URLRequest(url: antiPhishhingURL)
        urlRequest.httpMethod = "GET"
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil, let data = data else {
                DispatchQueue.main.async(execute: {
                    log.error(error!)
                    completion(false)
                })
                return
            }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                if let result = json as? [String: Any] {
                    if let blacklist = result["blacklist"] as? [Any] {
                        for suffixTuples in blacklist {
                            let suffixTuplesArray = suffixTuples as! [AnyObject]
                            if let suffix = suffixTuplesArray.first as? String, md5Suffix == suffix {
                                DispatchQueue.main.async(execute: {
                                    self.detectedPhishingURLs.append(url)
                                    completion(true)
                                })
                            }
                        }
                        DispatchQueue.main.async(execute: {
                            completion(false)
                        })
                    }
                }
            } catch {
                DispatchQueue.main.async(execute: {
                    log.error(error)
                    completion(false)
                })
            }
        }
        dataTask.resume()
    }

    private func prefix(url: String) -> Substring {
        let md5Hash = url.md5()
        let middelIndex = md5Hash.index(md5Hash.startIndex, offsetBy: 16)
        return md5Hash[..<middelIndex]
    }

    private func suffix(url: String) -> Substring {
        let md5Hash = url.md5()
        let middelIndex = md5Hash.index(md5Hash.startIndex, offsetBy: 16)
        return md5Hash[middelIndex...]
    }
}
