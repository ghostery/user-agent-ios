//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

private class BadgeView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = ""
        label.font = label.font.withSize(10)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func update(_ count: Int) {
        label.text = String(count)
    }

    private func setupView() {
        layer.cornerRadius = 3
        backgroundColor = .Grey60
        addSubview(label)
        setupLayout()
    }

    private func setupLayout() {
        label.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.topMargin.bottomMargin.equalTo(0)
            make.leftMargin.rightMargin.equalTo(2)
        }
    }
}

class PrivacyIndicatorView: UIView {
    public var onButtonTap: (() -> Void)?

    private lazy var enabledIcon = { UIImage.templateImageNamed("tracking-protection") }()
    private lazy var disabledIcon = { UIImage.templateImageNamed("tracking-protection-off") }()

    private lazy var badge = { BadgeView() }()

    private lazy var button: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.templateImageNamed("tracking-protection"), for: .normal)
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        button.tintColor = UIColor.Grey50
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    @objc
    private func didPressButton(_ button: UIButton) {
        onButtonTap?()
    }

    func updateBadge(_ count: Int) {
        badge.update(count)
    }

    func showStatusDisabled() {
        guard button.currentImage != disabledIcon else { return }
        badge.isHidden = true
        button.setImage(disabledIcon, for: .normal)
    }

    func showStatusEnabled() {
        guard button.currentImage != enabledIcon else { return }
        badge.isHidden = false
        button.setImage(enabledIcon, for: .normal)
    }

    private func setupView() {
        isHidden = true
        badge.isUserInteractionEnabled = false
        addSubview(button)
        addSubview(badge)
        setupLayout()
    }

    private func setupLayout() {
        button.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }

        badge.snp.makeConstraints { make in
            make.right.equalTo(self)
            make.top.equalTo(6)
        }
    }
}


// TODO: Update the above class with this code
class LivePrivacyIndicator: UIView {
    // MARK: - Properties
    public var categories: [UIColor: Int] = [:] { didSet { updateChart() }}

    private var sliceLayers: [CGColor: CAShapeLayer] = [:]
    private var fromPercentages: [UIColor: CGFloat] = [:]
    private var toPercentages: [UIColor: CGFloat] = [:]

    private lazy var canvasView = UIView()
    private var backgroundTrackLayer: CAShapeLayer?

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }

    // MARK: - Updating
    private func updateChart() {

        var numberOfitems: Int = 0
        categories.values.forEach { numberOfitems += $0 }

        var fromPercent: CGFloat = 0
        var toPercent: CGFloat = 0

        // Sorting the colors by their string representation does not make a lot of sense, except that
        // it keeps the sorting stable so parts of the graph don't suddenly jump around
        for (color, value) in categories.sorted(by: { String(describing: $0) < String(describing: $1) }) {
            toPercent = fromPercent + CGFloat(value) / CGFloat(numberOfitems)
            let slice = layer(for: color.cgColor)
            slice.strokeStart = fromPercent
            slice.strokeEnd = toPercent
            canvasView.layer.addSublayer(slice)
            fromPercentages[color] = fromPercent
            toPercentages[color] = toPercent
            fromPercent = toPercent
        }
    }

    // MARK: - Setup
    private func setupSubViews() {
        canvasView.backgroundColor = UIColor.white
        canvasView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(canvasView)
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
    }

    func layer(for color: CGColor, cache: Bool = true) -> CAShapeLayer {
        guard sliceLayers[color] == nil || !cache else {
            return sliceLayers[color]!
        }

        let canvasWidth = canvasView.frame.width
        let canvasCenter = CGPoint(x: canvasView.bounds.width / 2, y: canvasView.bounds.height / 2)
        let path = UIBezierPath(arcCenter: canvasCenter,
                                radius: canvasWidth * 3 / 8,
                                startAngle: percentToRadian(0),
                                endAngle: percentToRadian(0.9999),
                                clockwise: true)
        let backgroundLayer = CAShapeLayer()
        backgroundLayer.path = path.cgPath
        backgroundLayer.fillColor = nil
        backgroundLayer.strokeColor = color
        backgroundLayer.lineWidth = canvasWidth * 1 / 8
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1

        sliceLayers[color] = backgroundLayer

        return backgroundLayer
    }

    // MARK: - Internal Helper Functions
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

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundTrackLayer?.removeFromSuperlayer()
        backgroundTrackLayer = layer(for: UIColor.lightGray.cgColor, cache: false)
        backgroundTrackLayer?.lineWidth = (backgroundTrackLayer?.lineWidth ?? 0) + 2
        canvasView.layer.addSublayer(backgroundTrackLayer!)
    }
}
