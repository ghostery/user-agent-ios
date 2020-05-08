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

    var isAntiTrackingEnabled: Bool {
        return false
    }

    var isAdBlockingEnabled: Bool {
        return false
    }

    var isPopupBlockerEnabled: Bool {
        return false
    }

    @objc func notifiedTabSetupRequired() {}

    func notifyContentBlockingChanged() {}

    var status: BlockerStatus {
        guard self.isAntiTrackingEnabled || self.isAdBlockingEnabled else {
            return .Disabled
        }
        guard let url = tab?.currentURL() else {
            return .NoBlockedURLs
        }
        let isAdBlockAllowListed = self.isAdBlockingEnabled && ContentBlocker.shared.isAdsAllowListed(url: url)
        let isAntiTrackingAllowListed = self.isAntiTrackingEnabled && ContentBlocker.shared.isTrackingAllowListed(url: url)

        if stats.total == 0 {
            if isAdBlockAllowListed && isAntiTrackingAllowListed {
                return .AllowListed
            }
            return .NoBlockedURLs
        } else {
            if isAdBlockAllowListed {
                return .AdBlockAllowListed
            } else if isAntiTrackingAllowListed {
                return .AntiTrackingAllowListed
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
