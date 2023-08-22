/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import Shared
import SnapKit
import Storage
import SDWebImage

private let log = Logger.browserLogger

class CustomSearchError: MaybeErrorType {

    enum Reason {
        case DuplicateEngine, FormInput
    }

    var reason: Reason!

    internal var description: String {
        return "Search Engine Not Added"
    }

    init(_ reason: Reason) {
        self.reason = reason
    }
}

class CustomSearchViewController: SettingsTableViewController {

    fileprivate var urlString: String?
    fileprivate var engineTitle = ""
    fileprivate lazy var spinnerView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .gray)
        spinner.hidesWhenStopped = true
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Strings.Settings.Search.AddCustomEngine.Title
        view.addSubview(spinnerView)
        spinnerView.snp.makeConstraints { make in
            make.center.equalTo(self.view.snp.center)
        }
    }

    var successCallback: (() -> Void)?

    fileprivate func addSearchEngine(_ searchQuery: String, title: String) {
        spinnerView.startAnimating()

        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)

        createEngine(forQuery: trimmedQuery, andName: trimmedTitle).uponQueue(.main) { result in
            self.spinnerView.stopAnimating()
            guard let engine = result.successValue else {
                let alert: UIAlertController
                let error = result.failureValue as? CustomSearchError

                alert = (error?.reason == .DuplicateEngine) ?
                    ThirdPartySearchAlerts.duplicateCustomEngine() : ThirdPartySearchAlerts.incorrectCustomEngineForm()

                self.navigationItem.rightBarButtonItem?.isEnabled = true
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.profile.searchEngines.addSearchEngine(engine)

            CATransaction.begin() // Use transaction to call callback after animation has been completed
            CATransaction.setCompletionBlock(self.successCallback)
            _ = self.navigationController?.popViewController(animated: true)
            CATransaction.commit()
        }
    }

    func createEngine(forQuery query: String, andName name: String) -> Deferred<Maybe<OpenSearchEngine>> {
        let deferred = Deferred<Maybe<OpenSearchEngine>>()
        guard let template = getSearchTemplate(withString: query),
            let url = URL(string: template.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!), url.isWebPage() else {
                deferred.fill(Maybe(failure: CustomSearchError(.FormInput)))
                return deferred
        }

        // ensure we haven't already stored this template
        guard engineExists(name: name, template: template) == false else {
            deferred.fill(Maybe(failure: CustomSearchError(.DuplicateEngine)))
            return deferred
        }

        func fillDeferred(image: UIImage?) {
            let engine = OpenSearchEngine(engineID: nil, shortName: name, image: image, searchTemplate: template, suggestTemplate: nil, isCustomEngine: true)

            // Make sure a valid scheme is used
            let testUrl = engine.searchURLForQuery("test")
            let maybe = (testUrl == nil) ? Maybe(failure: CustomSearchError(.FormInput)) : Maybe(success: engine)
            deferred.fill(maybe)
        }

        switch Features.Icons.type {
        case .cliqz:
            fillDeferred(image: nil)
        case .favicon:
            FaviconFetcher.fetchFavImageForURL(forURL: url, profile: profile).uponQueue(.main) { result in
                let image = result.successValue ?? FaviconFetcher.letter(forUrl: url)
                fillDeferred(image: image)
            }
        }
        return deferred
    }

    private func engineExists(name: String, template: String) -> Bool {
        return profile.searchEngines.orderedEngines.contains { (engine) -> Bool in
            return engine.shortName == name || engine.searchTemplate == template
        }
    }

    func getSearchTemplate(withString query: String) -> String? {
        let SearchTermComponent = "%s"      // Placeholder in User Entered String
        let placeholder = "{searchTerms}"   // Placeholder looked for when using Custom Search Engine in OpenSearch.swift

        if query.contains(SearchTermComponent) {
            return query.replacingOccurrences(of: SearchTermComponent, with: placeholder)
        }
        return nil
    }

    override func generateSettings() -> [SettingSection] {

        func URLFromString(_ string: String?) -> URL? {
            guard let string = string else {
                return nil
            }
            return URL(string: string)
        }

        let titleField = CustomSearchEngineTextView(placeholder: Strings.Settings.Search.AddCustomEngine.TitlePlaceholder, settingIsValid: { text in
            return text != nil && text?.isEmpty != true
        }, settingDidChange: {fieldText in
            guard let title = fieldText else {
                return
            }
            self.engineTitle = title
        })
        titleField.textField.text = engineTitle
        titleField.textField.accessibilityIdentifier = "customEngineTitle"

        let urlField = CustomSearchEngineTextView(placeholder: Strings.Settings.Search.AddCustomEngine.URLPlaceholder, height: 133, keyboardType: .URL, settingIsValid: { text in
            // Can check url text text validity here.
            return true
        }, settingDidChange: {fieldText in
            self.urlString = fieldText
        })

        urlField.textField.autocapitalizationType = .none
        urlField.textField.text = urlString
        urlField.textField.accessibilityIdentifier = "customEngineUrl"

        let settings: [SettingSection] = [
            SettingSection(title: NSAttributedString(string: Strings.Settings.Search.AddCustomEngine.TitleFieldSectionTitle), children: [titleField]),
            SettingSection(title: NSAttributedString(string: Strings.Settings.Search.AddCustomEngine.URLSectionTitle), footerTitle: NSAttributedString(string: "https://youtube.com/search?q=%s"), children: [urlField]),
        ]

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.addCustomSearchEngine))
        self.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "customEngineSaveButton"

        return settings
    }

    @objc func addCustomSearchEngine(_ nav: UINavigationController?) {
        self.view.endEditing(true)
        navigationItem.rightBarButtonItem?.isEnabled = false
        if let url = self.urlString {
            self.addSearchEngine(url, title: self.engineTitle)
        }
    }
}

