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
    public typealias Callback = (_ error: NSError?, _ result: Any?) -> Void

    private typealias ActionId = NSInteger
    private let lockDispatchQueue = DispatchQueue(label: "com.cliqz.jsbridge.lock", attributes: [])
    private let lockSemaphore = DispatchSemaphore(value: 0)
    private var bridgeReady = false
    private var actionCounter: ActionId = 0
    private var callbacks = [ActionId: Callback]()

    override static func requiresMainQueueSetup() -> Bool {
        return false
    }

    override open func supportedEvents() -> [String]! {
        return ["publishEvent", "callAction"]
    }

    func callAction(module: String, action: String, args: [Any], callback: Callback? = nil) {
        var actionId: ActionId?

        if callback != nil {
            actionId = self.nextActionId()
            self.callbacks[actionId!] = callback
        }

        lockDispatchQueue.async {
            if !self.bridgeReady {
                self.lockSemaphore.wait()
            }

            var body: [String: Any] = ["module": module, "action": action, "args": args]

            if let actionId = actionId {
                body["id"] = actionId
            }

            self.sendEvent(withName: "callAction", body: body)
        }
    }

    @objc(ready)
    func ready() {
        if !bridgeReady {
            bridgeReady = true
            lockSemaphore.signal()
        }
    }

    @objc(replyToAction:result:)
    func replyToAction(_ actionId: NSInteger, result: NSDictionary) {
        if let callback = self.callbacks[actionId] {
            if let error = result["error"] {
                callback(NSError(domain: "BrowserCore", code: 100, userInfo: ["error": error]), nil)
            } else {
                callback(nil, result["result"])
            }
        }
    }

    private func nextActionId() -> ActionId {
        self.actionCounter += 1
        return self.actionCounter
    }
}
