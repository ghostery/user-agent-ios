//
//  History.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React

@objc(History)
class History: NSObject, NativeModuleBase {
    @objc(getTopSites:reject:)
    func getTopSites(resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                reject("profile", "Profile not loaded", nil)
                return
            }

            profile.history.getTopSitesWithLimit(20).upon { topsites in
                guard let mySites = topsites.successValue?.asArray() else {
                    reject("history", "Top sites db access error", nil)
                    return
                }

                resolve(mySites.map({ ["url": $0.url, "title": $0.title] }))
            }
        }
    }

    @objc(removeDomain:resolve:reject:)
    func removeDomain(
        domainName: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.withAppDelegate { appDel in
            appDel.useCases.history.deleteAllTracesOfDomain(domainName as String) {
                resolve(nil)
            }
        }
    }

    @objc(getDomains:offset:resolve:reject:)
    func getDomains(
        limit: NSInteger,
        offset: NSInteger,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                reject("profile", "Profile not loaded", nil)
                return
            }

            profile.history.getDomainsByLastVisit(limit: limit, offset: offset).upon { domains in
                guard let domains = domains.successValue?.asArray() else {
                    reject("history", "Domains db access error", nil)
                    return
                }

                resolve(domains.map { $0.toDict() })
            }
        }
    }

    @objc(getVisits:limit:offset:resolve:reject:)
    func getVisits(
        domainName: NSString,
        limit: NSInteger,
        offset: NSInteger,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                reject("profile", "Profile not loaded", nil)
                return
            }

            profile.history.getSitesByLastVisit(
                limit: limit,
                offset: offset,
                domainName: domainName as String
            ).upon { sites in
                guard let sites = sites.successValue?.asArray() else {
                    reject("history", "Visits db access error", nil)
                    return
                }

                resolve(sites.map { $0.toDict() })
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
