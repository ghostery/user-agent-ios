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
    fileprivate let lockDispatchQueue = DispatchQueue(label: "com.cliqz.jsbridge.lock", attributes: [])
    fileprivate let lockSemaphore = DispatchSemaphore(value: 0)
    fileprivate var bridgeReady = false

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["publishEvent", "callAction"]
    }

    func callAction(module: String, action: String, args: [Any]) {
        lockDispatchQueue.async {
            if !self.bridgeReady {
                self.lockSemaphore.wait()
            }
            self.sendEvent(withName: "callAction", body: ["module": module, "action": action, "args": args])
        }
    }

    @objc(ready)
    func ready() {
        if !bridgeReady {
            bridgeReady = true
            lockSemaphore.signal()
        }
    }
}
