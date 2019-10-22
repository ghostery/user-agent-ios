//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import WebKit

extension ContentBlocker {

    func trackingWhitelistFileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent("whitelist")
    }

    // Get the whitelist domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func trackingWhitelistAsJSON() -> String {
        if self.trackingWhitelistedDomains.domainSet.isEmpty {
            return ""
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "'*" + self.trackingWhitelistedDomains.domainSet.joined(separator: "','*") + "'"
        return ", {'action': { 'type': 'ignore-previous-rules' }, 'trigger': { 'url-filter': '.*', 'if-domain': [\(list)] }}".replacingOccurrences(of: "'", with: "\"")
    }

    func trackingWhitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        guard let domain = whitelistableDomain(fromUrl: url) else { return }

        if enable {
            self.trackingWhitelistedDomains.domainSet.insert(domain)
        } else {
            self.trackingWhitelistedDomains.domainSet.remove(domain)
        }

        updateTrackingWhitelist(completion: completion)
    }

    func clearTrackingWhitelist(completion: (() -> Void)?) {
        self.trackingWhitelistedDomains.domainSet = Set<String>()
        self.updateTrackingWhitelist(completion: completion)
    }

    private func updateTrackingWhitelist(completion: (() -> Void)?) {
        self.removeAllRulesInStore {
            self.compileListsNotInStore {
                completion?()
                NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)

            }
        }

        guard let fileURL = self.trackingWhitelistFileURL() else { return }
        if self.trackingWhitelistedDomains.domainSet.isEmpty {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }

        let list = self.trackingWhitelistedDomains.domainSet.joined(separator: "\n")
        do {
            try list.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save whitelist file: \(error)")
        }
    }

    func isTrackingWhitelisted(url: URL) -> Bool {
        guard let domain = self.whitelistableDomain(fromUrl: url) else {
            return false
        }
        return self.trackingWhitelistedDomains.domainSet.contains(domain)
    }

    func readTrackingWhitelistFile() -> [String]? {
        guard let fileURL = self.trackingWhitelistFileURL() else { return nil }
        let text = try? String(contentsOf: fileURL, encoding: .utf8)
        if let text = text, !text.isEmpty {
            return text.components(separatedBy: .newlines)
        }

        return nil
    }
}
