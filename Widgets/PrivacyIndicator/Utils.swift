import UIKit

extension PrivacyIndicator {
    enum utils {

        static func createStrike(
            start: CGPoint,
            end: CGPoint,
            lineWidth: CGFloat
        ) -> CAShapeLayer {
            let path = UIBezierPath()
            path.move(to: start)
            path.addLine(to: end)
            return self.createStrikeLayer(path: path.cgPath, lineWidth: lineWidth)
        }

        static func createStrikeLayer(path: CGPath, lineWidth: CGFloat) -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.path = path
            layer.fillColor = nil
            layer.lineWidth = lineWidth
            return layer
        }

        static func createCircle(
            center: CGPoint,
            radius: CGFloat,
            lineWidth: CGFloat
        ) -> CAShapeLayer {
            let path = self.createCirclePath(center: center, radius: radius)
            return self.createCircleLayer(path: path, lineWidth: lineWidth)
        }

        static func createCirclePath(
            center: CGPoint,
            radius: CGFloat
        ) -> UIBezierPath {
            return UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: percentToRadian(0),
                endAngle: percentToRadian(0.9999),
                clockwise: true
            )
        }

        static func createCircleLayer(
            path: UIBezierPath,
            lineWidth: CGFloat
        ) -> CAShapeLayer {
            let layer = CAShapeLayer()
            layer.path = path.cgPath
            layer.fillColor = nil
            layer.lineWidth = lineWidth
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
}
