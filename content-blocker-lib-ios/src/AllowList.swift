//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

struct AllowListedDomains {
    var domainSet = Set<String>() {
        didSet {
            domainRegex = domainSet.compactMap { wildcardContentBlockerDomainToRegex(domain: "*" + $0) }
        }
    }

    private(set) var domainRegex = [String]()
}

class AllowList {
    typealias CleanupStore = ([BlocklistName], (() -> Void)?) -> Void

    var cleanupStore: CleanupStore?

    private var filename: String!
    private var blocklists: [BlocklistName]!

    public var allowListedDomains = AllowListedDomains()

    init(allowListFilename: String, blocklists: [BlocklistName]) {
        self.filename = allowListFilename
        self.blocklists = blocklists

        // Read the allowList at startup
        if let list = self.readAllowListFile() {
            self.allowListedDomains.domainSet = Set(list)
        }
    }

    func fileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent(self.filename)
    }

    // Get the allowList domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func asJSON() -> String {
        if self.allowListedDomains.domainSet.isEmpty {
            return ""
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "'*" + self.allowListedDomains.domainSet.joined(separator: "','*") + "'"
        return ", {'action': { 'type': 'ignore-previous-rules' }, 'trigger': { 'url-filter': '.*', 'if-domain': [\(list)] }}".replacingOccurrences(of: "'", with: "\"")
    }

    func allowList(enable: Bool, url: URL, completion: (() -> Void)?) {
        guard let domain = self.allowListableDomain(fromUrl: url) else { return }

        if enable {
            self.allowListedDomains.domainSet.insert(domain)
        } else {
            self.allowListedDomains.domainSet.remove(domain)
        }

        self.updateAllowList(completion: completion)
    }

    private func updateAllowList(completion: (() -> Void)?) {
        self.cleanupStore?(self.blocklists, completion)

        guard let fileURL = self.fileURL() else { return }
        if self.allowListedDomains.domainSet.isEmpty {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }

        let list = self.allowListedDomains.domainSet.joined(separator: "\n")
        do {
            try list.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save allowList file: \(error)")
        }
    }

    func isAllowListed(url: URL) -> Bool {
        guard let domain = self.allowListableDomain(fromUrl: url) else {
            return false
        }
        return self.allowListedDomains.domainSet.contains(domain)
    }

    private func readAllowListFile() -> [String]? {
        guard let fileURL = self.fileURL() else { return nil }
        let text = try? String(contentsOf: fileURL, encoding: .utf8)
        if let text = text, !text.isEmpty {
            return text.components(separatedBy: .newlines)
        }
        return nil
    }

    // Ensure domains used for allowListing are standardized by using this function.
    private func allowListableDomain(fromUrl url: URL) -> String? {
        guard let domain = url.host, !domain.isEmpty else {
            return nil
        }
        return domain
    }
}
