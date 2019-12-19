import Foundation

protocol PrivacyIndicatorUtilsPath {
    init()
    func move(to: CGPoint)
    func addLine(to: CGPoint)
    var cgPath: CGPath { get }
}

extension UIBezierPath: PrivacyIndicatorUtilsPath { }

enum PrivacyIndicatorUtils {

    static func createStrike(
        _ width: CGFloat,
        _ maxX: CGFloat,
        _ maxY: CGFloat
    ) -> CAShapeLayer {
        let path: UIBezierPath = self.createStrikePath(width, maxX, maxY)
        return self.createStrikeLayer(path.cgPath, width)
    }

    static func createStrikePath<T: PrivacyIndicatorUtilsPath>(
        _ width: CGFloat,
        _ maxX: CGFloat,
        _ maxY: CGFloat,
        _ path: T = T()
    ) -> T {
        let radius = width * 3 / 8
        let diagonal = sqrt(3 * width * width)
        let distance = (diagonal / 2) - radius
        let vDistance = sqrt((distance * distance) / 2)

        path.move(to: CGPoint(x: vDistance, y: vDistance))
        path.addLine(to: CGPoint(x: maxX - vDistance, y: maxY - vDistance))
        return path
    }

    static func createStrikeLayer(
        _ path: CGPath,
        _ width: CGFloat
    ) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path
        layer.fillColor = nil
        layer.strokeColor = UIColor(named: "PrivacyIndicatorBackground")!.cgColor
        layer.lineWidth = width * 1 / 8
        return layer
    }

    static func createCircle(
        _ center: CGPoint,
        _ width: CGFloat,
        _ color: CGColor
    ) -> CAShapeLayer {
        let path = self.createCirclePath(center, width)
        return self.createCircleLayer(path, width, color)
    }

    static func createCirclePath(
        _ center: CGPoint,
        _ width: CGFloat
    ) -> UIBezierPath {
        return UIBezierPath(
            arcCenter: center,
            radius: width * 3 / 8,
            startAngle: percentToRadian(0),
            endAngle: percentToRadian(0.9999),
            clockwise: true
        )
    }

    static func createCircleLayer(
        _ path: UIBezierPath,
        _ width: CGFloat,
        _ color: CGColor
    ) -> CAShapeLayer {
        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.fillColor = nil
        layer.strokeColor = color
        layer.lineWidth = width * 1 / 8
        layer.strokeStart = 0
        layer.strokeEnd = 1
        return layer
    }

    // percent [0.0, 1)
    static func percentToRadian(_ percent: CGFloat) -> CGFloat {
        // Because angle starts wtih X positive axis,
        // add 270 degrees to rotate it to Y positive axis.
        let angle = (270 + percent * 360).truncatingRemainder(dividingBy: 360)
        return angle * CGFloat.pi / 180.0
    }

    struct CircleRange {
        let count: CGFloat
        var first: CGFloat = 0
        var last: CGFloat = 0

        mutating func advance(_ value: CGFloat) {
            first = last
            last = last + value / count
        }
    }
}
