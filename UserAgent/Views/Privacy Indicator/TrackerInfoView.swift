//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class TrackerInfoView: UIView {
    // MARK: - Properties
    var pageStats: TPPageStats? { didSet { self.updateStats() }}
    var domainURL: URL?

    private var cachedLabelsForStats: [WTMCategory: UILabel] = [:]
    private var cachedNumberLabelsForStats: [WTMCategory: UILabel] = [:]
    private var cachedStackViewsForStats: [WTMCategory: UIStackView] = [:]

    private let allTrackersSeenOnLabel: UILabel = {
        let label = UILabel()
        label.text = "All trackers seeeeeen on" // TODO: Localize
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
    func updateStats() {
        guard let pageStats = pageStats else { return }

        DispatchQueue.main.async {
            self.privacyIndicator.update(with: pageStats)
            self.domainLabel.text = self.domainURL?.host
            self.numberOfTrackersLabel.text = "\(pageStats.total)"
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let statsDict = WTMCategory.statsDict(from: pageStats)

            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                for statType in WTMCategory.all() {
                    let value = statsDict[statType, default: 0]
                    self.cachedNumberLabelsForStats[statType]?.text = "\(value)"
                    self.cachedStackViewsForStats[statType]?.isHidden = value <= 0
                    self.cachedStackViewsForStats[statType]?.alpha = value <= 0 ? 0 : 1
                }
            }, completion: nil)
        }
    }
}

private extension TrackerInfoView {
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
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        return label
    }
}
