//
//  ReactNativeHomeViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 22.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class HomeViewController: ReactViewController {
    weak var homePanelDelegate: HomePanelDelegate?

    fileprivate let profile: Profile

    init(profile: Profile) {
        self.profile = profile
        super.init(componentName: "Home", initialProperties: nil)
        // TODO: user proper caching
        self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func applyTheme() {
        view.backgroundColor = UIColor.theme.browser.background
    }

    func scrollToTop() {

    }

    func scrollToTop(animated: Bool) {

    }
}
