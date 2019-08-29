//
//  JSBridge.swift
//  Client
//
//  Created by Krzysztof Modras on 29.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import React

@objc(JSBridge)
class JSBridge: RCTEventEmitter {
    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["publishEvent", "callAction"]
    }

    func callAction(module: String, action: String, args: Array<Any>) {
        sendEvent(withName: "callAction", body: ["module": module, "action": action, "args": args])
    }
}
