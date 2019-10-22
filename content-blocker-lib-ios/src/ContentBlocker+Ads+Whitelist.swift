/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

extension ContentBlocker {

    func adsWhitelistFileURL() -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent("ads_whitelist")
    }

    // Get the whitelist domain array as a JSON fragment that can be inserted at the end of a blocklist.
    func adsWhitelistAsJSON() -> String {
        if self.adsWhitelistedDomains.domainSet.isEmpty {
            return ""
        }
        // Note that * is added to the front of domains, so foo.com becomes *foo.com
        let list = "'*" + self.adsWhitelistedDomains.domainSet.joined(separator: "','*") + "'"
        return ", {'action': { 'type': 'ignore-previous-rules' }, 'trigger': { 'url-filter': '.*', 'if-domain': [\(list)] }}".replacingOccurrences(of: "'", with: "\"")
    }

    func adsWhitelist(enable: Bool, url: URL, completion: (() -> Void)?) {
        guard let domain = self.whitelistableDomain(fromUrl: url) else { return }

        if enable {
            self.adsWhitelistedDomains.domainSet.insert(domain)
        } else {
            self.adsWhitelistedDomains.domainSet.remove(domain)
        }

        self.updateAdsWhitelist(completion: completion)
    }

    func clearAdsWhitelist(completion: (() -> Void)?) {
        self.adsWhitelistedDomains.domainSet = Set<String>()
        self.updateAdsWhitelist(completion: completion)
    }

    private func updateAdsWhitelist(completion: (() -> Void)?) {
        self.removeAllRulesInStore {
            self.compileListsNotInStore {
                completion?()
                NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)

            }
        }

        guard let fileURL = self.adsWhitelistFileURL() else { return }
        if self.adsWhitelistedDomains.domainSet.isEmpty {
            try? FileManager.default.removeItem(at: fileURL)
            return
        }

        let list = self.adsWhitelistedDomains.domainSet.joined(separator: "\n")
        do {
            try list.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save whitelist file: \(error)")
        }
    }

    func isAdsWhitelisted(url: URL) -> Bool {
        guard let domain = self.whitelistableDomain(fromUrl: url) else {
            return false
        }
        return self.adsWhitelistedDomains.domainSet.contains(domain)
    }

    func readAdsWhitelistFile() -> [String]? {
        guard let fileURL = self.adsWhitelistFileURL() else { return nil }
        let text = try? String(contentsOf: fileURL, encoding: .utf8)
        if let text = text, !text.isEmpty {
            return text.components(separatedBy: .newlines)
        }
        return nil
    }

}
