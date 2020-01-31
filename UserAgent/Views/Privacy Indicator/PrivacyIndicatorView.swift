import Foundation
import Widgets

enum PrivacyIndicatorTransformation {
    static func transform(
        status: BlockerStatus,
        stats: TPPageStats
    ) -> (arcs: [PrivacyIndicator.Segment], strike: PrivacyIndicator.Segment?) {
        if status == .NoBlockedURLs {
            let color = UIColor(named: "NoTrackersSeen")!
            return (arcs: [(color, 1)], strike: nil)
        }
        if [.Disabled, .Whitelisted].contains(status) {
            let color = UIColor(named: "PrivacyIndicatorBackground")!
            return (arcs: [(color, 1)], strike: (color, 1))
        }
        let arcs: [(UIColor, Int)] = WTMCategory.statsDict(from: stats)
            .map { (key, value) in (key.color, value) }
            .filter { $0.1 != 0 }
            .sorted(by: { $1.1 < $0.1 })
        print("XXXX privacyIndicator update", arcs)
        return (arcs: arcs, strike: nil)
    }
}

class PrivacyIndicatorView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        render()
    }

    override var bounds: CGRect {
        didSet {
            DispatchQueue.main.async { [weak self] () in
              if self == nil { return }
              self!.canvasView.relayout(status: self!.status)
            }
        }
    }

    public var onTapBlock: (() -> Void)? {
        didSet {
            button.isHidden = onTapBlock == nil
        }
    }

    public var blocker: FirefoxTabContentBlocker? {
        didSet {
            status = blocker?.status ?? .Disabled
            update(with: blocker?.stats ?? TPPageStats())
        }
    }

    private var status: BlockerStatus = .Disabled
    private lazy var canvasView = PrivacyIndicatorCanvasView()
    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(didPressButton(_:)), for: .touchUpInside)
        button.isHidden = onTapBlock == nil
        return button
    }()

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if clipsToBounds || isHidden || alpha == 0 { return nil }
        for subview in subviews.reversed() {
            let view = self._hitTest(subview, point, event)
            if view != nil { return view }
        }
        return nil
    }

    private func _hitTest(_ view: UIView, _ point: CGPoint, _ ev: UIEvent?) -> UIView? {
        let newPoint = view.convert(point, from: self)
        return view.hitTest(newPoint, with: ev)
    }
}

extension PrivacyIndicatorView {
    func update(with stats: TPPageStats) {
      canvasView.render(with: stats, status: status)
    }
}

// MARK: - Private API
fileprivate extension PrivacyIndicatorView {
    @objc
    func didPressButton(_ button: UIButton) {
        onTapBlock?()
    }

    func render() {
        addSubview(canvasView)
        addSubview(button)

        canvasView.translatesAutoresizingMaskIntoConstraints = false
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

        self.clipsToBounds = false // default should be false
        button.snp.makeConstraints { make in
            // make the button BIGGER than ourselves to have a large tap target
            make.top.bottom.equalTo(self)
            make.leading.equalTo(self).offset(-10)
            make.trailing.equalTo(self).offset(10)
        }
    }
}
