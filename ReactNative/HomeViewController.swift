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
        setupReactView()
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
