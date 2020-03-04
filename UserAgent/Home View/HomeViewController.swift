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

class HomeViewNavigationController: UINavigationController {
    private let homeViewController: HomeViewController!

    var homePanelDelegate: HomePanelDelegate? {
        didSet {
            self.homeViewController.homePanelDelegate = homePanelDelegate
        }
    }

    init(profile: Profile) {
        self.homeViewController = HomeViewController(profile: profile)
        super.init(rootViewController: self.homeViewController)
        self.setNavigationBarHidden(true, animated: false)
        self.navigationBar.isTranslucent = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented, use init(profile:) instead.")
    }
}

extension HomeViewNavigationController: HomeViewControllerProtocol {
    func refreshTopSites() {
        self.homeViewController.refreshTopSites()
    }

    func refreshBookmarks() {
        self.homeViewController.refreshBookmarks()
    }

    func refreshHistory() {
        self.homeViewController.refreshHistory()
    }

    func applyTheme() {
        self.homeViewController.applyTheme()
    }

    func scrollToTop() {
        self.homeViewController.scrollToTop()
    }

    func scrollToTop(animated: Bool) {
        self.homeViewController.scrollToTop(animated: animated)
    }

    func switchView(segment: HomeViewController.Segment) {
        self.homeViewController.switchView(segment: segment)
    }

    func switchViewToDefaultSegment() {
        self.homeViewController.switchViewToDefaultSegment()
    }
}

/// Shows the New Tab view, including Pinned Sites and Top Sites
class HomeViewController: UIViewController {
    // MARK: Properties
    weak var homePanelDelegate: HomePanelDelegate?

    fileprivate let profile: Profile

    enum Segment: Int32 {
        case topSites = 0
        case bookmarks
        case history

        var title: String {
            switch self {
            case .topSites:
                return Strings.HomeView.SegmentedControl.TopSitesTitle
            case .bookmarks:
                return Strings.HomeView.SegmentedControl.BookmarksTitle
            case .history:
                return Strings.HomeView.SegmentedControl.HistoryTitle
            }
        }

        static var defaultValue: Segment {
            return .topSites
        }

    }

    private let segments: [Segment] = [.topSites, .bookmarks, .history]
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: self.segments.map({ $0.title }))
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

    private lazy var bookmarksView: BookmarksView = {
        let bookmarksView = BookmarksView(profile: self.profile)
        bookmarksView.delegate = self
        return bookmarksView
    }()

    private lazy var historyView: HistoryView = {
        let historyView = HistoryView(profile: self.profile)
//        historyView.delegate = self
        return historyView
    }()

    // MARK: - Initialization
    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: .NewsSettingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationReceived), name: .NewTabPageDefaultViewSettingsDidChange, object: nil)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // MARK: - Actions
    @objc private func notificationReceived(_ notification: Notification) {
        DispatchQueue.main.async {
            switch notification.name {
            case .NewsSettingsDidChange:
                self.refreshTopSites()
            case .NewTabPageDefaultViewSettingsDidChange:
                self.switchToDefaultSegment()
            default:
                print("Error: Received unexpected notification \(notification.name)")
            }
        }
    }

    func refresh() {
        self.topSitesView.reloadData()
        self.bookmarksView.reloadData()
        self.historyView.reloadData()
    }
}

// MARK: - Private Implementation
private extension HomeViewController {
    func setup() {
        setupSegmentedControl()
        setupConstraints()
    }

    func switchToDefaultSegment() {
        var defaultSegment: Segment = Segment.defaultValue
        if let rawValue = self.profile.prefs.intForKey(PrefsKeys.NewTabPageDefaultView), let segment = Segment(rawValue: rawValue) {
            defaultSegment = segment
        }
        showView(segment: defaultSegment)
        guard let segmentIndex = segments.firstIndex(of: defaultSegment) else { return }
        segmentedControl.selectedSegmentIndex = segmentIndex
    }

    func setupSegmentedControl() {
        self.switchToDefaultSegment()
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

    func switchViewToDefaultSegment() {
        self.switchToDefaultSegment()
    }

    func scrollToTop() {}
    func scrollToTop(animated: Bool) {}

    func refreshTopSites() {
        self.topSitesView.reloadData()
    }

    func refreshBookmarks() {
        self.bookmarksView.reloadData()
    }

    func refreshHistory() {
        self.historyView.reloadData()
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
