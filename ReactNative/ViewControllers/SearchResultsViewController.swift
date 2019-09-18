//
//  SearchResultsViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import Foundation
import React

class SearchResultsViewController: ReactViewController {
    var lastQuery: String = ""

    fileprivate let profile: Profile

    init(profile: Profile, isPrivate: Bool) {
        self.profile = profile
        super.init(componentName: "SearchResults", initialProperties: [
            "theme": SearchResultsViewController.getTheme(),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var searchQuery: String = "" {
        didSet {
            var keyCode = ""
            let lastStringLength = lastQuery.count

            if lastStringLength - searchQuery.count == 1 {
                keyCode = "Backspace"
            } else if searchQuery.count > lastStringLength {
                keyCode = "Key" + String(searchQuery.last!).uppercased()
            }

            lastQuery = searchQuery

            browserCore.callAction(module: "search", action: "startSearch", args: [
                searchQuery,
                ["key": keyCode],
                ["contextId": "mobile-cards"],
            ])
        }
    }

    func handleKeyCommands(sender: UIKeyCommand) {

    }

    fileprivate static func getTheme() -> [String: Any] {
        return [
            "backgroundColor": UIColor.theme.browser.background.hexString,
        ]
    }
}

extension SearchResultsViewController: Themeable {
    func applyTheme() {
        view.backgroundColor = UIColor.clear
        browserCore.callAction(
            module: "Screen:SearchResults",
            action: "changeTheme",
            args: [SearchResultsViewController.getTheme()]
        )
    }
}
