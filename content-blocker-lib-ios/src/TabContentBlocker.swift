/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import WebKit

extension Notification.Name {
   public static let didChangeContentBlocking = Notification.Name("didChangeContentBlocking")
   public static let contentBlockerTabSetupRequired = Notification.Name("contentBlockerTabSetupRequired")
}

protocol ContentBlockerTab: class {
    func currentURL() -> URL?
    func currentWebView() -> WKWebView?
}

class TabContentBlocker {
    weak var tab: ContentBlockerTab?

    var isPrivacyDashboardEnabled: Bool {
        return false
    }

    @objc func notifiedTabSetupRequired() {}

    func notifyContentBlockingChanged() {}

    var status: BlockerStatus {
        guard self.isPrivacyDashboardEnabled else {
            return .Disabled
        }
        guard let url = tab?.currentURL() else {
            return .NoBlockedURLs
        }
        let isAdBlockWhitelisted = self.isPrivacyDashboardEnabled && ContentBlocker.shared.isAdsWhitelisted(url: url)
        let isAntiTrackingWhitelisted = self.isPrivacyDashboardEnabled && ContentBlocker.shared.isTrackingWhitelisted(url: url)

        if stats.total == 0 {
            if isAdBlockWhitelisted && isAntiTrackingWhitelisted {
                return .Whitelisted
            }
            return .NoBlockedURLs
        } else {
            if isAdBlockWhitelisted {
                return .AdBlockWhitelisted
            } else if isAntiTrackingWhitelisted {
                return .AntiTrackingWhitelisted
            }
            return .Blocking
        }
    }

    var stats: TPPageStats = TPPageStats() {
        didSet {
            guard self.tab != nil else { return }
            notifyContentBlockingChanged()
        }
    }

    init(tab: ContentBlockerTab) {
        self.tab = tab
        NotificationCenter.default.addObserver(self, selector: #selector(notifiedTabSetupRequired), name: .contentBlockerTabSetupRequired, object: nil)
    }

    func scriptMessageHandlerName() -> String? {
        return "trackingProtectionStats"
    }

    class func prefsChanged() {
        // This class func needs to notify all the active instances of ContentBlocker to update.
        NotificationCenter.default.post(name: .contentBlockerTabSetupRequired, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
