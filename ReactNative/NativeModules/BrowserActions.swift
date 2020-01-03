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

private struct MozActionParams: Codable {
    var url: String
}

@objc(BrowserActions)
class BrowserActions: NSObject, NativeModuleBase {
    @objc(openLink:query:isSearchEngine:)
    public func openLink(url_str: NSString, query: NSString, isSearchEngine: Bool) {
        self.withAppDelegate { appDel in
            var url: URL?

            if url_str.hasPrefix("moz-action:") {
                let decoder = JSONDecoder()
                let mozActionComponents = url_str.components(separatedBy: ",")

                guard
                   let mozActionData = mozActionComponents[1].data(using: .ascii),
                   let mozActionParams = try? decoder.decode(MozActionParams.self, from: mozActionData)
                else { return }

                url = URL(string: mozActionParams.url)

                guard let url = url else { return }
                appDel.browserViewController.switchToTabForURLOrOpen(url, isPrivileged: true)
                return
            }

            if let selectedUrl = URL(string: url_str as String) {
                url = selectedUrl
            } else if let encodedString = url_str.addingPercentEncoding(
                withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {
                url = URL(string: encodedString)
            }

            if
                let url = url,
                let tab = appDel.tabManager.selectedTab
            {
                appDel.browserViewController.finishEditingAndSubmit(url,
                    visitType: VisitType.link,
                    forTab: tab)
                if query.length > 0 {
                    tab.queries[url] = String(query)
                }
            }
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
