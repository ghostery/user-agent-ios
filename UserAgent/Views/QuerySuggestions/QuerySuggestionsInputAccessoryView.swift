//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

protocol QuerySuggestionDelegate: class {
    func querySuggestionTapped(_ suggestion: String)
}

class QuerySuggestionsInputAccessoryView: UIView {
    static let ShowSuggestionsNotification = NSNotification.Name(rawValue: "ShowSuggestionsNotification")

    public weak var delegate: QuerySuggestionDelegate?

    private var suggestionsView: SuggestionsView!

    // MARK: - Initialization
    init() {
        let screenBounds = UIScreen.main.bounds
        let width = min(screenBounds.width, screenBounds.height)
        let frame = CGRect(x: 0.0, y: 0.0, width: width, height: 44)

        super.init(frame: frame)

        self.isHidden = true
        self.autoresizingMask = .flexibleWidth
        self.backgroundColor = UIColor(rgb: 0xADB5BD)

        addSuggestionsView(frame: frame)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showSuggestions),
            name: type(of: self).ShowSuggestionsNotification,
            object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Helpers
    @objc private func showSuggestions(notification: NSNotification) {
        guard
            let suggestionsData = notification.object as? [String: AnyObject],
            let query = suggestionsData["query"] as? String,
            let suggestions = suggestionsData["suggestions"] as? [String]
        else { return }

        DispatchQueue.main.async {
            if self.suggestionsView.displaySuggestions(query: query, suggestions: suggestions) {
                self.isHidden = false
            } else {
                self.isHidden = true
            }
        }
    }

    private func addSuggestionsView(frame: CGRect) {
        let suggestionsView = SuggestionsView()
        suggestionsView.frame = frame
        suggestionsView.autoresizingMask = .flexibleWidth
        suggestionsView.onSuggestionTapped = { suggestion in
            self.delegate?.querySuggestionTapped(suggestion)
        }
        addSubview(suggestionsView)
        self.suggestionsView = suggestionsView
    }
}
