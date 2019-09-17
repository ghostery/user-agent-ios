//
//  ReactBaseView.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import React

class ReactViewController: UIViewController {
    override var view: UIView! {
        get {
            if  _view == nil {
                _view = RCTRootView(
                    bridge: ReactNativeBridge.sharedInstance.bridge,
                    moduleName: componentName,
                    initialProperties: initialProperties
                )
                viewDidLoad()
            }

            return _view
        }

        set {
            fatalError("Cannot replace React View")
        }
    }

    private let componentName: String
    private var _view: UIView?
    private var initialProperties: [String: Any]?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    init(componentName: String, initialProperties: [String: Any]?) {
        self.componentName = componentName
        self.initialProperties = initialProperties
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var browserCore: JSBridge {
        get {
            return ReactNativeBridge.sharedInstance.browserCore
        }
    }
}
