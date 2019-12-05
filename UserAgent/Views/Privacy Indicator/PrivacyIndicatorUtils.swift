import Foundation

enum PrivacyIndicatorUtils { // utils

  static func createStrike(
      _ width: CGFloat,
      _ maxX: CGFloat,
      _ maxY: CGFloat
  ) -> CAShapeLayer {
      let radius = width * 3 / 8
      let diagonal = sqrt(2 * width * width + width * width)
      let distance = (diagonal / 2) - radius
      let vDistance = sqrt((distance * distance) / 2)

      let path = UIBezierPath()
      path.move(to: CGPoint(x: vDistance, y: vDistance))
      path.addLine(to: CGPoint(x: maxX - vDistance, y: maxY - vDistance))

      let layer = CAShapeLayer()
      layer.path = path.cgPath
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
      let path = UIBezierPath(
          arcCenter: center,
          radius: width * 3 / 8,
          startAngle: percentToRadian(0),
          endAngle: percentToRadian(0.9999),
          clockwise: true
      )
      return _createCircle(path, width, color)
  }

  static func _createCircle(
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

  struct CircleIterator {
      let n: CGFloat
      var current: CGFloat = 0
      var next: CGFloat = 0

    mutating func advance(_ value: CGFloat) {
        current = next
        next = next + value / n
    }
  }

}
