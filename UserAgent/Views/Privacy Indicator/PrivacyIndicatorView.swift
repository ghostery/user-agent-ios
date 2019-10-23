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
    // MARK: - Properties
    public var onButtonTap: (() -> Void)?

    private var cachedStats: [TPPageStatsType: Int] = [:]

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
        // TOOD: isHidden = true
        setupSubViews()
    }

    // MARK: - API
    /// Update the Privacy Indicator with the specified TPPageStats object
    ///
    /// The update will be animated. You can call this method multiple times during load.
    /// - Parameter stats: The page stas to animate to.
    func update(with stats: TPPageStats) {
        DispatchQueue.main.async {
            self.cachedStats[.adCount] = stats.adCount
            self.cachedStats[.analyticCount] = stats.analyticCount
            self.cachedStats[.contentCount] = stats.contentCount
            self.cachedStats[.socialCount] = stats.socialCount
            self.cachedStats[.essentialCount] = stats.essentialCount
            self.cachedStats[.miscCount] = stats.miscCount
            self.cachedStats[.hostingCount] = stats.hostingCount
            self.cachedStats[.pornvertisingCount] = stats.pornvertisingCount
            self.cachedStats[.audioVideoPlayerCount] = stats.audioVideoPlayerCount
            self.cachedStats[.extensionsCount] = stats.extensionsCount
            self.cachedStats[.customerInteractionCount] = stats.customerInteractionCount
            self.cachedStats[.cdnCount] = stats.cdnCount
            self.cachedStats[.unknownCount] = stats.unknownCount

            self.updateChart()
        }
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundTrackLayer?.removeFromSuperlayer()
        backgroundTrackLayer = layer(for: UIColor.black.withAlphaComponent(0.3).cgColor, cache: false)
        canvasView.layer.addSublayer(backgroundTrackLayer!)
    }

    // MARK: - Entities
    private enum TPPageStatsType {
        case adCount
        case analyticCount
        case contentCount
        case socialCount
        case essentialCount
        case miscCount
        case hostingCount
        case pornvertisingCount
        case audioVideoPlayerCount
        case extensionsCount
        case customerInteractionCount
        case commentsCount
        case cdnCount
        case unknownCount

        static func all() -> [TPPageStatsType] {
            [
                adCount, analyticCount, contentCount, socialCount, essentialCount, miscCount, hostingCount, pornvertisingCount,
                audioVideoPlayerCount, extensionsCount, customerInteractionCount, commentsCount, cdnCount, unknownCount,
            ]
        }
    }
}

// MARK: - Private API
private extension PrivacyIndicatorView {
    private func color(for statsType: TPPageStatsType) -> UIColor {
        switch statsType {
        case .adCount:
            return UIColor(named: "Advertising")!
        case .analyticCount:
            return UIColor(named: "SiteAnalytics")!
        case .contentCount:
            return UIColor(named: "Advertising")!
        case .socialCount:
            return UIColor(named: "SocialMedia")!
        case .essentialCount:
            return UIColor(named: "Essential")!
        case .miscCount:
            return UIColor(named: "Misc")!
        case .hostingCount:
            return UIColor(named: "Hosting")!
        case .pornvertisingCount:
            return UIColor(named: "Advertising")!
        case .audioVideoPlayerCount:
            return UIColor(named: "AudioVideoPlayer")!
        case .extensionsCount:
            return UIColor(named: "Advertising")!
        case .customerInteractionCount:
            return UIColor(named: "CustomerInteraction")!
        case .commentsCount:
            return UIColor(named: "Advertising")!
        case .cdnCount:
            return UIColor(named: "Cdn")!
        default:
            return UIColor(named: "Unknown")!
        }
    }

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
            let color = self.color(for: statsType)
            toPercent = fromPercent + CGFloat(value) / CGFloat(numberOfitems)
            let slice = layer(for: color.cgColor)
            slice.strokeStart = fromPercent
            slice.strokeEnd = toPercent
            canvasView.layer.addSublayer(slice)
            fromPercent = toPercent
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
