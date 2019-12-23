//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

private extension String {
    func trim() -> String {
        let newString = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return newString
    }
}

class SuggestionsView: UIView {
    // MARK: - Instance variables
    var onSuggestionTapped: ((_ suggestion: String) -> Void)?

    // MARK: - Constants
    private let boldFontAttributes = [
        NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17),
        NSAttributedString.Key.foregroundColor: UIColor.Grey80,
    ]
    private let normalFontAttributes = [
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        NSAttributedString.Key.foregroundColor: UIColor.Grey80,
    ]
    private let separatorBgColor = UIColor(rgb: 0xC7CBD3)
    private let margin: CGFloat = 10

    // MARK: - Private variables
    private var currentSuggestions: [String] = []

    private(set) var shouldShowSuggestions: Bool = false

    private var currentQuery: String = "" {
        didSet {
            if currentQuery.isEmpty {
                currentSuggestions.removeAll()
                clearSuggestions()
            }
        }
    }

    func updateLastestSuggestions() {
        guard self.shouldShowSuggestions(query: self.currentQuery, suggestions: self.currentSuggestions) else {
            self.shouldShowSuggestions = false
            return
        }
        self.updateSuggestions(query: self.currentQuery, suggestions: self.currentSuggestions)
    }

    // MARK: - Public API
    func updateSuggestions(query: String, suggestions: [String]) {
        self.currentQuery = query
        self.shouldShowSuggestions = false

        guard shouldShowSuggestions(query: query, suggestions: suggestions) else {
            updateSuggestions(suggestions)
            return
        }

        self.clearSuggestions()
        currentSuggestions = suggestions

        var index = 0
        var x: CGFloat = margin
        var difference: CGFloat = 0
        var offset: CGFloat = 0
        var displayedSuggestions = [(String, CGFloat)]()
        let maxSuggestionsCount = getMaxSuggestionsCount()

        // Calcuate extra space after the last suggesion
        for suggestion in suggestions {
            if suggestion.trim() == query.trim() {
                continue
            }
            let suggestionWidth = getWidth(suggestion)
            // show Max N suggestions which does not exceed screen width
            if x + suggestionWidth > self.frame.width || displayedSuggestions.count == maxSuggestionsCount {
                break
            }
            // increment step
            x = x + suggestionWidth + 2*margin + 1
            index = index + 1
            displayedSuggestions.append((suggestion, suggestionWidth))
        }

        // distribute the extra space evenly on all suggestions
        difference = self.frame.width - x
        offset = round(difference/CGFloat(index))

        // draw the suggestions inside the view
        x = margin
        index = 0
        for (suggestion, width) in displayedSuggestions {
            let suggestionWidth = width + offset
            // Adding vertical separator between suggestions
            if index > 0 {
                let verticalSeparator = createVerticalSeparator(x)
                self.addSubview(verticalSeparator)
            }
            // Adding the suggestion button
            let suggestionButton = createSuggestionButton(x, index: index, suggestion: suggestion, suggestionWidth: suggestionWidth)
            self.addSubview(suggestionButton)

            // increment step
            x = x + suggestionWidth + 2*margin + 1
            index = index + 1
            self.shouldShowSuggestions = true
        }
    }

    // MARK: - Helper methods
    private func clearSuggestions() {
        let subViews = self.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
    }

    private func shouldShowSuggestions(query: String, suggestions: [String]) -> Bool {
        return currentQuery == query && !suggestions.isEmpty
    }

    private func updateSuggestions(_ suggestions: [String]) {
        currentSuggestions = suggestions
    }

    private func getMaxSuggestionsCount() -> Int {
        switch traitCollection.horizontalSizeClass {
        case .regular:
            return 5
        default:
            return 3
        }
    }

    private func getWidth(_ suggestion: String) -> CGFloat {
        let sizeOfString = (suggestion as NSString).size(withAttributes: boldFontAttributes)
        return sizeOfString.width + 5
    }

    private func createVerticalSeparator(_ x: CGFloat) -> UIView {
        let verticalSeparator = UIView()
        verticalSeparator.frame = CGRect(x: x-11, y: 0, width: 1, height: self.frame.height)
        verticalSeparator.backgroundColor = separatorBgColor
        return verticalSeparator
    }

    private func createSuggestionButton(_ x: CGFloat, index: Int, suggestion: String, suggestionWidth: CGFloat) -> UIButton {
        let button = UIButton(type: .custom)
        let suggestionTitle = getTitle(suggestion)
        button.setAttributedTitle(suggestionTitle, for: UIControl.State())
        button.frame = CGRect(x: x, y: 0, width: suggestionWidth, height: self.frame.height)
        button.addTarget(self, action: #selector(selectSuggestion(_:)), for: .touchUpInside)
        button.tag = index
        return button
    }

    private func getTitle(_ suggestion: String) -> NSAttributedString {
        let prefix = currentQuery
        var title: NSMutableAttributedString!

        if let range = suggestion.range(of: prefix), range.lowerBound == suggestion.startIndex {
            title = NSMutableAttributedString(string: prefix, attributes: normalFontAttributes)
            var suffix = suggestion
            suffix.replaceSubrange(range, with: "")
            title.append(NSAttributedString(string: suffix, attributes: boldFontAttributes))
        } else {
            title = NSMutableAttributedString(string: suggestion, attributes: boldFontAttributes)
        }
        return title
    }

    @objc private func selectSuggestion(_ button: UIButton) {
        guard let suggestion = button.titleLabel?.text else {
            return
        }
        onSuggestionTapped?(suggestion + " ")
    }
}
