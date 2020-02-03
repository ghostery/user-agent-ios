import Foundation
import Widgets

enum PrivacyIndicatorTransformation {
    static func transform(
        status: BlockerStatus,
        stats: TPPageStats
    ) -> (arcs: [PrivacyIndicator.Segment], strike: PrivacyIndicator.Segment?) {
        if status == .NoBlockedURLs {
            let color = UIColor(named: "NoTrackersSeen")!
            return (arcs: [(color, 1)], strike: nil)
        }
        if [.Disabled, .Whitelisted].contains(status) {
            let color = UIColor(named: "PrivacyIndicatorBackground")!
            return (arcs: [(color, 1)], strike: (color, 1))
        }
        let arcs: [(UIColor, Int)] = WTMCategory.statsDict(from: stats)
            .map { (key, value) in (key.color, value) }
            .filter { $0.1 != 0 }
            .sorted(by: { $1.1 < $0.1 })
        return (arcs: arcs, strike: nil)
    }
}
