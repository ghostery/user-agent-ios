//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared

class PrivacyDashboardView: UIView {
    // MARK: - Properties
    var blocker: FirefoxTabContentBlocker? {
        didSet {
            guard let blocker = blocker else { return }
            domainURL = blocker.tab?.currentURL()
            privacyIndicator.blocker = blocker
            updateLegend()
        }
    }

    private var domainURL: URL?

    private var cachedLabelsForStats: [WTMCategory: UILabel] = [:]
    private var cachedNumberLabelsForStats: [WTMCategory: UILabel] = [:]
    private var cachedStackViewsForStats: [WTMCategory: UIStackView] = [:]

    private lazy var stackViewForNoTrackersSeen: UIStackView = {
        let dotView = circleView(withColor: UIColor(named: "NoTrackersSeen")!)
        let label = statLabel(labelled: Strings.PrivacyDashboard.Legend.NoTrackersSeen)

        let stackView = UIStackView(arrangedSubviews: [dotView, label])
        stackView.spacing = 5
        stackView.alignment = .top
        stackView.isHidden = true
        return stackView
    }()

    private lazy var stackViewForWhiteListed: UIStackView = {
        let dotView = circleView(withColor: UIColor(named: "PrivacyIndicatorBackground")!)
        let label = statLabel(labelled: Strings.PrivacyDashboard.Legend.Whitelisted)

        let stackView = UIStackView(arrangedSubviews: [dotView, label])
        stackView.spacing = 5
        stackView.alignment = .top
        stackView.isHidden = true
        return stackView
    }()

    private let allTrackersSeenOnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 3
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private let domainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.DarkGreen
        return label
    }()

    private let numberOfTrackersLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        let pointSize = UIFont.preferredFont(forTextStyle: .largeTitle).pointSize
        label.font = UIFont.monospacedDigitSystemFont(ofSize: pointSize, weight: .medium)
        return label
    }()

    private let privacyIndicator = PrivacyIndicatorView()

    private let pageStatsListStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .top
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - API
    private func updateLegend() {
        guard let pageStats = blocker?.stats else { return }

        DispatchQueue.main.async {
            self.updateTitlelabel()

            self.domainLabel.text = self.domainURL?.baseDomain
            self.numberOfTrackersLabel.text = "\(pageStats.total)"
            self.numberOfTrackersLabel.isHidden = self.blocker?.status == .Disabled || self.blocker?.status == .Whitelisted

            self.stackViewForNoTrackersSeen.isHidden = self.blocker?.status == .NoBlockedURLs ? false : true
            self.stackViewForWhiteListed.isHidden = self.blocker?.status == .Whitelisted ? false : true

            self.privacyIndicator.update(with: pageStats)

            let statsDict = WTMCategory.statsDict(from: pageStats)

            for statType in WTMCategory.all() {
                let value = statsDict[statType, default: 0]
                self.cachedNumberLabelsForStats[statType]?.text = "\(value)"
                self.cachedStackViewsForStats[statType]?.isHidden = value <= 0
                self.cachedStackViewsForStats[statType]?.alpha = value <= 0 ? 0 : 1
            }
        }
    }

    private func updateTitlelabel() {
        guard let blocker = self.blocker else { return }

        switch blocker.status {
        case .Disabled: break
        case .NoBlockedURLs:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.NoTrackersSeen
        case .AdBlockWhitelisted:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.AdBlockWhitelisted
        case .AntiTrackingWhitelisted:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.AntiTrackingWhitelisted
        case .Whitelisted:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.Whitelisted
        case .Blocking:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.BlockingEnabled
        }
    }
}

private extension PrivacyDashboardView {
    private func setup() {
        snp.makeConstraints { make in
            // This fixes a bug where the tableview would squash elements inside PrivacyDashboardView
            make.height.greaterThanOrEqualTo(UIScreen.main.bounds.height * 0.3)
        }

        backgroundColor = UIColor.clear

        let titleStackView = UIStackView(arrangedSubviews: [allTrackersSeenOnLabel, domainLabel])
        titleStackView.axis = .vertical

        let mainStackView = UIStackView(arrangedSubviews: [privacyIndicator, pageStatsListStackView])
        mainStackView.spacing = 10
        mainStackView.alignment = .top
        mainStackView.distribution = .fillProportionally

        [titleStackView, mainStackView, numberOfTrackersLabel].forEach { addSubview($0) }

        for statType in WTMCategory.all() {
            let dotView = circleView(withColor: statType.color)
            let label = statLabel(labelled: statType.localizedName)

            let numberLabel = statLabel(labelled: "")
            numberLabel.alpha = 0.7

            let stackView = UIStackView(arrangedSubviews: [dotView, label, numberLabel])
            stackView.spacing = 5
            stackView.alignment = .top
            stackView.isHidden = true

            cachedLabelsForStats[statType] = label
            cachedStackViewsForStats[statType] = stackView
            cachedNumberLabelsForStats[statType] = numberLabel

            pageStatsListStackView.addArrangedSubview(stackView)
        }

        pageStatsListStackView.addArrangedSubview(stackViewForNoTrackersSeen)
        pageStatsListStackView.addArrangedSubview(stackViewForWhiteListed)

        titleStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        mainStackView.snp.makeConstraints { make in
            make.top.equalTo(titleStackView.snp.bottom).offset(16)
            make.leading.trailing.bottom.equalToSuperview()
        }

        privacyIndicator.snp.makeConstraints { make in
            make.width.equalTo(mainStackView).dividedBy(2.2)
        }

        numberOfTrackersLabel.snp.makeConstraints { make in
            make.center.equalTo(privacyIndicator)
        }
    }

    func circleView(withColor: UIColor) -> UIView {
        let radius = 5
        let topMargin = 4

        let containerView = UIView()
        containerView.snp.makeConstraints { make in
            make.width.equalTo(radius * 2)
            make.height.equalTo((radius * 2) + (topMargin * 2))
        }

        let circleView = UIView()
        containerView.addSubview(circleView)
        circleView.snp.makeConstraints { make in
            make.width.equalTo(circleView.snp.height)
            make.height.equalTo(radius * 2)
            make.center.equalTo(containerView)
        }

        circleView.backgroundColor = withColor
        circleView.layer.cornerRadius = CGFloat(radius)

        return containerView
    }

    func statLabel(labelled text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.theme.textField.textAndTint
        label.text = text
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }

    func spacerView() -> UIView {
        let margin = 5

        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(margin)
            make.height.equalTo(margin)
        }

        return view
    }
}
