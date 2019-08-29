//
//  ReactBaseView.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import Foundation
import React

protocol ReactBaseView {
    static var componentName: String { get }
}

extension ReactBaseView {
    // TODO: Ideally this function is replaced with `override loadView`
    func createReactView() -> RCTRootView {
        #if DEBUG
            let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        #else
            let jsCodeLocation = Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif

        return RCTRootView(
            bundleURL: jsCodeLocation!,
            moduleName: type(of: self).componentName,
            initialProperties: nil,
            launchOptions: nil
        )
    }
}