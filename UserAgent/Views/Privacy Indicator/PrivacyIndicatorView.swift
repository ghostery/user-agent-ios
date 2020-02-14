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
        if [.Disabled, .AllowListed].contains(status) {
            let color = UIColor(named: "PrivacyIndicatorBackground")!
            return (arcs: [(color, 1)], strike: (color, 1))
        }
        let arcsWithKeys: [(UIColor, Int, WTMCategory)] = WTMCategory.statsDict(from: stats)
            .map { (key, value) in (key.color, value, key) }
            .filter { $0.1 != 0 }
            .sorted(by: { String(describing: $1.2) < String(describing: $0.2) })
        let arcs: [(UIColor, Int)] = arcsWithKeys.map { (color, value, key) in (color, value) }
        return (arcs: arcs, strike: nil)
    }
}
