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

        self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)

        _ = self.profile.history.getTopSitesWithLimit(8).both(
            self.profile.history.getPinnedTopSites()
        ).bindQueue(.main) { (topSites, pinned) -> Success in
            self.addHomeView(
                speedDials: topSites.successValue?.asArray() ?? [],
                pinnedSites: pinned.successValue?.asArray() ?? []
            )
            return succeed()
        }
    }

    // MARK: - API

    // MARK: - Private Implementation
    private func addHomeView(speedDials: [Site], pinnedSites: [Site]) {
        func toDial(site: Site) -> [String: String] {
            return [
                "url": site.url,
                "title": site.title,
            ]
        }

        let reactView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Home",
            initialProperties: [
                "speedDials": speedDials.map(toDial),
                "pinnedSites": pinnedSites.map(toDial),
            ]
        )

        guard let homeView = reactView else { return }

        self.view.addSubview(homeView)

        homeView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self.view)
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
