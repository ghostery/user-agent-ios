//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class BubbleView: UIView {

    override func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height

        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 22, y: height))
        bezierPath.addLine(to: CGPoint(x: width - 17, y: height))
        bezierPath.addCurve(to: CGPoint(x: width, y: height - 17), controlPoint1: CGPoint(x: width - 7.61, y: height), controlPoint2: CGPoint(x: width, y: height - 7.61))
        bezierPath.addLine(to: CGPoint(x: width, y: 17))
        bezierPath.addCurve(to: CGPoint(x: width - 17, y: 0), controlPoint1: CGPoint(x: width, y: 7.61), controlPoint2: CGPoint(x: width - 7.61, y: 0))
        bezierPath.addLine(to: CGPoint(x: 21, y: 0))
        bezierPath.addCurve(to: CGPoint(x: 4, y: 17), controlPoint1: CGPoint(x: 11.61, y: 0), controlPoint2: CGPoint(x: 4, y: 7.61))
        bezierPath.addLine(to: CGPoint(x: 4, y: height - 11))
        bezierPath.addCurve(to: CGPoint(x: 0, y: height), controlPoint1: CGPoint(x: 4, y: height - 1), controlPoint2: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: -0.05, y: height - 0.01))
        bezierPath.addCurve(to: CGPoint(x: 11.04, y: height - 4.04), controlPoint1: CGPoint(x: 4.07, y: height + 0.43), controlPoint2: CGPoint(x: 8.16, y: height - 1.06))
        bezierPath.addCurve(to: CGPoint(x: 22, y: height), controlPoint1: CGPoint(x: 16, y: height), controlPoint2: CGPoint(x: 19, y: height))

        UIColor.gray.setFill()
        bezierPath.close()
        bezierPath.fill()
    }
}

class ChatBubbleView: UIView {
    private var label: UILabel!
    private var bubbleView: BubbleView!

    private let labelFont = UIFont.systemFont(ofSize: 14)

    init(text: String) {
        super.init(frame: .zero)
        self.setupLabel(text)
        self.setupBubbleView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")

    }

    func calculatedSize(width: CGFloat) -> CGSize {
        guard let text = self.label.text else {
            return .zero
        }

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: .usesLineFragmentOrigin,
                                            attributes: [.font: self.labelFont],
                                            context: nil)
        return boundingBox.size
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let boundingSize = self.calculatedSize(width: self.frame.width)

        self.label.frame.size = CGSize(width: ceil(boundingSize.width),
                                  height: ceil(boundingSize.height))

        let bubbleSize = CGSize(width: label.frame.width + 28, height: label.frame.height + 20)
        self.bubbleView.frame.size = bubbleSize

        self.bubbleView.frame.origin = .zero
        self.label.frame.origin = CGPoint(x: 10, y: 10)
    }

    private func setupBubbleView() {
        self.bubbleView = BubbleView()
        self.bubbleView.backgroundColor = .clear
        self.addSubview(self.bubbleView)
        self.bringSubviewToFront(self.label)
    }

    private func setupLabel(_ text: String) {
        self.label = UILabel()
        self.label.text = text
        self.label.numberOfLines = 0
        label.font = self.labelFont
        label.textColor = .white // TODO: set proper color
        self.addSubview(self.label)
    }
}
