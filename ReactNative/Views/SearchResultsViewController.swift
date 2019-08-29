//
//  SearchResultsViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import Foundation
import React

class SearchViewController: UIViewController, ReactBaseView {
    var bridge: RCTBridge?
    var lastQuery: String = ""

    static var componentName: String = "SearchResults"

    fileprivate let profile: Profile

    init(profile: Profile, isPrivate: Bool) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        let view = createReactView()
        self.view = view
        bridge = view.bridge 
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

            (bridge?.module(for: JSBridge.self) as! JSBridge).callAction(module: "search", action: "startSearch", args: [
                searchQuery,
                ["key": keyCode],
                ["contextId": "mobile-cards"],
            ])
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func handleKeyCommands(sender: UIKeyCommand) {

    }
}

extension SearchViewController: Themeable {
    func applyTheme() {

    }
}
