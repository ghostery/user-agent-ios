//
//  ReactBaseView.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import React

/// Encapsulates a React Native View
class ReactViewController: UIViewController, BrowserCoreClient {

    // MARK: Properties
    private let componentName: String
    private var initialProperties: [String: Any]?

    init(componentName: String, initialProperties: [String: Any]?) {
        self.componentName = componentName
        self.initialProperties = initialProperties
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: componentName,
            initialProperties: initialProperties
        )
    }
}
