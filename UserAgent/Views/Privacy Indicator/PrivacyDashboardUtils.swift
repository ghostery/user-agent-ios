import Shared

enum PrivacyDashboardUtils {
    static func stackViewForStatEmpty(
        _ color: UIColor,
        _ text: String
    ) -> UIStackView {
        let dot = dotView(color)
        let label = statLabel(text)

        let stackView = UIStackView(arrangedSubviews: [dot, label])
        stackView.spacing = 5
        stackView.alignment = .top
        return stackView
    }

    static func stackViewForStat(
        _ color: UIColor,
        _ text: String,
        _ value: String
    ) -> UIStackView {
        let dot = dotView(color)
        let label = statLabel(text)
        let number = statLabel(value)
        number.alpha = 0.7
        number.textAlignment = .right

        let stackView = UIStackView(arrangedSubviews: [dot, label, number])
        stackView.spacing = 5
        stackView.alignment = .top
        stackView.distribution = .fillProportionally

        label.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(100)
        }
        number.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(25)
            make.width.greaterThanOrEqualTo(18)
        }
        return stackView
    }

    static func dotView(_ color: UIColor) -> UIView {
        let wrapper = self.dotWrapperView()
        self.dotMainView(wrapper, color)
        return wrapper
    }

    static func dotWrapperView() -> UIView {
        let radius = 5
        let margin = 4
        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(radius * 2)
            make.height.equalTo((radius * 2) + (margin * 2))
        }
        return view
    }

    static func dotMainView(
        _ wrapper: UIView,
        _ color: UIColor
    ) {
        let radius = 5
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = CGFloat(radius)
        wrapper.addSubview(view)

        view.snp.makeConstraints { make in
            make.width.equalTo(view.snp.height)
            make.height.equalTo(radius * 2)
            make.center.equalTo(wrapper)
        }
    }

    static func statLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.textColor = Theme.textField.textAndTint
        label.text = text
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }

    static func titleLabel(withStatus status: BlockerStatus?) -> UILabel {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        label.text = self.headerText(status)
        return label
    }

    static func domainLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.DarkGreen
        label.text = text
        return label
    }

    static func counterLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        let pointSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        label.font = UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: .medium)
        return label
    }

    static func spacerView() -> UIView {
        let margin = 5
        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(margin)
            make.height.equalTo(margin)
        }
        return view
    }

    static func headerText(_ status: BlockerStatus?) -> String {
        if status == nil { return "" }
        switch status {
        case .Disabled: return ""
        case .NoBlockedURLs:
             return Strings.PrivacyDashboard.Title.NoTrackersSeen
        case .AdBlockWhitelisted:
             return Strings.PrivacyDashboard.Title.AdBlockWhitelisted
        case .AntiTrackingWhitelisted:
            return Strings.PrivacyDashboard.Title.AntiTrackingWhitelisted
        case .Whitelisted:
            return Strings.PrivacyDashboard.Title.Whitelisted
        case .Blocking:
            return Strings.PrivacyDashboard.Title.BlockingEnabled
        default: return ""
        }
    }
}