class CustomSearchEngineTextView: Setting, UITextViewDelegate {

    fileprivate let Padding: CGFloat = 8
    fileprivate let TextLabelHeight: CGFloat = 44
    fileprivate var TextLabelWidth: CGFloat {
        let width = textField.frame.width == 0 ? 360 : textField.frame.width
        return width
    }
    fileprivate var TextFieldHeight: CGFloat = 44

    fileprivate let defaultValue: String?
    fileprivate let placeholder: String
    fileprivate let settingDidChange: ((String?) -> Void)?
    fileprivate let settingIsValid: ((String?) -> Bool)?

    let textField = UITextView()
    let placeholderLabel = UILabel()
    var keyboardType: UIKeyboardType = .default

    init(defaultValue: String? = nil, placeholder: String, height: CGFloat = 44, keyboardType: UIKeyboardType = .default, settingIsValid isValueValid: ((String?) -> Bool)? = nil, settingDidChange: ((String?) -> Void)? = nil) {
        self.defaultValue = defaultValue
        self.TextFieldHeight = height
        self.settingDidChange = settingDidChange
        self.settingIsValid = isValueValid
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        textField.addSubview(placeholderLabel)
        super.init(cellHeight: TextFieldHeight)
    }

    override func onConfigureCell(_ cell: ThemedTableViewCell) {
        super.onConfigureCell(cell)
        if let id = accessibilityIdentifier {
            textField.accessibilityIdentifier = id + "TextField"
        }

        placeholderLabel.adjustsFontSizeToFitWidth = true
        placeholderLabel.textColor = Theme.general.settingsTextPlaceholder
        placeholderLabel.text = placeholder
        placeholderLabel.isHidden = !textField.text.isEmpty
        placeholderLabel.frame = CGRect(width: TextLabelWidth, height: TextLabelHeight)
        textField.font = placeholderLabel.font

        textField.textContainer.lineFragmentPadding = 0
        textField.keyboardType = keyboardType
        if keyboardType == .default {
            textField.autocapitalizationType = .words
        }
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.backgroundColor = Theme.tableView.rowBackground
        textField.textColor = Theme.tableView.rowText
        cell.isUserInteractionEnabled = true
        cell.accessibilityTraits = UIAccessibilityTraits.none
        cell.contentView.addSubview(textField)
        cell.selectionStyle = .none

        textField.snp.makeConstraints { make in
            make.height.equalTo(TextFieldHeight)
            make.left.right.equalTo(cell.contentView).inset(Padding)
        }
    }

    override func onClick(_ navigationController: UINavigationController?) {
        textField.becomeFirstResponder()
    }

    fileprivate func isValid(_ value: String?) -> Bool {
        guard let test = settingIsValid else {
            return true
        }
        return test(prepareValidValue(userInput: value))
    }

    func prepareValidValue(userInput value: String?) -> String? {
        return value
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = textField.text.isEmpty == false
    }

    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = textField.text.isEmpty == false
        settingDidChange?(textView.text)
        let color = isValid(textField.text) ? Theme.tableView.rowText : Theme.general.destructiveRed
        textField.textColor = color
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        placeholderLabel.isHidden = textField.text.isEmpty == false
        settingDidChange?(textView.text)
    }
}
