import UIKit
import Shared
import Widgets

class PrivacyDashboardView: UIView, PhotonCustomViewCellContent {
    var onSizeChange: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.register(self, forTabEvents: .didChangeContentBlocking)
        self.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(0)
        }
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.onSizeChange?()
    }

    var blocker: FirefoxTabContentBlocker? {
        didSet {
            guard let blocker = blocker else { return }
            self.subviews.forEach { $0.removeFromSuperview() }
            self.render(
                status: blocker.status,
                stats: blocker.stats,
                domain: blocker.tab?.currentURL()?.baseDomain ?? ""
            )
            let (arcs, strike) = PrivacyIndicatorTransformation
                .transform(status: blocker.status, stats: blocker.stats)
            self.privacyIndicator.update(arcs: arcs, strike: strike)
        }
    }
    private let privacyIndicator = PrivacyIndicator.Widget()
}

private extension PrivacyDashboardView {
    func renderHeader(withStatus status: BlockerStatus, domain: String) -> UIView {
        let view = UIStackView(arrangedSubviews: [
            PrivacyDashboardUtils.Label(
                withType: .title,
                PrivacyDashboardUtils.headerText(withStatus: status)
            ),
            PrivacyDashboardUtils.Label(withType: .domain, domain),
        ])
        view.axis = .vertical
        view.distribution = .equalSpacing
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        return view
    }

    func renderMain(header: UIView, content: UIView) {
        let subviews = [self.privacyIndicator, content]
        let view = UIStackView(arrangedSubviews: subviews)
        view.spacing = 10
        view.alignment = .top
        view.distribution = .fillProportionally
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }
        self.privacyIndicator.snp.makeConstraints { make in
            make.width.equalTo(view).dividedBy(2.2)
        }
    }

    func renderStatsWrapper() -> UIStackView {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 5

        return view
    }

    func renderStats(
        wrapper: UIStackView,
        stats: TPPageStats
    ) {
        let statsDict = WTMCategory.statsDict(from: stats)
        WTMCategory.all()
            .filter { statsDict[$0, default: 0] != 0 }
            .forEach { self.renderStat(wrapper: wrapper, category: $0, stats: statsDict) }
    }

    func renderStat(
        wrapper: UIStackView,
        category: WTMCategory,
        stats: [WTMCategory: Int]
    ) {
        let value = stats[category, default: 0]
        let color = category.color
        let name = category.localizedName
        let dot = PrivacyDashboardUtils.Dot(withColor: color)
        let label = PrivacyDashboardUtils.Label(withType: .stat, name)
        let number = PrivacyDashboardUtils.Label(withType: .stat, String(value))
        number.alpha = 0.7
        number.textAlignment = .right
        number.numberOfLines = 1
        let view = UIView()
        [dot, label, number].forEach({ view.addSubview($0) })
        dot.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
        }
        label.snp.makeConstraints { (make) in
            make.left.equalTo(dot.snp.right).offset(5)
            make.top.bottom.equalToSuperview()
        }
        number.snp.makeConstraints { (make) in
            make.left.greaterThanOrEqualTo(label.snp.right).offset(-5)
            make.top.right.equalToSuperview()
            // space for keeping three digits [18, 25]
            make.width.greaterThanOrEqualTo(18)
            make.width.lessThanOrEqualTo(25)
        }
        wrapper.addArrangedSubview(view)
    }

    func renderCounter(withStats stats: TPPageStats) {
        let view = PrivacyDashboardUtils.Label(withType: .counter, String(stats.total))
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.center.equalTo(self.privacyIndicator)
        }
    }

    func renderStatForNoBlockingUrl(withWrapper wrapper: UIStackView) {
        let view = PrivacyDashboardUtils.HStack { () -> (UIView, UILabel) in
            let name = Strings.PrivacyDashboard.Legend.NoTrackersSeen
            return (
                PrivacyDashboardUtils.Dot(withColor: UIColor(named: "NoTrackersSeen")!),
                PrivacyDashboardUtils.Label(withType: .stat, name)
            )
        }
        wrapper.addArrangedSubview(view)
    }

    func renderStatForAllowListed(withWrapper wrapper: UIStackView) {
        let view = PrivacyDashboardUtils.HStack { () -> (UIView, UILabel) in
            let name = Strings.PrivacyDashboard.Legend.AllowListed
            let color = UIColor(named: "PrivacyIndicatorBackground")!
            return (
                PrivacyDashboardUtils.Dot(withColor: color),
                PrivacyDashboardUtils.Label(withType: .stat, name)
            )
        }
        wrapper.addArrangedSubview(view)
    }

    func render(
        status: BlockerStatus,
        stats: TPPageStats,
        domain: String
    ) {
        let header = self.renderHeader(withStatus: status, domain: domain)
        let statsWrapper = self.renderStatsWrapper()
        self.renderMain(header: header, content: statsWrapper)
        if status == .NoBlockedURLs {
            return self.renderStatForNoBlockingUrl(withWrapper: statsWrapper)
        }
        if [.Disabled, .AllowListed].contains(status) {
            return self.renderStatForAllowListed(withWrapper: statsWrapper)
        }
        self.renderCounter(withStats: stats)
        self.renderStats(wrapper: statsWrapper, stats: stats)
    }
}

extension PrivacyDashboardView: TabEventHandler {

    func tabDidChangeContentBlocking(_ tab: Tab) {
        guard self.blocker?.tab === tab else {
            return
        }
        guard let blocker = self.blocker else { return }
        self.subviews.forEach { $0.removeFromSuperview() }
        self.render(
            status: blocker.status,
            stats: blocker.stats,
            domain: blocker.tab?.currentURL()?.baseDomain ?? ""
        )
        let (arcs, strike) = PrivacyIndicatorTransformation
            .transform(status: blocker.status, stats: blocker.stats)
        self.privacyIndicator.update(arcs: arcs, strike: strike)
    }

}
