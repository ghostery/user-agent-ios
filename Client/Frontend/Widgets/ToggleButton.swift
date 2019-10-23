/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit

private struct UX {
    static let BackgroundColor = UIColor.Grey90

    // The amount of pixels the toggle button will expand over the normal size. This results in the larger -> contract animation.
    static let ExpandDelta: CGFloat = 5
    static let ShowDuration: TimeInterval = 0.1
    static let HideDuration: TimeInterval = 0.1

    static let BackgroundSizeHeight: CGFloat = 32.0
}

class ToggleButton: UIButton {
    func setSelected(_ selected: Bool, animated: Bool = true) {
        self.isSelected = selected
        if animated {
            animateSelection(selected)
        }
    }

    fileprivate func updateMaskPathForSelectedState(_ selected: Bool) {
        let path = CGMutablePath()
        if selected {
            var rect = CGRect(size: CGSize(width: self.frame.size.width + UX.ExpandDelta, height: UX.BackgroundSizeHeight))
            rect.center = maskShapeLayer.position
            path.addRoundedRect(in: rect, cornerWidth: 5, cornerHeight: 5)
        } else {
            path.addRoundedRect(in: CGRect(origin: maskShapeLayer.position, size: CGSize(width: 1, height: 1)), cornerWidth: 0, cornerHeight: 0)
        }
        self.maskShapeLayer.path = path
    }

    fileprivate func animateSelection(_ selected: Bool) {
        var endFrame = CGRect(size: CGSize(width: self.frame.size.width + UX.ExpandDelta, height: UX.BackgroundSizeHeight))
        endFrame.center = maskShapeLayer.position

        if selected {
            let animation = CAKeyframeAnimation(keyPath: "path")

            let startPath = CGMutablePath()
            startPath.addRoundedRect(in: CGRect(origin: maskShapeLayer.position, size: CGSize(width: 1, height: 1)), cornerWidth: 0, cornerHeight: 0)

            let endPath = CGMutablePath()
            endPath.addRoundedRect(in: endFrame, cornerWidth: UX.ExpandDelta, cornerHeight: UX.ExpandDelta)

            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            animation.values = [
                startPath,
                endPath,
            ]
            animation.duration = UX.ShowDuration
            self.maskShapeLayer.path = endPath
            self.maskShapeLayer.add(animation, forKey: "grow")
        } else {
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = UX.HideDuration
            animation.fillMode = CAMediaTimingFillMode.forwards

            let fromPath = CGMutablePath()
            fromPath.addRoundedRect(in: endFrame, cornerWidth: UX.ExpandDelta, cornerHeight: UX.ExpandDelta)
            animation.fromValue = fromPath
            animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

            let toPath = CGMutablePath()
            toPath.addRoundedRect(in: CGRect(origin: self.maskShapeLayer.bounds.center, size: CGSize(width: 1, height: 1)), cornerWidth: 0, cornerHeight: 0)

            self.maskShapeLayer.path = toPath
            self.maskShapeLayer.add(animation, forKey: "shrink")
        }
    }

    lazy fileprivate var backgroundView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.layer.addSublayer(self.backgroundLayer)
        return view
    }()

    lazy fileprivate var maskShapeLayer: CAShapeLayer = {
        let circle = CAShapeLayer()
        return circle
    }()

    lazy fileprivate var backgroundLayer: CALayer = {
        let backgroundLayer = CALayer()
        backgroundLayer.backgroundColor = UX.BackgroundColor.cgColor
        backgroundLayer.mask = self.maskShapeLayer
        return backgroundLayer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentMode = .redraw
        insertSubview(backgroundView, belowSubview: imageView!)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let zeroFrame = CGRect(size: frame.size)
        backgroundView.frame = zeroFrame

        // Make the gradient larger than normal to allow the mask transition to show when it blows up
        // a little larger than the resting size
        backgroundLayer.bounds = backgroundView.frame.insetBy(dx: -UX.ExpandDelta, dy: -UX.ExpandDelta)
        maskShapeLayer.bounds = backgroundView.frame
        backgroundLayer.position = CGPoint(x: zeroFrame.midX, y: zeroFrame.midY)
        maskShapeLayer.position = CGPoint(x: zeroFrame.midX, y: zeroFrame.midY)

        updateMaskPathForSelectedState(isSelected)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
