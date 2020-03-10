//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Storage
import Shared
import XCGLogger

private let log = Logger.browserLogger

private let BookmarkDetailFieldCellIdentifier = "BookmarkDetailFieldCellIdentifier"

private struct BookmarkDetailViewControllerUX {
    static let FieldRowHeight: CGFloat = 58
    static let IndentationWidth: CGFloat = 20
    static let MinIndentedContentWidth: CGFloat = 100
}

class BookmarkDetailViewControllerError: MaybeErrorType {
    public var description = "Unable to save BookmarkNode."
}

protocol BookmarkDetailViewControllerDelegate: class {
    func bookmardDetailViewDidCancel()
    func bookmardDetailViewDidSave()
}

class BookmarkDetailViewController: SiteTableViewController {
    enum BookmarkDetailSection: Int, CaseIterable {
        case fields
    }

    enum BookmarkDetailFieldsRow: Int {
        case title
        case url
    }

    weak var delegate: BookmarkDetailViewControllerDelegate?

    // Non-editable field(s) that all BookmarkNodes have.
    let bookmarkNodeGUID: GUID

    // Editable field(s) that only BookmarkItems and
    // BookmarkFolders have.
    var bookmarkItemOrFolderTitle: String?

    // Editable field(s) that only BookmarkItems have.
    var bookmarkItemURL: String?

    private var maxIndentationLevel: Int {
        return Int(floor((view.frame.width - BookmarkDetailViewControllerUX.MinIndentedContentWidth) / BookmarkDetailViewControllerUX.IndentationWidth))
    }

    init(profile: Profile, bookmarkNode: BookmarkNode) {
        self.bookmarkNodeGUID = bookmarkNode.guid
        super.init(profile: profile)

        self.tableView.accessibilityIdentifier = "Bookmark Detail"
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: BookmarkDetailFieldCellIdentifier)

        if let bookmarkItem = bookmarkNode as? BookmarkItem {
            self.bookmarkItemOrFolderTitle = bookmarkItem.title
            self.bookmarkItemURL = bookmarkItem.url

            self.title = Strings.Bookmarks.BookmarksEditBookmark
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel) { _ in
            self.delegate?.bookmardDetailViewDidCancel()
            self.navigationController?.dismiss(animated: true)
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save) { _ in
            self.save().uponQueue(.main) { _ in
                self.delegate?.bookmardDetailViewDidSave()
                self.navigationController?.dismiss(animated: true)
            }
        }

        updateSaveButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Focus the keyboard on the first text field.
        if let firstTextFieldCell = tableView.visibleCells.first(where: { $0 is TextFieldTableViewCell }) as? TextFieldTableViewCell {
            firstTextFieldCell.textField.becomeFirstResponder()
        }
    }

    override func applyTheme() {
        super.applyTheme()

        if let current = navigationController?.visibleViewController as? Themeable, current !== self {
            current.applyTheme()
        }

        self.tableView.backgroundColor = Theme.tableView.headerBackground
    }

    func updateSaveButton() {
        let url = URL(string: bookmarkItemURL ?? "")
        navigationItem.rightBarButtonItem?.isEnabled = url?.schemeIsValid == true && url?.host != nil
    }

    func save() -> Success {
        guard let title = self.bookmarkItemOrFolderTitle, let url = self.bookmarkItemURL else {
            return deferMaybe(BookmarkDetailViewControllerError())
        }
        return self.profile.bookmarks.modelFactory >>== { $0.updateByGUID(self.bookmarkNodeGUID, title: title, url: url) }
    }

    // MARK: UITableViewDataSource | UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return BookmarkDetailSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let bookmarkSection = BookmarkDetailSection(rawValue: section)!
        switch bookmarkSection {
        case .fields:
            return 2
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let bookmarkSection = BookmarkDetailSection(rawValue: indexPath.section)!
        switch bookmarkSection {
        case .fields:
            // Handle Title/URL editable field cells.
            guard let cell = tableView.dequeueReusableCell(withIdentifier: BookmarkDetailFieldCellIdentifier, for: indexPath) as? TextFieldTableViewCell else {
                return super.tableView(tableView, cellForRowAt: indexPath)
            }

            cell.delegate = self

            switch indexPath.row {
            case BookmarkDetailFieldsRow.title.rawValue:
                cell.titleLabel.text = Strings.Bookmarks.BookmarkDetailFieldTitle
                cell.textField.text = self.bookmarkItemOrFolderTitle
                cell.textField.autocapitalizationType = .sentences
                cell.textField.keyboardType = .default
                return cell
            case BookmarkDetailFieldsRow.url.rawValue:
                cell.titleLabel.text = Strings.Bookmarks.BookmarkDetailFieldURL
                cell.textField.text = self.bookmarkItemURL
                cell.textField.autocapitalizationType = .none
                cell.textField.keyboardType = .URL
                return cell
            default:
                return super.tableView(tableView, cellForRowAt: indexPath) // Should not happen.
            }
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let bookmarkSection = BookmarkDetailSection(rawValue: indexPath.section)!
        switch bookmarkSection {
        case .fields:
            return BookmarkDetailViewControllerUX.FieldRowHeight
        }
    }

}

extension BookmarkDetailViewController: TextFieldTableViewCellDelegate {
    func textFieldTableViewCell(_ textFieldTableViewCell: TextFieldTableViewCell, didChangeText text: String) {
        guard let indexPath = tableView.indexPath(for: textFieldTableViewCell) else {
            return
        }

        switch indexPath.row {
        case BookmarkDetailFieldsRow.title.rawValue:
            bookmarkItemOrFolderTitle = text
        case BookmarkDetailFieldsRow.url.rawValue:
            bookmarkItemURL = text
            updateSaveButton()
        default:
            log.warning("Received didChangeText: for a cell with an IndexPath that should not exist.")
        }
    }
}
