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

    private enum Segment {
        case topSites
        case bookmarks
        case history
        case downloads
    }

    private var logo = LogoView(url: "https://cliqz.com")

    private let segments: [Segment] = [.topSites, .bookmarks, .history, .downloads]
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: self.segments.map({ self.title(for: $0) }))
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.setContentCompressionResistancePriority(.required, for: .vertical)
        return segmentedControl
    }()

    private lazy var allViews: [UIView] = { return [topSitesView, bookmarksView, historyView, downloadsView] }()

    private lazy var topSitesView: UIView = {
        let topSitesView = TopSitesView(profile: self.profile)
        return topSitesView
    }()

    private let bookmarksView: UIView = {
        let bookmarksView = UIView()
        bookmarksView.backgroundColor = UIColor.blue
        return bookmarksView
    }()

    private lazy var historyView: UIView = {
        let historyView = HistoryView(profile: self.profile)
        historyView.delegate = self
        return historyView
    }()

    private let downloadsView: UIView = {
        let downloadsView = UIView()
        downloadsView.backgroundColor = UIColor.green
        return downloadsView
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
}

// MARK: - Private Implementation
private extension HomeViewController {
    func setup() {
        setupSegmentedControl()
        setupConstraints()
    }

    func setupSegmentedControl() {
        showView(segment: .topSites)
        guard let segmentIndex = segments.firstIndex(of: .topSites) else { return }
        segmentedControl.selectedSegmentIndex = segmentIndex
    }

    func setupConstraints() {
        view.addSubview(segmentedControl)
        view.addSubview(topSitesView)
        view.addSubview(bookmarksView)
        view.addSubview(historyView)
        view.addSubview(downloadsView)

        historyView.addSubview(logo)
        logo.snp.makeConstraints { make in
            make.width.height.equalTo(60)
        }

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

        bookmarksView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }

        historyView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }

        downloadsView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }

    @objc
    func segmentedControlValueChanged() {
        let value = segments[segmentedControl.selectedSegmentIndex]

        UIView.animate(withDuration: 0.2) {
            self.showView(segment: value)
        }
    }

    private func showView(segment: Segment) {
        allViews.forEach { $0.alpha = 0 }
        guard let segmentIndex = segments.firstIndex(of: segment) else { return }
        allViews[segmentIndex].alpha = 1
    }

    private func title(for segment: Segment) -> String {
        switch segment {
        case .topSites:
            return Strings.SegmentedControlTopSitesTitle
        case .bookmarks:
            return Strings.SegmentedControlBookmarksTitle
        case .history:
            return Strings.SegmentedControlHistoryTitle
        case .downloads:
            return Strings.SegmentedControlDownloadsTitle
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

extension HomeViewController: LibraryViewDelegate {

    func libraryDidRequestToOpenInNewTab(_ url: URL, isPrivate: Bool) {
        self.homePanelDelegate?.homePanelDidRequestToOpenInNewTab(url, isPrivate: isPrivate)
    }

    func library(didSelectURL url: URL, visitType: VisitType) {
        self.homePanelDelegate?.homePanel(didSelectURL: url, visitType: visitType)
    }

    func library(wantsToOpen contextMenu: PhotonActionSheet) {
        self.present(contextMenu, animated: true)
    }

}
