//
//  ReactNativeHomeViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 22.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import React
import Shared
import Storage

/// Shows the New Tab view, including Pinned Sites and Top Sites
class HomeViewController: UIViewController {
    // MARK: Properties
    weak var homePanelDelegate: HomePanelDelegate?

    fileprivate let profile: Profile

    private enum Segment: String {
        case topSites = "top siiites"
        case bookmarks = "boookmarkz"
        case history = "hirrostyyy"
    }

    private let segments: [Segment] = [.topSites, .bookmarks, .history]
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: self.segments.map({ $0.rawValue }))
        return segmentedControl
    }()

    private lazy var topSitesView: UIView = {
        let topSitesView = TopSitesView(profile: self.profile)
        return topSitesView
    }()

    // MARK: - Initialization
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(profile:) instead.")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - API
}

// MARK: - Private Implementation
extension HomeViewController {
    private func setup() {
        setupSegmentedControl()
        setupConstraints()
    }

    private func setupSegmentedControl() {

    }

    private func setupTopSitesView() {

    }

    private func setupConstraints() {
        view.addSubview(segmentedControl)
        view.addSubview(topSitesView)

        let margins = 8

        segmentedControl.snp.makeConstraints { make in

            make.top.equalToSuperview().offset(margins)
            make.left.lessThanOrEqualToSuperview().offset(margins)
            make.right.lessThanOrEqualToSuperview().offset(-margins)
            make.centerX.equalToSuperview()
        }

        topSitesView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
}

// MARK: - HomeViewControllerProtocol
extension HomeViewController: HomeViewControllerProtocol {
    func applyTheme() {
        view.backgroundColor = UIColor.theme.browser.background
    }

    func scrollToTop() {

    }

    func scrollToTop(animated: Bool) {

    }
}
