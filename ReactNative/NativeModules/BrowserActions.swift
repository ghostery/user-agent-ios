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

    @objc(hideKeyboard)
    func hideKeyboard() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: HideKeyboardSearchNotification, object: nil, userInfo: nil)
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
                    var results: [[String: String]] = []
                    let frecentHistory = profile.history.getFrecentHistory()
                    frecentHistory.getSites(matchingSearchQuery: query as String, limit: 100).upon { sites in
                        guard let sites = sites.successValue?.asArray() else {
                            return
                        }

                        for site in sites {
                            if let url = URL(string: site.url), !profile.searchEngines.isSearchEngineRedirectURL(url: url, query: query as String) {
                                let d = ["url": site.url, "title": site.title]
                                results.append(d)
                            }
                        }
                        callback([results])
                    }
                }
            }
        }
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
