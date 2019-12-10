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

    enum Segment {
        case topSites
        case bookmarks
        case history
    }

    private let segments: [Segment] = [.topSites, .bookmarks, .history]
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: self.segments.map({ self.title(for: $0) }))
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        segmentedControl.setContentCompressionResistancePriority(.required, for: .vertical)
        if #available(iOS 13.0, *) {
            segmentedControl.backgroundColor = UIColor.systemGray6
        } else {
            segmentedControl.backgroundColor = UIColor.Grey20
        }
        return segmentedControl
    }()

    private lazy var allViews: [UIView] = { return [topSitesView, bookmarksView, historyView] }()

    private lazy var topSitesView: TopSitesView = {
        let topSitesView = TopSitesView(profile: self.profile)
        return topSitesView
    }()

    private lazy var bookmarksView: UIView = {
        let bookmarksView = BookmarksView(profile: self.profile)
        bookmarksView.delegate = self
        return bookmarksView
    }()

    private lazy var historyView: UIView = {
        let historyView = HistoryView(profile: self.profile)
        historyView.delegate = self
        return historyView
    }()

    // MARK: - Initialization
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: .NewsSettingsChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(profile:) instead.")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    // MARK: - Actions
    @objc private func notificationReceived(_ notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case .NewsSettingsChange:
                print("Update top sites")
            default:
                print("Error: Received unexpected notification \(notification.name)")
            }
        }
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
        segmentedControl.tintColor = UIColor.BrightBlue
    }

    func setupConstraints() {
        view.addSubview(segmentedControl)
        view.addSubview(topSitesView)
        view.addSubview(bookmarksView)
        view.addSubview(historyView)

        let margins = 8

        segmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(margins)
            make.left.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.leftMargin).offset(margins)
            make.right.lessThanOrEqualTo(self.view.safeAreaLayoutGuide.snp.rightMargin).offset(-margins)
            make.centerX.equalToSuperview()
        }

        topSitesView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(margins)
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }

        bookmarksView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(margins)
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }

        historyView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(margins)
            make.bottom.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
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
            return Strings.HomeView.SegmentedControl.TopSitesTitle
        case .bookmarks:
            return Strings.HomeView.SegmentedControl.BookmarksTitle
        case .history:
            return Strings.HomeView.SegmentedControl.HistoryTitle
        }
    }
}

// MARK: - HomeViewControllerProtocol
extension HomeViewController: HomeViewControllerProtocol {
    func applyTheme() {
        view.backgroundColor = Theme.browser.background
        self.allViews.forEach({ ($0 as? Themeable)?.applyTheme() })
    }

    func switchView(segment: HomeViewController.Segment) {
        self.showView(segment: segment)
        self.segmentedControl.selectedSegmentIndex = self.segments.firstIndex(of: segment) ?? 0
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

    func library(wantsToPresent viewController: UIViewController) {
        self.present(viewController, animated: true)
    }

}

extension HomeViewController: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

}
