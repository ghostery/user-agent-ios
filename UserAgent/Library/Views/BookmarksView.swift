//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared
import Storage
import UIKit

class BookmarksView: LibraryView {
    private let toolbarHeight: CGFloat

    // MARK: - UX constants.
    private struct BookmarksPanelUX {
        static let IconBorderWidth: CGFloat = 0.5
        static let IconBorderColor = UIColor.Grey30
        static let EmptyScreenItemWidth = 170
    }

    // MARK: - Properties
    var source: BookmarksModel?
    var parentFolders = [BookmarkFolder]()
    var bookmarkFolder: BookmarkFolder?
    var refreshControl: UIRefreshControl?

    private let BookmarkFolderCellIdentifier = "BookmarkFolderIdentifier"
    private let BookmarkSeparatorCellIdentifier = "BookmarkSeparatorIdentifier"
    private let BookmarkFolderHeaderViewIdentifier = "BookmarkFolderHeaderIdentifier"

    init(profile: Profile, toolbarHeight: CGFloat) {
        self.toolbarHeight = toolbarHeight
        super.init(profile: profile)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Initialization
    override func setup() {
        super.setup()
        self.tableView.contentInset.bottom = self.toolbarHeight
        self.tableView.accessibilityIdentifier = Strings.Bookmarks.Title
        self.tableView.addGestureRecognizer(self.longPressRecognizer)
        self.loadData()
    }

    override func applyTheme() {
        super.applyTheme()
    }

    // MARK: - Public API
    override func siteForIndexPath(_ indexPath: IndexPath) -> Site? {
        guard let source = source, let bookmark = source.current[indexPath.row] else { return nil }

        switch bookmark {
        case let item as BookmarkItem:
            return Site(url: item.url, title: item.title, bookmarked: true, guid: item.guid)
        case is BookmarkSeparator:
            return Site(url: "", title: "—", bookmarked: false)
        case is BookmarkFolder:
            return Site(url: "", title: "Folder", bookmarked: false)
        default:
            // This should never happen, said the bishop to the actress
            break
        }

        return nil
    }

    override var deleteActionTitle: String {
        return Strings.HomePanel.ContextMenu.RemoveBookmark
    }

    override func removeSiteForURLAtIndexPath(_ indexPath: IndexPath) {
        guard let source = source, let bookmark = source.current[indexPath.row] else {
            print("Source not set, aborting.")
            return
        }

        // Don't delete folders, we don't create them anyway
        guard !(bookmark is BookmarkFolder) else { return }

        // Block to do this -- this is UI code.
        guard let factory = source.modelFactory.value.successValue else {
            print("Couldn't get model factory. This is unexpected.")
            self.onModelFailure(DatabaseError(description: "Unable to get factory."))
            return
        }

        let specificFactory = factory.factoryForIndex(indexPath.row, inFolder: source.current)
        if let err = specificFactory.removeByGUID(bookmark.guid).value.failureValue {
            print("Failed to remove \(bookmark.guid).")
            self.onModelFailure(err)
            return
        }

        self.tableView.beginUpdates()
        self.source = source.removeGUIDFromCurrent(bookmark.guid)
        self.tableView.deleteRows(at: [indexPath], with: .left)
        self.tableView.endUpdates()
        self.updateEmptyPanelState()
    }

    override func pinToTopSites(_ site: Site) {
        _ = self.profile.history.addPinnedTopSite(site).value
    }

    override func reloadData() {
        self.source?.reloadData().upon(onModelFetched)
    }

    override func emptyMessage() -> String? {
        return Strings.Bookmarks.PanelEmptyStateTitle
    }

    override func additionalContextMenuActions(indexPath: IndexPath) -> [PhotonActionSheetItem] {
        let editBookmark = PhotonActionSheetItem(title: Strings.Bookmarks.BookmarksEditBookmark, iconString: "action_edit", handler: { action in
            guard let source = self.source, let bookmark = source.current[indexPath.row] else {
                print("Source not set, aborting.")
                return
            }
            self.delegate?.library(wantsToEdit: bookmark)
        })
        return [editBookmark]
    }

    func loadData() {
        // If we've not already set a source for this panel, fetch a new model from
        // the root; otherwise, just use the existing source to select a folder.
        guard let source = self.source else {
            // Get all the bookmarks split by folders
            if let bookmarkFolder = bookmarkFolder {
                profile.bookmarks.modelFactory >>== { $0.modelForFolder(bookmarkFolder).upon(self.onModelFetched) }
            } else {
                profile.bookmarks.modelFactory >>== { $0.modelForRoot().upon(self.onModelFetched) }
            }
            return
        }

        if let bookmarkFolder = bookmarkFolder {
            source.selectFolder(bookmarkFolder).upon(onModelFetched)
        } else {
            source.selectFolder(BookmarkRoots.MobileFolderGUID).upon(onModelFetched)
        }
    }

    private func onModelFetched(_ result: Maybe<BookmarksModel>) {
        guard let model = result.successValue else {
            self.onModelFailure(result.failureValue as Any)
            return
        }
        self.onNewModel(model)
    }

    private func onNewModel(_ model: BookmarksModel) {
        if Thread.current.isMainThread {
            self.source = model
            self.tableView.reloadData()
            return
        }

        DispatchQueue.main.async {
            self.source = model
            self.tableView.reloadData()
            self.updateEmptyPanelState()
        }
    }

    private func onModelFailure(_ e: Any) {
        print("Error: failed to get data: \(e)")
    }

}

// MARK: - Private API
private extension BookmarksView {

    private func updateEmptyPanelState() {
        // swiftlint:disable:next empty_count
        if source?.current.count == 0 && source?.current.guid == BookmarkRoots.MobileFolderGUID {
            if self.emptyStateOverlayView.superview == nil {
                self.tableView.tableFooterView = self.emptyStateOverlayView
            }
        } else {
            self.tableView.alwaysBounceVertical = true
            self.tableView.tableFooterView = UIView(frame: .zero)
        }
    }

}

// MARK: - Table View Data Source
extension BookmarksView {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return source?.current.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = .none
        return self.configureSite(cell, for: indexPath)
    }

    private func configureSite(_ cell: UITableViewCell, for indexPath: IndexPath) -> UITableViewCell {
        if let site = self.siteForIndexPath(indexPath), let cell = cell as? TwoLineTableViewCell {
            cell.setLines(site.title, detailText: site.url)
            cell.imageView?.layer.borderColor = BookmarksPanelUX.IconBorderColor.cgColor
            cell.imageView?.layer.borderWidth = BookmarksPanelUX.IconBorderWidth
            cell.iconView.getIcon(site: site)
        }
        return cell
    }

}

// MARK: - Table View Delegate
extension BookmarksView {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        if let site = self.siteForIndexPath(indexPath), let url = URL(string: site.url) {
            self.delegate?.library(didSelectURL: url, visitType: .typed)
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let title = Strings.General.DeleteString
        let delete = UITableViewRowAction(style: .default, title: title, handler: { (action, indexPath) in
            self.removeSiteForURLAtIndexPath(indexPath)
        })
        return [delete]
    }

}
