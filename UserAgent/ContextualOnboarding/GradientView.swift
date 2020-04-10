//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class GradientView: UIView {

    enum GradientDrawOptions: Int {
        case centerTopCenterBottom = 0
        case centerLeftCenterRight
        case topLeftBottomRight
        case topRightBottomLeft
    }

    enum GradientDrawStyle: Int {
        case linear = 0
        case radial
    }

    var drawOptions: GradientDrawOptions = .centerLeftCenterRight {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var drawStyle: GradientDrawStyle = .linear {
        didSet {
            self.setNeedsDisplay()
        }
    }

    var colors: [UIColor] = [] {
        didSet {
            self.setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        self.drawGradient(context: context, rect: rect)
    }

    private func drawGradient(context: CGContext, rect: CGRect) {
        let colors = self.cgColor()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colorLocations = self.gradientColorLocations()
        let cfArrayColors = (colors as CFArray)
        let gradient = CGGradient(colorsSpace: colorSpace, colors: cfArrayColors, locations: colorLocations)
        if let gradient = gradient {
            let points = self.getDrawOptionsLocations(in: rect)
            if self.drawStyle == .linear {
                context.drawLinearGradient(gradient, start: points.startPoint, end: points.endPoint, options: [.drawsBeforeStartLocation])
            } else {
                let radius = max(rect.width, rect.height) / 2
                context.drawRadialGradient(gradient, startCenter: points.startPoint, startRadius: 0, endCenter: points.endPoint, endRadius: radius, options: [.drawsAfterEndLocation])
            }
        }
    }

    private func gradientColorLocations() -> [CGFloat] {
        let distance: CGFloat = 1.0/CGFloat(colors.count)
        var result: [CGFloat] = [CGFloat]()
        for index in 0..<colors.count {
            var value = (0.5 - distance * CGFloat(colors.count - 1 - index)) * CGFloat(colors.count)
            value = value > 1 ? 1 : value
            value = value < 0 ? 0 : value
            result.append(value)
        }
        return result
    }

    private func getDrawOptionsLocations(in frame: CGRect) -> (startPoint: CGPoint, endPoint: CGPoint) {
        guard self.drawStyle == .linear else {
            let point: CGPoint = CGPoint(x: frame.width/2, y: frame.height/2)
            return (point, point)
        }
        switch self.drawOptions {
        case .centerTopCenterBottom:
            let point1: CGPoint = CGPoint(x: frame.width/2, y: 0)
            let point2: CGPoint = CGPoint(x: frame.width/2, y: frame.height)
            return (point1, point2)
        case .centerLeftCenterRight:
            let point1: CGPoint = CGPoint(x: 0, y: frame.height/2)
            let point2: CGPoint = CGPoint(x: frame.width, y: frame.height/2)
            return (point1, point2)
        case .topLeftBottomRight:
            let point1: CGPoint = CGPoint(x: 0, y: 0)
            let point2: CGPoint = CGPoint(x: frame.width, y: frame.height)
            return (point1, point2)
        case .topRightBottomLeft:
            let point1: CGPoint = CGPoint(x: frame.width, y: 0)
            let point2: CGPoint = CGPoint(x: 0, y: frame.height)
            return (point1, point2)
        }
    }

    private func cgColor() -> [CGColor] {
        var cgColorArray: [CGColor] = []
        for color in self.colors {
            cgColorArray.append(color.cgColor)
        }
        return cgColorArray
    }

}
