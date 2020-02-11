import UIKit

extension PrivacyIndicator {
    class CanvasView: UIView {
        var arcs: [Segment] = []
        var strike: Segment?
        private var pool = (arcs: Pool<Circle>(), strikes: Pool<Strike>())
        override func didMoveToSuperview() {
            super.didMoveToSuperview()
            self.setConstraints()
        }

        override var bounds: CGRect {
            didSet {
                self.pool.arcs.settings = self.getSettingForCircle()
                self.pool.strikes.settings = self.getSettingForStrike()
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            self.pool.arcs.reallocate(with: self.arcs.count)
            self.pool.strikes.reallocate(with: self.strike == nil ? 0 : 1)
            self.drawArcs()
            self.drawStrikes()
        }
    }
}

extension PrivacyIndicator.CanvasView {
    func update(
        arcs: [PrivacyIndicator.Segment],
        strike: PrivacyIndicator.Segment?
    ) {
        self.arcs = arcs
        self.strike = strike
        self.setNeedsLayout()
    }
}

fileprivate extension PrivacyIndicator.CanvasView {
    func drawArcs() {
        let n = CGFloat(self.arcs.map { $0.1 }.reduce(0, +))
        var range = PrivacyIndicator.utils.CircleRange(count: n)
        self.arcs.forEach { self.drawArc($0, &range) }
    }

    func drawArc(
        _ segment: PrivacyIndicator.Segment,
        _ r: inout PrivacyIndicator.utils.CircleRange
    ) {
        let (color, value) = segment
        if value == 0 { return }
        r.advance(CGFloat(value))
        let layer = self.pool.arcs.next().layer
        layer.strokeColor = color.cgColor
        layer.strokeStart = r.first
        layer.strokeEnd = r.last
        if self.layer != layer.superlayer {
            self.layer.addSublayer(layer)
        }
    }

    func drawStrikes() {
        guard let (color, _) = self.strike else { return }
        let layer = self.pool.strikes.next().layer
        layer.strokeColor = color.cgColor
        layer.strokeStart = 0
        layer.strokeEnd = 1
        if self.layer != layer.superlayer {
            self.layer.addSublayer(layer)
        }
    }

    func setConstraints() {
        guard let sv = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.centerXAnchor.constraint(equalTo: sv.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: sv.centerYAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        [
            self.widthAnchor.constraint(equalTo: sv.widthAnchor),
            self.heightAnchor.constraint(equalTo: sv.heightAnchor),
        ].forEach { $0.priority = .defaultHigh; $0.isActive = true }
    }

    func getSettingForStrike() -> PrivacyIndicator.Strike.Shape {
        let width = self.frame.width
        let maxX = self.bounds.maxX
        let maxY = self.bounds.maxY
        let radius = width * 3 / 8
        let diagonal = sqrt(2 * width * width)
        let distance = (diagonal / 2) - radius
        let vDistance = sqrt((distance * distance) / 2)

        return PrivacyIndicator.Strike.Shape(
            start: CGPoint(x: vDistance, y: vDistance),
            end: CGPoint(x: maxX - vDistance, y: maxY - vDistance),
            lineWidth: width * 1 / 8)
    }

    func getSettingForCircle() -> PrivacyIndicator.Circle.Shape {
        return PrivacyIndicator.Circle.Shape(
            center: CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2),
            radius: self.frame.width * 3 / 8,
            lineWidth: self.frame.width / 8)
    }
}
