/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Shared

enum WTMCategory: String {
    case advertising = "advertising"
    case analytics = "site_analytics"
    case content = "content"
    case social = "social_media"
    case essential = "essential"
    case misc = "misc"
    case hosting = "hosting"
    case pornvertising = "pornvertising"
    case audioVideoPlayer = "audio_video_player"
    case extensions = "extensions"
    case customerInteraction = "customer_interaction"
    case comments = "comments"
    case cdn = "cdn"
    case unknown = "unknown"
}

struct Tracker: Hashable {
    var category: WTMCategory
    var id: String
}

struct TPPageStats {
    private (set) var adCount: Int = 0
    private (set) var analyticCount: Int = 0
    private (set) var contentCount: Int = 0
    private (set) var socialCount: Int = 0
    private (set) var essentialCount: Int = 0
    private (set) var miscCount: Int = 0
    private (set) var hostingCount: Int = 0
    private (set) var pornvertisingCount: Int = 0
    private (set) var audioVideoPlayerCount: Int = 0
    private (set) var extensionsCount: Int = 0
    private (set) var customerInteractionCount: Int = 0
    private (set) var commentsCount: Int = 0
    private (set) var cdnCount: Int = 0
    private (set) var unknownCount: Int = 0

    private (set) var trackers: Set<Tracker> = []

    var total: Int {
        return self.adCount + self.socialCount + self.analyticCount + self.contentCount + self.essentialCount + self.miscCount + self.hostingCount + self.pornvertisingCount + self.audioVideoPlayerCount + self.extensionsCount + self.customerInteractionCount + self.commentsCount + self.cdnCount + self.unknownCount
    }

    mutating func update(byAddingTracker tracker: Tracker) {
        self.trackers.insert(tracker)
        switch tracker.category {
        case .advertising:
            self.adCount += 1
        case .analytics:
            self.analyticCount += 1
        case .content:
            self.contentCount += 1
        case .social:
            self.socialCount += 1
        case .essential:
            self.essentialCount += 1
        case .misc:
            self.miscCount += 1
        case .hosting:
            self.hostingCount += 1
        case .pornvertising:
            self.pornvertisingCount += 1
        case .audioVideoPlayer:
            self.audioVideoPlayerCount += 1
        case .extensions:
            self.extensionsCount += 1
        case .customerInteraction:
            self.customerInteractionCount += 1
        case .comments:
            self.commentsCount += 1
        case .cdn:
            self.cdnCount += 1
        case .unknown:
            self.unknownCount += 1
        }
    }
}

class TPStatsBlocklistChecker {
    static let shared = TPStatsBlocklistChecker()

    // Initialized async, is non-nil when ready to be used.
    private var blockLists: TPStatsBlocklists?

    func isBlocked(url: URL) -> Deferred<Tracker?> {
        let deferred = Deferred<Tracker?>()

        guard let blockLists = blockLists, let host = url.host, !host.isEmpty else {
            // TP Stats init isn't complete yet
            deferred.fill(nil)
            return deferred
        }

        // Make a copy on the main thread
        let allowListRegex = ContentBlocker.shared.allowLists.ads.allowListedDomains.domainRegex + ContentBlocker.shared.allowLists.trackers.allowListedDomains.domainRegex

        DispatchQueue.global().async {
            deferred.fill(
                blockLists.urlIsInCategory(url, allowListedDomains: allowListRegex)
            )
        }
        return deferred
    }

    func startup() {
        DispatchQueue.global().async {
            let parser = TPStatsBlocklists()
            parser.load()
            DispatchQueue.main.async {
                self.blockLists = parser
            }
        }
    }
}

// The 'unless-domain' and 'if-domain' rules use wildcard expressions, convert this to regex.
func wildcardContentBlockerDomainToRegex(domain: String) -> String? {
    struct Memo { static var domains =  [String: String]() }

    if let memoized = Memo.domains[domain] {
        return memoized
    }

    // Convert the domain exceptions into regular expressions.
    var regex = domain + "$"
    if regex.first == "*" {
        regex = "." + regex
    }
    regex = regex.replacingOccurrences(of: ".", with: "\\.")

    Memo.domains[domain] = regex
    return regex
}

class TPStatsBlocklists {
    private var trackers = [String: (Tracker)]()

    func load() {
        do {
            guard let path = Bundle.main.path(forResource: "tracker_db_v2", ofType: "json") else {
                assertionFailure("Blocklists: bad file path.")
                return
            }

            let json = try Data(contentsOf: URL(fileURLWithPath: path))
            guard let data = try JSONSerialization.jsonObject(with: json, options: []) as? [String: AnyObject] else {
                assertionFailure("Blocklists: bad JSON cast.")
                return
            }
            guard let apps = data["apps"] as? [String: AnyObject] else {
                assertionFailure("Blocklists: bad JSON cast.")
                return
            }
            var categories = [String: String]()
            for app in apps {
                if
                    let value = app.value as? [String: AnyObject],
                    let category = value["cat"] as? String
                {
                    categories[app.key] = category
                }
            }
            guard let domains = data["domains"] as? [String: AnyObject] else {
                assertionFailure("Blocklists: bad JSON cast.")
                return
            }
            for domain in domains {
                let id = String(describing: domain.value)
                guard
                    let category = categories[id],
                    let wtmCategory = WTMCategory(rawValue: category)
                else {
                    continue
                }
                self.trackers[domain.key] = Tracker(category: wtmCategory, id: id)
            }
        } catch {
            assertionFailure("Blocklists: \(error.localizedDescription)")
            return
        }
    }

    func urlIsInCategory(_ url: URL, allowListedDomains: [String]) -> Tracker? {
        guard let baseDomain = url.baseDomain else {
            return nil
        }
        guard let tracker = self.trackers[baseDomain] else {
            return nil
        }

        // Check the allowList.
        if !allowListedDomains.isEmpty {
            for ignoreDomain in allowListedDomains {
                if baseDomain.range(of: ignoreDomain, options: .regularExpression) != nil {
                    return nil
                }
            }
        }
        return tracker
    }

}
