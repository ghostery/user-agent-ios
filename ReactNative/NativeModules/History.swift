//
//  History.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React

@objc(History)
class History: NSObject {
    @objc(getTopSites:reject:)
    func getTopSites(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                reject("app", "Application not fully initialized", NSError())
                return
            }

            guard let profile = appDel.profile else {
                reject("profile", "Profile not loaded", NSError())
                return
            }

            profile.history.getTopSitesWithLimit(20).upon { topsites in
                guard let mySites = topsites.successValue?.asArray() else {
                    reject("history", "Top sites db access error", NSError())
                    return
                }

                resolve(mySites.map({ ["url": $0.url, "title": $0.title] }))
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
