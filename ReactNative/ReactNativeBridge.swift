//
//  ReactNativeBridge.swift
//  Client
//
//  Created by Krzysztof Modras on 30.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React

class ReactNativeBridge {
    static let sharedInstance = ReactNativeBridge()

    lazy var bridge: RCTBridge = RCTBridge(delegate: ReactNativeBridgeDelegate(), launchOptions: nil)

    var browserCore: BrowserCore {
        return bridge.module(for: JSBridge.self) as! JSBridge
    }
}

private class ReactNativeBridgeDelegate: NSObject, RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge!) -> URL! {
        #if DEBUG
            return URL(string: "http://localhost:8081/index.bundle?platform=ios")
        #else
            return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}
