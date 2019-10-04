//
//  Tabs.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//
import React
import Storage

let HideKeyboardSearchNotification = NSNotification.Name(rawValue: "Search:hideKeyboard")

@objc(BrowserActions)
class BrowserActions: NSObject {
    @objc(openLink:query:isSearchEngine:)
    public func openLink(url_str: NSString, query: NSString, isSearchEngine: Bool) {
        DispatchQueue.main.async {
            guard let appDel = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            var url: URL?
            if let selectedUrl = URL(string: url_str as String) {
                url = selectedUrl
            } else if let encodedString = url_str.addingPercentEncoding(
                withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {
                url = URL(string: encodedString)
            }

            if let url = url {
                appDel.browserViewController.homePanel(didSelectURL: url, visitType: VisitType.link)
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
        guard let query = query, let suggestions = suggestions else { return }
        NotificationCenter.default.post(
            name: QuerySuggestionsInputAccessoryView.ShowSuggestionsNotification,
            object: ["query": query, "suggestions": suggestions])
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
                            if let url = URL(string: site.url), !self.isDuckduckGoRedirectURL(url) {
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

    private func isDuckduckGoRedirectURL(_ url: URL) -> Bool {
        let urlString = url.absoluteString
        if "duckduckgo.com" == url.host,
            urlString.contains("kh="),
            urlString.contains("uddg=") {
            return true
        }

        return false
    }

    @objc(requiresMainQueueSetup)
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
