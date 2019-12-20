import UIKit
import Shared

class PrivacyDashboardView: UIView {
    var blocker: FirefoxTabContentBlocker? {
        didSet {
            guard let blocker = blocker else { return }
            self.privacyIndicator.blocker = blocker
            DispatchQueue.main.async { [weak self] in
                self?.subviews.forEach { $0.removeFromSuperview() } // todo ask about it
                self?.render(blocker.stats, blocker.tab?.currentURL())
            }
        }
    }
    private let privacyIndicator = PrivacyIndicatorView()
}

private extension PrivacyDashboardView {

    func renderHeader(_ status: BlockerStatus, _ url: URL?) -> UIView {
        let view = UIStackView(arrangedSubviews: [
            PrivacyDashboardUtils.titleLabel(withStatus: status),
            PrivacyDashboardUtils.domainLabel(url?.baseDomain ?? ""),
        ])
        view.axis = .vertical
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        return view
    }

    func renderMain(_ wrapper: UIView, _ header: UIView) {
        let subviews = [self.privacyIndicator, wrapper]
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

    func renderWrapper() -> UIStackView {
        let view = UIStackView()
        view.alignment = .top
        view.axis = .vertical
        view.spacing = 5
        return view
    }

    func renderStats(_ wrapper: UIStackView, _ stats: TPPageStats) {
        let statsDict = WTMCategory.statsDict(from: stats)
        WTMCategory.all()
            .filter { statsDict[$0, default: 0] != 0 }
            .forEach { self.renderStat(wrapper, $0, statsDict) }
    }

    func renderStat(
        _ wrapper: UIStackView,
        _ category: WTMCategory,
        _ statsDict: [WTMCategory: Int]
    ) {
        let value = statsDict[category, default: 0]
        let color = category.color
        let name = category.localizedName
        let view = PrivacyDashboardUtils.stackViewForStat(color, name, String(value))
        wrapper.addArrangedSubview(view)
    }

    func renderCounter(_ stats: TPPageStats) {
        let view = PrivacyDashboardUtils.counterLabel(String(stats.total))
        self.addSubview(view)

        view.snp.makeConstraints { make in
            make.center.equalTo(self.privacyIndicator)
        }
    }

    func render(
        _ stats: TPPageStats,
        _ url: URL?
    ) {
        guard let blocker = self.blocker else { return }
        self.snp.makeConstraints { make in
            // This fixes a bug
            // where the tableview would squash elements inside PrivacyDashboardView
            make.height.greaterThanOrEqualTo(UIScreen.main.bounds.height * 0.3)
        }
        self.backgroundColor = UIColor.clear

        let header = self.renderHeader(blocker.status, url)
        let wrapper = self.renderWrapper()
        self.renderMain(wrapper, header)

        if blocker.status == .NoBlockedURLs {
            let noTrackersSeen = PrivacyDashboardUtils.stackViewForStatEmpty(
                UIColor(named: "NoTrackersSeen")!,
                Strings.PrivacyDashboard.Legend.NoTrackersSeen
            )
            wrapper.addArrangedSubview(noTrackersSeen)
            return
        }

        if [.Disabled, .Whitelisted].contains(blocker.status) {
            let whiteListed = PrivacyDashboardUtils.stackViewForStatEmpty(
                UIColor(named: "PrivacyIndicatorBackground")!,
                Strings.PrivacyDashboard.Legend.Whitelisted
            )
            wrapper.addArrangedSubview(whiteListed)
            return
        }

        self.renderCounter(stats)
        self.renderStats(wrapper, stats)
    }
}
