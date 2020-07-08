//
//  Tabs.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React
import Storage
import Shared

let HideKeyboardSearchNotification = NSNotification.Name(rawValue: "Search:hideKeyboard")

@objc(BrowserActions)
class BrowserActions: NSObject, NativeModuleBase {
    @objc(openLink:query:)
    public func openLink(url_str: NSString, query: NSString) {
        self.withAppDelegate { appDel in
            appDel.useCases.openLink.openLink(urlString: url_str as String, query: query as String)
        }
    }

    @objc(openDomain:)
    public func openDomain(name: NSString) {
        let domainName = name as String
        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                return
            }

            profile.history.getDomainProtocol(domainName).uponQueue(.main) { protocolName in
                guard let protocolName = protocolName.successValue else { return }
                let url = URL(string: "\(protocolName)://\(domainName)")
                guard let urlString = url?.absoluteString else {
                    return
                }
                appDel.useCases.openLink.openLink(urlString: urlString, query: "")
            }
        }
    }

    @objc(hideKeyboard)
    func hideKeyboard() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: HideKeyboardSearchNotification, object: nil, userInfo: nil)
        }
    }

    @objc(startSearch:)
    func startSearch(query: NSString) {
        self.withAppDelegate { appDel in
            let query = query as String
            _ = appDel.browserViewController.focusLocationTextField(
                forTab: appDel.browserViewController.tabManager.selectedTab,
                setSearchText: query)
        }
    }

    @objc(showQuerySuggestions:suggestions:)
    func showQuerySuggestions(query: NSString?, suggestions: NSArray?) {
        guard let query = query, let suggestions = suggestions else {
            NotificationCenter.default.post(name: QuerySuggestionsInputAccessoryView.ShowSuggestionsNotification, object: nil)
            return
        }
        NotificationCenter.default.post(name: QuerySuggestionsInputAccessoryView.ShowSuggestionsNotification, object: ["query": query, "suggestions": suggestions])
    }

    @objc(searchHistory:callback:)
    func searchHistory(query: NSString, callback: @escaping RCTResponseSenderBlock) {
        debugPrint("searchHistory")

        DispatchQueue.main.async {
            if let appDel = UIApplication.shared.delegate as? AppDelegate {
                if let profile = appDel.profile {
                    var results: [[String: Any]] = []
                    let frecentHistory = profile.history.getFrecentHistory()
                    frecentHistory.getSites(matchingSearchQuery: query as String, limit: 100).upon { sites in
                        guard let sites = sites.successValue?.asArray() else {
                            return
                        }

                        for site in sites {
                            if
                                let url = URL(string: site.url),
                                !profile.searchEngines.isSearchEngineRedirectURL(url: url, query: query as String)
                            {
                                results.append(site.toDict())
                            }
                        }
                        callback([results])
                    }
                }
            }
        }
    }

    @objc(getQuerySuggestions:resolve:reject:)
    func getQuerySuggestions(
        query: NSString,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        self.withAppDelegate { appDel in
            guard let profile = appDel.profile else {
                reject("profile", "Profile not loaded", nil)
                return
            }
            let engine = profile.searchEngines.defaultEngine
            let ua = UserAgent.desktopUserAgent()

            let suggestClient = SearchSuggestClient(searchEngine: engine, userAgent: ua)
            suggestClient.query(query as String) { (suggestions, error) in
                if error != nil {
                    reject("suggestions", "something when wrong", nil)
                    return
                }
                resolve(suggestions)
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
