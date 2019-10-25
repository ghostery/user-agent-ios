//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Circle based Privacy Indicator
class PrivacyIndicatorView: UIView {
    // MARK: - Types
    enum Status {
        case enabled
        case disabled
    }

    // MARK: - Properties
    public var onButtonTap: (() -> Void)?

    public var status: BlockerStatus = .Blocking { didSet { updateStatus() }}

    private var cachedStats: [WTMCategory: Int] = [:]

    private lazy var canvasView = UIView()

    private var cachedSliceLayers: [CGColor: CAShapeLayer] = [:]
    private var backgroundTrackLayer: CAShapeLayer?

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
        setupBackgroundTrack()
    }

    // MARK: - API
    /// Update the Privacy Indicator with the specified TPPageStats object
    ///
    /// The update will be animated. You can call this method multiple times during load.
    /// - Parameter stats: The page stas to animate to.
    func update(with stats: TPPageStats) {
        DispatchQueue.main.async {
            self.cachedStats = WTMCategory.statsDict(from: stats)
            self.updateChart()
        }
    }
}

// MARK: - Private API
private extension PrivacyIndicatorView {
    @objc
    private func didPressButton(_ button: UIButton) {
        onButtonTap?()
    }

    private func updateChart() {
        var numberOfitems: Int = 0
        cachedStats.values.forEach { numberOfitems += $0 }

        var fromPercent: CGFloat = 0
        var toPercent: CGFloat = 0

        for (statsType, value) in cachedStats.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            if value == 0 { continue }
            // let value = cachedStats[statsType, default: 0]
            let color = statsType.color
            toPercent = fromPercent + CGFloat(value) / CGFloat(numberOfitems)
            let slice = layer(for: color.cgColor)
            slice.strokeStart = fromPercent
            slice.strokeEnd = toPercent
            canvasView.layer.addSublayer(slice)
            fromPercent = toPercent
        }
    }

    private func updateStatus() {
        // TODO
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

    private func setupBackgroundTrack() {
        backgroundTrackLayer = layer(for: UIColor.black.withAlphaComponent(0.3).cgColor, cache: false)
        canvasView.layer.addSublayer(backgroundTrackLayer!)
    }

    private func layer(for color: CGColor, cache: Bool = true) -> CAShapeLayer {
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

        cachedSliceLayers[color] = newPathLayer

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
