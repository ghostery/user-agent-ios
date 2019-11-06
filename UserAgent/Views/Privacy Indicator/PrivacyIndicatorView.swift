//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Circle based Privacy Indicator
///
/// Configure with `onTapBlock:` and `status`, then update with the `update:` method.
class PrivacyIndicatorView: UIView {
    // MARK: - Properties
    /// Call this block whenever the user taps the Privacy Indicator
    public var onTapBlock: (() -> Void)?

    /// Set the status to configure the Privacy Indicator
    ///
    /// - Disabled: The Privacy Indicator is seen as strike through
    /// - NoBlockedURLs: The Privacy Indicator is green
    /// - Whitelisted: The Privacy Indicator is gray
    /// - Blocking: The Privacy Indicator is filling up with color representations of various trackers found on the page
    public var status: BlockerStatus = .Blocking { didSet { updateStatus() }}

    override var bounds: CGRect { didSet { relayout() }}

    private var cachedStats: [WTMCategory: Int] = [:]
    private lazy var canvasView = UIView()
    private var cachedSliceLayers: [CGColor: CAShapeLayer] = [:]
    private var backgroundTrackLayer: CAShapeLayer?
    private var greenLayer: CAShapeLayer?
    private var strikeThroughLayer: CAShapeLayer?
    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        return button
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    private func setupView() {
        setupSubViews()
    }

    // MARK: - API
    /// Update the Privacy Indicator with the specified TPPageStats object
    ///
    /// The update will be animated. You can call this method multiple times during load.
    /// - Parameter stats: The page stas to animate to.
    func update(with stats: TPPageStats) {
        DispatchQueue.main.async {
            self.cachedStats = WTMCategory.statsDict(from: stats)
            self.addTrackersToChart()
        }
    }
}

// MARK: - Private API
private extension PrivacyIndicatorView {
    @objc
    private func didPressButton(_ button: UIButton) {
        onTapBlock?()
    }

    private func relayout() {
        backgroundTrackLayer?.removeFromSuperlayer()
        backgroundTrackLayer = circleLayer(for: UIColor(named: "PrivacyIndicatorBackground")!.cgColor, cache: false)
        canvasView.layer.addSublayer(backgroundTrackLayer!)

        greenLayer?.removeFromSuperlayer()
        greenLayer = nil

        cachedSliceLayers.values.forEach { $0.removeFromSuperlayer() }
        cachedSliceLayers = [:]

        strikeThroughLayer?.removeFromSuperlayer()
        strikeThroughLayer = nil
    }

