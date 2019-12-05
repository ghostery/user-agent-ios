import Foundation

class PrivacyIndicatorCanvasView: UIView {
    private var cachedSliceLayers: [CGColor: CAShapeLayer] = [:]
    private var backgroundTrackLayer: CAShapeLayer?
    private var greenLayer: CAShapeLayer?
    private var strikeThroughLayer: CAShapeLayer?
    private var cachedStats: [WTMCategory: Int] = [:]
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

        let color =  UIColor(named: "PrivacyIndicatorBackground")!.cgColor
        backgroundTrackLayer = circleLayer(for: color, useCache: false)
        self.layer.addSublayer(backgroundTrackLayer!)

        switch status {
        case .Disabled, .Whitelisted:
            addStrikeThroughToChart()
        case .NoBlockedURLs:
            addGreenIndicatorToChart()
        case .Blocking, .AdBlockWhitelisted, .AntiTrackingWhitelisted:
            addTrackersToChart(status: status)
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

    func addTrackersToChart(status: BlockerStatus) {
        let n = CGFloat(cachedStats.values.reduce(0, +))
        var j = PrivacyIndicatorUtils.CircleIterator(n: n)
        for (statsType, value) in cachedStats
            .sorted(by: { String(describing: $0) < String(describing: $1) }) {
                let color = statsType.color.cgColor
                addTrackerToChart(value, color, &j)
        }
    }

    func addTrackerToChart(
      _ value: Int,
      _ color: CGColor,
      _ j: inout PrivacyIndicatorUtils.CircleIterator
    ) {
        if value == 0 { return }
        j.advance(CGFloat(value))
        let layer = circleLayer(for: color)
        layer.strokeStart = j.current
        layer.strokeEnd = j.next
        self.layer.addSublayer(layer)
    }

    private func removeTrackersFromChart() {
        for (statsType, _) in cachedStats {
            let layer = circleLayer(for: statsType.color.cgColor)
            layer.strokeStart = 0
            layer.strokeEnd = 0
        }
    }

    private func addStrikeThroughToChart() {
        let width = self.frame.width
        let maxX = self.bounds.maxX
        let maxY = self.bounds.maxY
        if strikeThroughLayer == nil {
            strikeThroughLayer = PrivacyIndicatorUtils.createStrike(width, maxX, maxY)
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
            let layer = circleLayer(for: color, useCache: false)
            self.layer.addSublayer(layer)
            greenLayer = layer
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

        let width = self.frame.width
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        let layer = PrivacyIndicatorUtils.createCircle(center, width, color)
        if useCache { cachedSliceLayers[color] = layer }
        return layer
    }
}
