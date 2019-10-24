//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

extension WTMCategory {
    /// Return all possible WTMCategory values in default ordering. (always try to use this ordering for consistency reasons)
    static func all() -> [WTMCategory] {
        [
            advertising, analytics, content, social, essential, misc, hosting, pornvertising,
            audioVideoPlayer, extensions, customerInteraction, comments, cdn, unknown,
        ]
    }

    /// Convert the stats object into a dictionary with TPPageStatsType as Keys
    static func statsDict(from stats: TPPageStats) -> [WTMCategory: Int] {
        var dict = [WTMCategory: Int]()

        dict[.advertising] = stats.adCount
        dict[.analytics] = stats.analyticCount
        dict[.content] = stats.contentCount
        dict[.social] = stats.socialCount
        dict[.essential] = stats.essentialCount
        dict[.misc] = stats.miscCount
        dict[.hosting] = stats.hostingCount
        dict[.pornvertising] = stats.pornvertisingCount
        dict[.audioVideoPlayer] = stats.audioVideoPlayerCount
        dict[.extensions] = stats.extensionsCount
        dict[.customerInteraction] = stats.customerInteractionCount
        dict[.cdn] = stats.cdnCount
        dict[.unknown] = stats.unknownCount

        return dict
    }

    var color: UIColor {
        switch self {
        case .advertising:
            return UIColor(named: "Advertising")!
        case .analytics:
            return UIColor(named: "SiteAnalytics")!
        case .content:
            return UIColor(named: "Advertising")!
        case .social:
            return UIColor(named: "SocialMedia")!
        case .essential:
            return UIColor(named: "Essential")!
        case .misc:
            return UIColor(named: "Misc")!
        case .hosting:
            return UIColor(named: "Hosting")!
        case .pornvertising:
            return UIColor(named: "Pornvertising")!
        case .audioVideoPlayer:
            return UIColor(named: "AudioVideoPlayer")!
        case .extensions:
            return UIColor(named: "Extensions")!
        case .customerInteraction:
            return UIColor(named: "CustomerInteraction")!
        case .comments:
            return UIColor(named: "Comments")!
        case .cdn:
            return UIColor(named: "Cdn")!
        default:
            return UIColor(named: "Unknown")!
        }
    }

    var localizedName: String {
        switch self {
        case .advertising:
            return Strings.TrackingProtectionAdsBlocked
        case .analytics:
            return Strings.TrackingProtectionAnalyticsBlocked
        case .content:
            return Strings.TrackingProtectionContentBlocked
        case .social:
            return Strings.TrackingProtectionSocialBlocked
        case .essential:
            return "esential" // TODO: Localize
        case .misc:
            return "missc" // TODO: Localize
        case .hosting:
            return "hoting" // TODO: Localize
        case .pornvertising:
            return "pronvertising" // TODO: Localize
        case .audioVideoPlayer:
            return "audoi vidoi" // TODO: Localize
        case .extensions:
            return "extenciones" // TODO: Localize
        case .customerInteraction:
            return "cutsomer intaractions" // TODO: Localize
        case .comments:
            return "commentz" // TODO: Localize
        case .cdn:
            return "cnd" // TODO: Localize
        default:
            return "unkanonwn" // TODO: Localize
        }
    }
}
