import UIKit

public enum PrivacyIndicator {
    public class Widget: UIView {
        public var onTapBlock: (() -> Void)? {
            didSet {
                self.button.isHidden = onTapBlock == nil
            }
        }
        private var canvas = PrivacyIndicator.CanvasView()
        private var button = PrivacyIndicator.ButtonView()
        override public func didMoveToSuperview() {
            super.didMoveToSuperview()
            self.clipsToBounds = false
            self.addSubview(self.canvas)
            self.addSubview(self.button) // should be added last, see hitTest
            self.button.addTarget(
                self,
                action: #selector(self.didPressButton(_:)),
                for: .touchUpInside)
        }
        override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if clipsToBounds || isHidden || alpha == 0 { return nil }
            for subview in subviews.reversed() {
                let newPoint = subview.convert(point, from: self)
                let view = subview.hitTest(newPoint, with: event)
                if view != nil { return view }
            }
            return nil
        }
    }
}

public extension PrivacyIndicator {
    typealias Segment = (UIColor, Int)
}

public extension PrivacyIndicator.Widget {
    func update(
        arcs: [PrivacyIndicator.Segment],
        strike: PrivacyIndicator.Segment?
    ) {
        self.canvas.update(arcs: arcs, strike: strike)
    }
}

fileprivate extension PrivacyIndicator.Widget {
    @objc
    func didPressButton(_ button: UIButton) {
        self.onTapBlock?()
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SwiftLeeViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return PrivacyIndicator.Widget()
    }
    func updateUIView(_ view: UIView, context: Context) {
        let v = (view as! PrivacyIndicator.Widget)
        let arcs = [(UIColor.green, 4), (UIColor.black, 3)]
        let strike = (UIColor.blue, 1)
        v.update(arcs: arcs, strike: strike)
    }
}
@available(iOS 13.0, *)
struct SwiftLeeViewController_Preview: PreviewProvider {
    static var previews: some View {
        SwiftLeeViewRepresentable()
    }
}
#endif