    private func addTrackersToChart() {
        guard status == .Blocking else { return }

        var numberOfitems: Int = 0
        cachedStats.values.forEach { numberOfitems += $0 }

        var fromPercent: CGFloat = 0
        var toPercent: CGFloat = 0

        for (statsType, value) in cachedStats.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            if value == 0 { continue }
            // let value = cachedStats[statsType, default: 0]
            let color = statsType.color
            toPercent = fromPercent + CGFloat(value) / CGFloat(numberOfitems)
            let slice = circleLayer(for: color.cgColor)
            slice.strokeStart = fromPercent
            slice.strokeEnd = toPercent
            canvasView.layer.addSublayer(slice)
            fromPercent = toPercent
        }
    }

    private func removeTrackersFromChart() {
        for (statsType, _) in cachedStats {
            let color = statsType.color
            let slice = circleLayer(for: color.cgColor)
            slice.strokeStart = 0
            slice.strokeEnd = 0
        }
    }

    private func addStrikeThroughToChart() {
        if strikeThroughLayer == nil {
            let canvasWidth = canvasView.frame.width

            // GEOMETRY!
            let radius = canvasWidth * 3 / 8
            let diagonalLength = sqrt(canvasWidth * canvasWidth + canvasWidth * canvasWidth)
            let distanceFromCorner = (diagonalLength / 2) - radius
            let verticalDistanceFromCorner = sqrt( (distanceFromCorner * distanceFromCorner) / 2 )

            let path = UIBezierPath()
            path.move(to: CGPoint(x: verticalDistanceFromCorner, y: verticalDistanceFromCorner))
            path.addLine(to: CGPoint(x: canvasView.bounds.maxX - verticalDistanceFromCorner, y: canvasView.bounds.maxY - verticalDistanceFromCorner))

            strikeThroughLayer = CAShapeLayer()
            strikeThroughLayer?.path = path.cgPath
            strikeThroughLayer?.fillColor = nil
            strikeThroughLayer?.strokeColor = UIColor(named: "PrivacyIndicatorBackground")!.cgColor
            strikeThroughLayer?.lineWidth = canvasWidth * 1 / 8

            guard let strikeThroughLayer = strikeThroughLayer else { return }
            canvasView.layer.addSublayer(strikeThroughLayer)
        }

        strikeThroughLayer?.strokeStart = 0
        strikeThroughLayer?.strokeEnd = 1
    }

    private func removeStrikeThroughFromChart() {
        strikeThroughLayer?.strokeStart = 0.5
        strikeThroughLayer?.strokeEnd = 0.5
    }

    private func addGreenIndicatorToChart() {
        if greenLayer == nil {
            let newGreenLayer = circleLayer(for: UIColor(named: "NoTrackersSeen")!.cgColor, cache: false)
            canvasView.layer.addSublayer(newGreenLayer)
            greenLayer = newGreenLayer
        }

        greenLayer?.strokeStart = 0
        greenLayer?.strokeEnd = 1
    }

    private func removeGreenIndicatorFromChart() {
        greenLayer?.strokeStart = 1
        greenLayer?.strokeEnd = 1
    }

    private func updateStatus() {
        removeTrackersFromChart()
        removeStrikeThroughFromChart()
        removeGreenIndicatorFromChart()

        switch status {
        case .Disabled:
            // The Privacy Indicator is seen as strike through
            addStrikeThroughToChart()
        case .NoBlockedURLs:
            // The Privacy Indicator is green
            addGreenIndicatorToChart()
        case .Whitelisted:
            // The Privacy Indicator is gray
            break
        case .Blocking:
            // The Privacy Indicator is filling up with color representations of various trackers found on the page
            addTrackersToChart()
        }
    }

    private func setupSubViews() {
        addSubview(canvasView)
        addSubview(button)

        canvasView.translatesAutoresizingMaskIntoConstraints = false
        canvasView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        canvasView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        canvasView.heightAnchor.constraint(equalTo: canvasView.widthAnchor).isActive = true

        [
            canvasView.widthAnchor.constraint(equalTo: widthAnchor),
            canvasView.heightAnchor.constraint(equalTo: heightAnchor),
        ].forEach {
            $0.priority = .defaultHigh
            $0.isActive = true
        }

        button.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }
    }

    private func circleLayer(for color: CGColor, cache: Bool = true) -> CAShapeLayer {
        guard cachedSliceLayers[color] == nil || !cache else {
            return cachedSliceLayers[color]!
        }

        let canvasWidth = canvasView.frame.width
        let canvasCenter = CGPoint(x: canvasView.bounds.width / 2, y: canvasView.bounds.height / 2)
        let path = UIBezierPath(arcCenter: canvasCenter,
                                radius: canvasWidth * 3 / 8,
                                startAngle: percentToRadian(0),
                                endAngle: percentToRadian(0.9999),
                                clockwise: true)
        let newPathLayer = CAShapeLayer()
        newPathLayer.path = path.cgPath
        newPathLayer.fillColor = nil
        newPathLayer.strokeColor = color
        newPathLayer.lineWidth = canvasWidth * 1 / 8
        newPathLayer.strokeStart = 0
        newPathLayer.strokeEnd = 1

        if cache {
            cachedSliceLayers[color] = newPathLayer
        }

        return newPathLayer
    }

    /// Convert slice percent to radian.
    ///
    /// - Parameter percent: Slice percent (0.0 - 1.0).
    /// - Returns: Radian
    private func percentToRadian(_ percent: CGFloat) -> CGFloat {
        //Because angle starts wtih X positive axis, add 270 degrees to rotate it to Y positive axis.
        var angle = 270 + percent * 360
        if angle >= 360 {
            angle -= 360
        }
        return angle * CGFloat.pi / 180.0
    }
}
