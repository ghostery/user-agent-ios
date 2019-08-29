//
//  ReactNativeHomeViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 22.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class HomeViewController: UIViewController, ReactBaseView, HomeViewControllerProtocol {
    static var componentName: String = "Home"

    weak var homePanelDelegate: HomePanelDelegate?
    fileprivate let profile: Profile

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let view = createReactView()
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: user proper caching
        self.profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme() {
        
    }

    func scrollToTop() {
    
    }

    func scrollToTop(animated: Bool) {

    }
}
