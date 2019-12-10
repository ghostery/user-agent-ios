import Foundation

class PrivacyIndicatorCanvasView: UIView {
    private var cachedSliceLayers: [CGColor: CAShapeLayer] = [:]
    private var cachedStats: [WTMCategory: Int] = [:]
    private var backgroundTrackLayer: CAShapeLayer?
    private var greenLayer: CAShapeLayer?
    private var strikeThroughLayer: CAShapeLayer?
}

extension PrivacyIndicatorCanvasView {
    func render(with stats: TPPageStats, status: BlockerStatus) {
        DispatchQueue.main.async { [weak self] in
            if self == nil { return }
            self!.cachedStats = WTMCategory.statsDict(from: stats)
            self!.render(status: status)
        }
    }

    func relayout(status: BlockerStatus) {
        reset()
        render(status: status)
    }
}

fileprivate extension PrivacyIndicatorCanvasView {
    func render(status: BlockerStatus) {
        removeTrackersFromChart()
        removeStrikeThroughFromChart()
        removeGreenIndicatorFromChart()
        addBackgroundToChart()

        switch status {
        case .Disabled, .Whitelisted:
            addStrikeThroughToChart()
        case .NoBlockedURLs:
            addGreenIndicatorToChart()
        case .Blocking, .AdBlockWhitelisted, .AntiTrackingWhitelisted:
            addTrackersToChart()
        }
    }

    func reset() {
        backgroundTrackLayer?.removeFromSuperlayer()
        greenLayer?.removeFromSuperlayer()
        strikeThroughLayer?.removeFromSuperlayer()
        cachedSliceLayers.values.forEach { $0.removeFromSuperlayer() }

        greenLayer = nil
        strikeThroughLayer = nil
        backgroundTrackLayer = nil
        cachedSliceLayers = [:]
    }

    func addBackgroundToChart() {
        if backgroundTrackLayer == nil {
            let color = UIColor(named: "PrivacyIndicatorBackground")!.cgColor
            backgroundTrackLayer = circleLayer(for: color, useCache: false)
            self.layer.addSublayer(backgroundTrackLayer!)
        }
    }

    func addTrackersToChart() {
        let n = CGFloat(cachedStats.values.reduce(0, +))
        var range = PrivacyIndicatorUtils.CircleRange(count: n)
        for (statsType, value) in cachedStats
            .sorted(by: { String(describing: $0) < String(describing: $1) }) {
                let color = statsType.color.cgColor
                addTrackerToChart(value, color, &range)
        }
    }

    func addTrackerToChart(
        _ value: Int,
        _ color: CGColor,
        _ r: inout PrivacyIndicatorUtils.CircleRange
    ) {
        if value == 0 { return }
        r.advance(CGFloat(value))
        let layer = circleLayer(for: color)
        layer.strokeStart = r.first
        layer.strokeEnd = r.last
        if layer.superlayer != self.layer {
            self.layer.addSublayer(layer)
        }
    }

    private func removeTrackersFromChart() {
        for (statsType, _) in cachedStats {
            let layer = circleLayer(for: statsType.color.cgColor)
            layer.strokeStart = 0
            layer.strokeEnd = 0
        }
    }

    private func addStrikeThroughToChart() {
        if strikeThroughLayer == nil {
            strikeThroughLayer = PrivacyIndicatorUtils.createStrike(
                self.frame.width,
                self.bounds.maxX,
                self.bounds.maxY
            )
            self.layer.addSublayer(strikeThroughLayer!)
        }
        strikeThroughLayer!.strokeStart = 0
        strikeThroughLayer!.strokeEnd = 1
    }

    private func removeStrikeThroughFromChart() {
        strikeThroughLayer?.strokeStart = 0.5
        strikeThroughLayer?.strokeEnd = 0.5
    }

    private func addGreenIndicatorToChart() {
        if greenLayer == nil {
            let color = UIColor(named: "NoTrackersSeen")!.cgColor
            greenLayer = circleLayer(for: color, useCache: false)
            self.layer.addSublayer(greenLayer!)
        }

        greenLayer!.strokeStart = 0
        greenLayer!.strokeEnd = 1
    }

    private func removeGreenIndicatorFromChart() {
        greenLayer?.strokeStart = 1
        greenLayer?.strokeEnd = 1
    }

    private func circleLayer(for color: CGColor, useCache: Bool = true) -> CAShapeLayer {
        if useCache && cachedSliceLayers[color] != nil {
            return cachedSliceLayers[color]!
        }
        let layer = PrivacyIndicatorUtils.createCircle(
            CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
            self.frame.width,
            color
        )
        if useCache { cachedSliceLayers[color] = layer }
        return layer
    }
}
