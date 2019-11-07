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

    private lazy var stackViewForTrackingDisabled: UIStackView = {
        let dotView = circleView(withColor: UIColor(named: "PrivacyIndicatorBackground")!)
        let label = statLabel(labelled: Strings.PrivacyDashboard.Legend.TrackingDisabled)

        let stackView = UIStackView(arrangedSubviews: [dotView, label])
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isHidden = true
        return stackView
    }()

    private lazy var stackViewForNoTrackersSeen: UIStackView = {
        let dotView = circleView(withColor: UIColor(named: "NoTrackersSeen")!)
        let label = statLabel(labelled: Strings.PrivacyDashboard.Legend.NoTrackersSeen)

        let stackView = UIStackView(arrangedSubviews: [dotView, label])
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isHidden = true
        return stackView
    }()

    private lazy var stackViewForWhiteListed: UIStackView = {
        let dotView = circleView(withColor: UIColor(named: "PrivacyIndicatorBackground")!)
        let label = statLabel(labelled: Strings.PrivacyDashboard.Legend.Whitelisted)

        let stackView = UIStackView(arrangedSubviews: [dotView, label])
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.isHidden = true
        return stackView
    }()

    private let allTrackersSeenOnLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let domainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.DarkGreen
        return label
    }()

    private let numberOfTrackersLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
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

            self.stackViewForTrackingDisabled.isHidden = self.blocker?.status == .Disabled ? false : true
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
        case .Disabled:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.TrackingDisabled
        case .NoBlockedURLs:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.NoTrackersSeen
        case .Whitelisted:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.Whitelisted
        case .Blocking:
            allTrackersSeenOnLabel.text = Strings.PrivacyDashboard.Title.BlockingEnabled
        }
    }
}

private extension PrivacyDashboardView {
    private func setup() {
        backgroundColor = UIColor.clear

        let titleStackView = UIStackView(arrangedSubviews: [allTrackersSeenOnLabel, domainLabel])
        titleStackView.axis = .vertical

        let mainStackView = UIStackView(arrangedSubviews: [privacyIndicator, pageStatsListStackView])
        mainStackView.spacing = 10
        mainStackView.alignment = .center

        [titleStackView, mainStackView, numberOfTrackersLabel].forEach { addSubview($0) }

        for statType in WTMCategory.all() {
            let dotView = circleView(withColor: statType.color)
            let label = statLabel(labelled: statType.localizedName)

            let numberLabel = statLabel(labelled: "")
            numberLabel.alpha = 0.7

            let stackView = UIStackView(arrangedSubviews: [dotView, label, numberLabel])
            stackView.spacing = 5
            stackView.alignment = .center
            stackView.isHidden = true

            cachedLabelsForStats[statType] = label
            cachedStackViewsForStats[statType] = stackView
            cachedNumberLabelsForStats[statType] = numberLabel

            pageStatsListStackView.addArrangedSubview(stackView)
        }

        pageStatsListStackView.addArrangedSubview(stackViewForTrackingDisabled)
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
            make.width.equalToSuperview().dividedBy(2.2)
        }

        numberOfTrackersLabel.snp.makeConstraints { make in
            make.center.equalTo(privacyIndicator)
        }
    }

    func circleView(withColor: UIColor) -> UIView {
        let radius = 5

        let view = UIView()
        view.snp.makeConstraints { make in
            make.width.equalTo(view.snp.height)
            make.height.equalTo(radius * 2)
        }

        view.backgroundColor = withColor
        view.layer.cornerRadius = CGFloat(radius)
        return view
    }

    func statLabel(labelled text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.Grey90
        label.text = text
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }
}
