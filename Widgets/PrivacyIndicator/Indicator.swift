//import Foundation
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
        print("XXXX Widget didMoveToSuperview")
        self.clipsToBounds = false
        self.addSubview(self.canvas)
        // button should be added last, see hitTest
        self.addSubview(self.button)
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
    deinit {
        print("XXXX deinit Indicator")
    }
}
}

public extension PrivacyIndicator.Widget {
    func update(
        arcs: [PrivacyIndicator.Segment],
        strike: PrivacyIndicator.Segment?
    ) {
        self.canvas.render(arcs: arcs, strike: strike)
    }
}

fileprivate extension PrivacyIndicator.Widget {
    @objc
    func didPressButton(_ button: UIButton) {
        print("XXXX Indicator didPressButton")
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
        v.update(arcs: [(UIColor.green, 1)], strike: nil)
    }
}
@available(iOS 13.0, *)
struct SwiftLeeViewController_Preview: PreviewProvider {
    static var previews: some View {
        SwiftLeeViewRepresentable()
    }
}
#endif
