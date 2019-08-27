//
//  SearchResultsViewController.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 27.08.19.
//  Copyright © 2019 Mozilla. All rights reserved.
//

import Foundation

class SearchViewController: UIViewController, ReactBaseView {
    static var componentName: String = "SearchResults"

    fileprivate let profile: Profile

    init(profile: Profile, isPrivate: Bool) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }

    override func loadView() {
        setupReactView()
    }

    var searchQuery: String = "" {
        didSet {

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
