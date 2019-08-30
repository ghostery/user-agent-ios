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
    init(componentName: String) {
        super.init(nibName: nil, bundle: nil)

        view = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: componentName,
            initialProperties: nil
        )
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
