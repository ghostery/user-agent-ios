//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

struct WhitelistedDomains {
    var domainSet = Set<String>() {
        didSet {
            domainRegex = domainSet.compactMap { wildcardContentBlockerDomainToRegex(domain: "*" + $0) }
        }
    }

    private(set) var domainRegex = [String]()
}

class Whitelist {
    var cleanupStore: (((() -> Void)?) -> Void)?

    private var filename: String!

    public var whitelistedDomains = WhitelistedDomains()

    init(whitelistFilename: String) {
        self.filename = whitelistFilename

        // Read the whitelist at startup
        if let list = self.readWhitelistFile() {
            self.whitelistedDomains.domainSet = Set(list)
        }
    }

    func fileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent(self.filename)
    }

    // Get the whitelist domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func asJSON() -> String {
        if self.whitelistedDomains.domainSet.isEmpty {
            return ""
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "'*" + self.whitelistedDomains.domainSet.joined(separator: "','*") + "'"
        return ", {'action': { 'type': 'ignore-previous-rules' }, 'trigger': { 'url-filter': '.*', 'if-domain': [\(list)] }}".replacingOccurrences(of: "'", with: "\"")
    }

    func whitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        guard let domain = self.whitelistableDomain(fromUrl: url) else { return }

        if enable {
            self.whitelistedDomains.domainSet.insert(domain)
        } else {
            self.whitelistedDomains.domainSet.remove(domain)
        }

        self.updateWhitelist(completion: completion)
    }

    private func updateWhitelist(completion: (() -> Void)?) {
        self.cleanupStore?(completion)

        guard let fileURL = self.fileURL() else { return }
        if self.whitelistedDomains.domainSet.isEmpty {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }

        let list = self.whitelistedDomains.domainSet.joined(separator: "\n")
        do {
            try list.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save whitelist file: \(error)")
        }
    }

    func isWhitelisted(url: URL) -> Bool {
        guard let domain = self.whitelistableDomain(fromUrl: url) else {
            return false
        }
        return self.whitelistedDomains.domainSet.contains(domain)
    }

    private func readWhitelistFile() -> [String]? {
        guard let fileURL = self.fileURL() else { return nil }
        let text = try? String(contentsOf: fileURL, encoding: .utf8)
        if let text = text, !text.isEmpty {
            return text.components(separatedBy: .newlines)
        }
        return nil
    }

    // Ensure domains used for whitelisting are standardized by using this function.
    private func whitelistableDomain(fromUrl url: URL) -> String? {
        guard let domain = url.host, !domain.isEmpty else {
            return nil
        }
        return domain
    }
}
