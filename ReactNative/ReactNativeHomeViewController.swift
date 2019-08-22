//
//  ReactNativeHomeViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 22.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation

class ReactNativeHomeViewController: UIViewController, HomePanel {
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
        let jsCodeLocation = URL(string: "http://localhost:8081/ReactNative/index.bundle?platform=ios")

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
}
