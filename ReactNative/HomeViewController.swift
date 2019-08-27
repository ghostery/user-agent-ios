//
//  ReactNativeHomeViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 22.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import React

class HomeViewController: UIViewController, HomeViewControllerProtocol {
    weak var homePanelDelegate: HomePanelDelegate?
    fileprivate let profile: Profile

    init(profile: Profile) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        #if DEBUG
            let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        #else
            let jsCodeLocation = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif

        self.view = RCTRootView(
            bundleURL: jsCodeLocation!,
            moduleName: "RNHighScores",
            initialProperties: nil,
            launchOptions: nil
        )
    }

    func applyTheme() {
        
    }

    func scrollToTop() {
    
    }

    func scrollToTop(animated: Bool) {

    }
}
