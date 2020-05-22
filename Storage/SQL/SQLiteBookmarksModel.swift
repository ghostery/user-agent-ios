/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

private let log = Logger.syncLogger

public enum Direction {
    case buffer
    case local

    var structureTable: String {
        switch self {
        case .local:
            return TableBookmarksLocalStructure
        case .buffer:
            return TableBookmarksBufferStructure
        }
    }

    var valueTable: String {
        switch self {
        case .local:
            return TableBookmarksLocal
        case .buffer:
            return TableBookmarksBuffer
        }
    }

    var valueView: String {
        switch self {
        case .local:
            return ViewBookmarksLocalOnMirror
        case .buffer:
            return ViewBookmarksBufferWithDeletionsOnMirror
        }
    }

    var structureView: String {
        switch self {
        case .local:
            return ViewBookmarksLocalStructureOnMirror
        case .buffer:
            return ViewBookmarksBufferStructureOnMirror
        }
    }
}

public protocol KeywordSearchSource {
    func getURLForKeywordSearch(_ keyword: String) -> Deferred<Maybe<String>>
}

open class SQLiteBookmarksModelFactory: BookmarksModelFactory {
    fileprivate let bookmarks: SQLiteBookmarks
    fileprivate let direction: Direction

    public init(bookmarks: SQLiteBookmarks, direction: Direction) {
        self.bookmarks = bookmarks
        self.direction = direction
    }

    public func factoryForIndex(_ index: Int, inFolder folder: BookmarkFolder) -> BookmarksModelFactory {
        return self
    }

    fileprivate func withDifferentDirection(_ direction: Direction) -> SQLiteBookmarksModelFactory {
        if self.direction == direction {
            return self
        }
        return SQLiteBookmarksModelFactory(bookmarks: self.bookmarks, direction: direction)
    }

    fileprivate func getChildrenWithParent(_ parentGUID: GUID, excludingGUIDs: [GUID]?=nil, includeIcon: Bool) -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        return self.bookmarks.getChildrenWithParent(parentGUID, direction: self.direction, excludingGUIDs: excludingGUIDs, includeIcon: includeIcon)
    }

    fileprivate func getRootChildren() -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        return self.getChildrenWithParent(BookmarkRoots.RootGUID, excludingGUIDs: [BookmarkRoots.RootGUID], includeIcon: true)
    }

    fileprivate func getChildren(_ guid: String) -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        return self.getChildrenWithParent(guid, includeIcon: true)
    }

    func folderForGUID(_ guid: GUID, title: String) -> Deferred<Maybe<BookmarkFolder>> {
        return self.getChildren(guid)
            >>== { cursor in

            if cursor.status == .failure {
                return deferMaybe(DatabaseError(description: "Couldn't get children: \(cursor.statusMessage)."))
            }

            return deferMaybe(SQLiteBookmarkFolder(guid: guid, title: title, children: cursor))
        }
    }

    fileprivate func modelWithRoot(_ root: BookmarkFolder) -> Deferred<Maybe<BookmarksModel>> {
        return deferMaybe(BookmarksModel(modelFactory: self, root: root))
    }

    open func modelForFolder(_ guid: String, title: String) -> Deferred<Maybe<BookmarksModel>> {
        if guid == BookmarkRoots.MobileFolderGUID {
            return self.modelForRoot()
        }

        let outputTitle = titleForSpecialGUID(guid) ?? title
        return self.folderForGUID(guid, title: outputTitle)
          >>== self.modelWithRoot
    }

    open func modelForFolder(_ folder: BookmarkFolder) -> Deferred<Maybe<BookmarksModel>> {
        return self.modelForFolder(folder.guid, title: folder.title)
    }

    open func modelForFolder(_ guid: String) -> Deferred<Maybe<BookmarksModel>> {
        return self.modelForFolder(guid, title: "")
    }

    open func modelForRoot() -> Deferred<Maybe<BookmarksModel>> {
        log.debug("Getting model for root.")
        let getFolder = self.folderForGUID(BookmarkRoots.MobileFolderGUID, title: Strings.BookmarksFolderTitleMobile)
        return getFolder >>== self.modelWithRoot
    }

    open var nullModel: BookmarksModel {
        let children = Cursor<BookmarkNode>(status: .failure, msg: "Null model")
        let folder = SQLiteBookmarkFolder(guid: "Null", title: "Null", children: children)
        return BookmarksModel(modelFactory: self, root: folder)
    }

    open func isBookmarked(_ url: String) -> Deferred<Maybe<Bool>> {
        return self.bookmarks.isBookmarked(url, direction: self.direction)
    }

    open func removeByURL(_ url: String) -> Success {
        if self.direction == Direction.buffer {
            return deferMaybe(DatabaseError(description: "Refusing to remove URL from buffer in model."))
        }

        // Find all of the records for the provided URL. Don't bother with
        // any that are already deleted!
        return self.bookmarks.nonDeletedGUIDsForURL(url)
          >>== self.bookmarks.removeGUIDs
    }

    open func removeByGUID(_ guid: GUID) -> Success {
        if self.direction == Direction.buffer {
            return deferMaybe(DatabaseError(description: "Refusing to remove GUID from buffer in model."))
        }

        log.debug("removeByGUID: \(guid)")
        return self.bookmarks.removeGUIDs([guid])
    }

    open func updateByGUID(_ guid: GUID, title: String, url: String) -> Success {
        if self.direction == Direction.buffer {
            return deferMaybe(DatabaseError(description: "Refusing to update GUID from buffer in model."))
        }

        log.debug("updateByGUID: \(guid) title: \(title) url: \(url)")
        return self.bookmarks.updateGUID(guid, title: title, url: url)
    }

    open func clearBookmarks() -> Success {
        return self.bookmarks.clearBookmarks()
    }
}

class EditableBufferBookmarksSQLiteBookmarksModelFactory: SQLiteBookmarksModelFactory {
    override func getChildrenWithParent(_ parentGUID: GUID, excludingGUIDs: [GUID]?, includeIcon: Bool) -> Deferred<Maybe<Cursor<BookmarkNode>>> {
        if parentGUID == BookmarkRoots.MobileFolderGUID {
            return self.bookmarks.getChildrenWithParent(parentGUID, direction: self.direction, excludingGUIDs: excludingGUIDs, includeIcon: includeIcon, factory: BookmarkFactory.editableItemsFactory)
        }
        return super.getChildrenWithParent(parentGUID, excludingGUIDs: excludingGUIDs, includeIcon: includeIcon)
    }

    override func removeByGUID(_ guid: GUID) -> Success {
        log.debug("Removing \(guid) from buffer.")
        return self.bookmarks.markBufferBookmarkAsDeleted(guid)
    }
}

private func isEditableExpression(_ direction: Direction) -> String {
    if direction == .buffer {
        return "0"
    }

    let sql = """
        SELECT EXISTS(
            SELECT
                EXISTS(SELECT 1 FROM bookmarksBuffer) AS hasBuffer,
                EXISTS(SELECT 1 FROM bookmarksMirror) AS hasMirror
            WHERE hasBuffer IS 0 OR hasMirror IS 0
        )
        """

    return sql
}

extension SQLiteBookmarks {

    fileprivate func getRecordsWithGUIDs(_ guids: [GUID], direction: Direction, includeIcon: Bool) -> Deferred<Maybe<Cursor<BookmarkNode>>> {

        let args: Args = guids
        let varlist = BrowserDB.varlist(args.count)
        let values = """
            SELECT -1 AS id, guid, type, date_added, is_deleted, parentid, parentName, feedUri, pos, title, bmkUri, siteUri, folderName, faviconID, (\(isEditableExpression(direction))) AS isEditable
            FROM \(direction.valueView)
            WHERE guid IN \(varlist) AND NOT is_deleted
            """

        let withIcon = """
            SELECT bookmarks.id AS id, bookmarks.guid AS guid, bookmarks.type AS type,
                   bookmarks.date_added AS date_added,
                   bookmarks.is_deleted AS is_deleted,
                   bookmarks.parentid AS parentid, bookmarks.parentName AS parentName,
                   bookmarks.feedUri AS feedUri, bookmarks.pos AS pos, title AS title,
                   bookmarks.bmkUri AS bmkUri, bookmarks.siteUri AS siteUri,
                   bookmarks.folderName AS folderName,
                   bookmarks.isEditable AS isEditable,
                   favicons.url AS iconURL, favicons.date AS iconDate, favicons.type AS iconType
            FROM (\(values)) AS bookmarks LEFT OUTER JOIN favicons ON
                bookmarks.faviconID = favicons.id
            """

        let sql = (includeIcon ? withIcon : values) + " ORDER BY title ASC"
        return self.db.runQuery(sql, args: args, factory: BookmarkFactory.factory)
    }

    /**
     * Return the children of the provided parent.
     * Rows are ordered by positional index.
     * This method is aware of is_overridden and deletion, using local override structure by preference.
     * Note that a folder can be empty locally; we thus use the flag rather than looking at the structure itself.
     */
    func getChildrenWithParent(_ parentGUID: GUID, direction: Direction, excludingGUIDs: [GUID]?=nil, includeIcon: Bool, factory: @escaping (SDRow) -> BookmarkNode = BookmarkFactory.factory) -> Deferred<Maybe<Cursor<BookmarkNode>>> {

        precondition((excludingGUIDs ?? []).count < 100, "Sanity bound for the number of GUIDs we can exclude.")

        let valueView = direction.valueView
        let structureView = direction.structureView

        let structure =
            "SELECT parent, child AS guid, idx FROM \(structureView) WHERE parent = ?"

        let values =
            "SELECT -1 AS id, guid, type, date_added, is_deleted, parentid, parentName, feedUri, pos, title, bmkUri, siteUri, folderName, faviconID, (\(isEditableExpression(direction))) AS isEditable FROM \(valueView)"

        // We exclude queries and dynamic containers, because we can't
        // usefully display them.
        let typeQuery = BookmarkNodeType.query.rawValue
        let typeDynamic = BookmarkNodeType.dynamicContainer.rawValue
        let typeFilter = " vals.type NOT IN (\(typeQuery), \(typeDynamic))"

        let args: Args
        let exclusion: String
        if let excludingGUIDs = excludingGUIDs {
            args = ([parentGUID] + excludingGUIDs).map { $0 }
            exclusion = "\(typeFilter) AND vals.guid NOT IN " + BrowserDB.varlist(excludingGUIDs.count)
        } else {
            args = [parentGUID]
            exclusion = typeFilter
        }

        let fleshed = """
            SELECT vals.id AS id, vals.guid AS guid, vals.type AS type, vals.date_added AS date_added,
                vals.is_deleted AS is_deleted, vals.parentid AS parentid, vals.parentName AS parentName,
                vals.feedUri AS feedUri, vals.siteUri AS siteUri, vals.pos AS pos, vals.title AS title,
                vals.bmkUri AS bmkUri, vals.folderName AS folderName, vals.faviconID AS faviconID,
                vals.isEditable AS isEditable, structure.idx AS idx, structure.parent AS _parent
            FROM (\(structure)) AS structure JOIN (\(values)) AS vals ON
                vals.guid = structure.guid
            WHERE \(exclusion)
            """

        let withIcon = """
            SELECT bookmarks.id AS id, bookmarks.guid AS guid, bookmarks.type AS type,
                bookmarks.date_added AS date_added,
                bookmarks.is_deleted AS is_deleted,
                bookmarks.parentid AS parentid, bookmarks.parentName AS parentName,
                bookmarks.feedUri AS feedUri, bookmarks.siteUri AS siteUri,
                bookmarks.pos AS pos, title AS title,
                bookmarks.bmkUri AS bmkUri, bookmarks.folderName AS folderName,
                bookmarks.idx AS idx, bookmarks._parent AS _parent,
                bookmarks.isEditable AS isEditable,
                favicons.url AS iconURL, favicons.date AS iconDate, favicons.type AS iconType
            FROM (\(fleshed)) AS bookmarks LEFT OUTER JOIN favicons ON
                bookmarks.faviconID = favicons.id
            """

        let sql = (includeIcon ? withIcon : fleshed) + " ORDER BY idx ASC"
        return self.db.runQuery(sql, args: args, factory: factory)
    }

    public func clearBookmarks() -> Success {
        return self.db.run([
            ("DELETE FROM bookmarksLocal WHERE parentid IS NOT ?", [BookmarkRoots.RootGUID]),
            self.favicons.getCleanupFaviconsQuery(),
        ])
    }

    public func updateGUID(_ guid: GUID, title: String, url: String) -> Success {
        if url.lengthOfBytes(using: .utf8) > AppConstants.DB_URL_LENGTH_MAX {
            return deferMaybe(BookmarkURLTooLargeError())
        }
        let title = title.truncateToUTF8ByteCount(AppConstants.DB_TITLE_LENGTH_MAX)
        return self.db.run([
            ("UPDATE bookmarksLocal SET title = ?, bmkUri = ? WHERE guid = ?", [title, url, guid]),
        ])
    }

    public func removeGUIDs(_ guids: [GUID]) -> Success {
        log.debug("removeGUIDs: \(guids)")

        // Override any parents that aren't already overridden. We're about to remove some
        // of their children.
        return self.overrideParentsOfGUIDs(guids)

        // Find, recursively, any children of the provided GUIDs. This will only be the case
        // if you specify folders. This is a special case because we're removing *all*
        // children, so we don't need to do the reindexing dance.
           >>> { self.deleteChildrenOfGUIDs(guids) }

        // Override any records that aren't already overridden.
           >>> { self.overrideGUIDs(guids) }

        // Then delete the already-overridden records. We do this one at a time in order
        // to get indices correct in edge cases. (We do bulk-delete their children
        // one layer at a time, at least.)
           >>> { walk(guids, f: self.removeLocalByGUID) }
    }

    fileprivate func nonDeletedGUIDsForURL(_ url: String) -> Deferred<Maybe<([GUID])>> {
        let sql = "SELECT DISTINCT guid FROM view_bookmarksLocal_on_mirror WHERE bmkUri = ? AND is_deleted = 0"
        let args: Args = [url]

        return self.db.runQuery(sql, args: args, factory: { $0[0] as! GUID }) >>== { guids in
            return deferMaybe(guids.asArray())
        }
    }

    fileprivate func overrideParentsOfGUIDs(_ guids: [GUID]) -> Success {
        log.debug("Overriding parents of \(guids).")

        // TO DO : Yes, this can be done in one go.
        let getParentsSQL =
            "SELECT DISTINCT parent FROM view_bookmarksLocalStructure_on_mirror WHERE child IN \(BrowserDB.varlist(guids.count)) AND is_overridden = 0"
        let getParentsArgs: Args = guids

        return self.db.runQuery(getParentsSQL, args: getParentsArgs, factory: { $0[0] as! GUID })
            >>== { parentsCursor in
                let parents = parentsCursor.asArray()
                log.debug("Overriding parents: \(parents).")
                let (sql, args) = self.getSQLToOverrideFolders(parents, atModifiedTime: Date.now())
                return self.db.run(sql.map { ($0, args) })
        }
    }

    fileprivate func overrideGUIDs(_ guids: [GUID]) -> Success {
        log.debug("Overriding GUIDs: \(guids).")
        let (sql, args) = self.getSQLToOverrideNonFolders(guids, atModifiedTime: Date.now())
        return self.db.run(sql.map { ($0, args) })
    }

    // Recursive.
    fileprivate func deleteChildrenOfGUIDs(_ guids: [GUID]) -> Success {
        if guids.isEmpty {
            return succeed()
        }

        precondition(BookmarkRoots.All.intersection(guids).isEmpty, "You can't even touch the roots for removal.")

        log.debug("Deleting children of \(guids).")

        let topArgs: Args = guids
        let topVarlist = BrowserDB.varlist(topArgs.count)
        let query = "SELECT child FROM view_bookmarksLocalStructure_on_mirror WHERE parent IN \(topVarlist)"

        // We're deleting whole folders, so we don't need to worry about indices.
        return self.db.runQuery(query, args: topArgs, factory: { $0[0] as! GUID })
            >>== { children in
                let childGUIDs = children.asArray()
                log.debug("… children of \(guids) are \(childGUIDs).")

                if childGUIDs.isEmpty {
                    log.debug("No children; nothing more to do.")
                    return succeed()
                }

                let childArgs: Args = childGUIDs
                let childVarlist = BrowserDB.varlist(childArgs.count)

                // Mirror the children if they're not already.
                // We use the non-folder version of this query because we're recursively
                // destroying structure right after this, so there's no point cloning the
                // mirror structure.
                // Then delete the children's children, so we don't leave orphans. This is
                // recursive, so by the time this succeeds we know that all of these records
                // have no remaining children.
                let (overrideSQL, overrideArgs) = self.getSQLToOverrideNonFolders(childGUIDs, atModifiedTime: Date.now())

                return self.deleteChildrenOfGUIDs(childGUIDs)
                    >>> { self.db.run(overrideSQL.map { ($0, overrideArgs) }) }
                    >>> {
                        // Delete the children themselves.

                        // Remove each child from structure. We use the top list to save effort.
                        let deleteStructure =
                            "DELETE FROM bookmarksLocalStructure WHERE parent IN \(topVarlist)"

                        // If a bookmark is New, delete it outright.
                        let deleteNew =
                            "DELETE FROM bookmarksLocal WHERE guid IN \(childVarlist) AND sync_status = 2"

                        // If a bookmark is Changed, mark it as deleted and bump its modified time.
                        let markChanged = self.getMarkDeletedSQLWithWhereFragment("guid IN \(childVarlist)")

                        return self.db.run([
                            (deleteStructure, topArgs),
                            (deleteNew, childArgs),
                            (markChanged, childArgs),
                        ])
                }
        }
    }

    fileprivate func getMarkDeletedSQLWithWhereFragment(_ whereFragment: String) -> String {
        let sql = """
            UPDATE bookmarksLocal SET
                date_added = NULL,
                is_deleted = 1,
                local_modified = \(Date.now()),
                bmkUri = NULL,
                feedUri = NULL,
                siteUri = NULL,
                pos = NULL,
                title = NULL,
                tags = NULL,
                keyword = NULL,
                description = NULL,
                parentid = NULL,
                parentName = NULL,
                folderName = NULL,
                queryId = NULL
            WHERE \(whereFragment) AND sync_status = 1
            """

        return sql
    }
    /**
     * This depends on the record's parent already being overridden if necessary.
     */
    fileprivate func removeLocalByGUID(_ guid: GUID) -> Success {
        let args: Args = [guid]

        // Find the index we're currently occupying.
        let previousIndexSubquery = "SELECT idx FROM bookmarksLocalStructure WHERE child = ?"

        // Fix up the indices of subsequent siblings.
        let updateIndices =
            "UPDATE bookmarksLocalStructure SET idx = (idx - 1) WHERE idx > (\(previousIndexSubquery))"

        // If the bookmark is New, delete it outright.
        let deleteNew =
            "DELETE FROM bookmarksLocal WHERE guid = ? AND sync_status = 2"

        // If the bookmark is Changed, mark it as deleted and bump its modified time.
        let markChanged = self.getMarkDeletedSQLWithWhereFragment("guid = ?")

        // Its parent must be either New or Changed, so we don't need to re-mirror it.
        // TO DO : bump the parent's modified time, because the child list changed?

        // Now delete from structure.
        let deleteStructure = "DELETE FROM bookmarksLocalStructure WHERE child = ?"

        return self.db.run([
            (updateIndices, args),
            (deleteNew, args),
            (markChanged, args),
            (deleteStructure, args),
        ])
    }

    fileprivate func markBufferBookmarkAsDeleted(_ guid: GUID) -> Success {
        let insertInPendingDeletions =
            "INSERT OR IGNORE INTO pending_deletions (id) VALUES (?)"
        let args: Args = [guid]
        return self.db.run(insertInPendingDeletions, withArgs: args)
    }
}

class SQLiteBookmarkFolder: BookmarkFolder {
    fileprivate let cursor: Cursor<BookmarkNode>
    override var count: Int {
        return cursor.count
    }

    override subscript(index: Int) -> BookmarkNode {
        let bookmark = cursor[index]
        return bookmark! as BookmarkNode
    }

    init(guid: String, title: String, children: Cursor<BookmarkNode>) {
        self.cursor = children
        super.init(guid: guid, title: title)
    }

    override func removeItemWithGUID(_ guid: GUID) -> BookmarkFolder? {
        let without = cursor.asArray().filter { $0.guid != guid }
        return MemoryBookmarkFolder(guid: self.guid, title: self.title, children: without)
    }
}

class BookmarkFactory {
    fileprivate class func addIcon(_ bookmark: BookmarkNode, row: SDRow) {
        // TO DO : share this logic with SQLiteHistory.
        if let faviconURL = row["iconURL"] as? String,
           let date = row["iconDate"] as? Double {
                bookmark.favicon = Favicon(url: faviconURL,
                                           date: Date(timeIntervalSince1970: date))
        }
    }

    fileprivate class func livemarkFactory(_ row: SDRow) -> BookmarkItem {
        let id = row["id"] as? Int
        let guid = row["guid"] as! String
        let url = row["siteUri"] as! String
        let title = row["title"] as? String ?? "Livemark"
        let isEditable = row.getBoolean("isEditable")           // Defaults to false.
        let bookmark = BookmarkItem(guid: guid, title: title, url: url, isEditable: isEditable)
        bookmark.id = id
        BookmarkFactory.addIcon(bookmark, row: row)
        return bookmark
    }

    // We ignore queries altogether inside the model factory.
    fileprivate class func queryFactory(_ row: SDRow) -> BookmarkItem {
        log.warning("Creating a BookmarkItem from a query. This is almost certainly unexpected.")
        let id = row["id"] as? Int
        let guid = row["guid"] as! String
        let title = row["title"] as? String ?? SQLiteBookmarks.defaultItemTitle
        let isEditable = row.getBoolean("isEditable")           // Defaults to false.
        let bookmark = BookmarkItem(guid: guid, title: title, url: "about:blank", isEditable: isEditable)
        bookmark.id = id
        BookmarkFactory.addIcon(bookmark, row: row)
        return bookmark
    }

    fileprivate class func separatorFactory(_ row: SDRow) -> BookmarkSeparator {
        let id = row["id"] as? Int
        let guid = row["guid"] as! String
        let separator = BookmarkSeparator(guid: guid)
        separator.id = id
        return separator
    }

    fileprivate class func itemRowFactory(_ row: SDRow, forceEditable: Bool = false) -> BookmarkItem {
        let id = row["id"] as? Int
        let guid = row["guid"] as! String
        let url = row["bmkUri"] as! String
        let title = row["title"] as? String ?? url
        let isEditable = forceEditable || row.getBoolean("isEditable")           // Defaults to false.
        let bookmark = BookmarkItem(guid: guid, title: title, url: url, isEditable: isEditable)
        bookmark.id = id
        BookmarkFactory.addIcon(bookmark, row: row)
        return bookmark
    }

    fileprivate class func itemFactory(_ row: SDRow) -> BookmarkItem {
        return BookmarkFactory.itemRowFactory(row, forceEditable: false)
    }

    fileprivate class func folderFactory(_ row: SDRow) -> BookmarkFolder {
        let id = row["id"] as? Int
        let guid = row["guid"] as! String
        let isEditable = row.getBoolean("isEditable")           // Defaults to false.
        let title = titleForSpecialGUID(guid) ??
                    row["title"] as? String ??
                    SQLiteBookmarks.defaultFolderTitle

        let folder = BookmarkFolder(guid: guid, title: title, isEditable: isEditable)
        folder.id = id
        BookmarkFactory.addIcon(folder, row: row)
        return folder
    }

    class func factory(_ row: SDRow) -> BookmarkNode {
        return BookmarkFactory.rowFactory(row, forceEditable: false)
    }

    class func editableItemsFactory(_ row: SDRow) -> BookmarkNode {
        return BookmarkFactory.rowFactory(row, forceEditable: true)
    }

    class func rowFactory(_ row: SDRow, forceEditable: Bool = false) -> BookmarkNode {
        if let typeCode = row["type"] as? Int, let type = BookmarkNodeType(rawValue: typeCode) {
            switch type {
            case .bookmark:
                return itemRowFactory(row, forceEditable: forceEditable)
            // dynamicContainer should never be hit: we exclude dynamic containers from our models.
            case .dynamicContainer, .folder:
                return folderFactory(row)
            case .separator:
                return separatorFactory(row)
            case .livemark:
                return livemarkFactory(row)
            case .query:
                // This should never be hit: we exclude queries from our models.
                return queryFactory(row)
            }
        }
        assert(false, "Invalid bookmark data.")
        return itemFactory(row)     // This will fail, but it keeps the compiler happy.
    }

    // N.B., doesn't include children!
    class func mirrorItemFactory(_ row: SDRow) -> BookmarkMirrorItem {
        // TO DO
        // let id = row["id"] as! Int

        let guid = row["guid"] as! GUID
        let typeCode = row["type"] as! Int
        let is_deleted = row.getBoolean("is_deleted")
        let parentid = row["parentid"] as? GUID
        let parentName = row["parentName"] as? String
        let feedUri = row["feedUri"] as? String
        let siteUri = row["siteUri"] as? String
        let pos = row["pos"] as? Int
        let title = row["title"] as? String
        let description = row["description"] as? String
        let bmkUri = row["bmkUri"] as? String
        let tags = row["tags"] as? String
        let keyword = row["keyword"] as? String
        let folderName = row["folderName"] as? String
        let queryId = row["queryId"] as? String
        let date_added = row.getTimestamp("date_added")

        // Local and mirror only.
        let faviconID = row["faviconID"] as? Int

        // Local only.
        let local_modified = row.getTimestamp("local_modified")

        // Mirror and buffer.
        let server_modified = row.getTimestamp("server_modified")
        let hasDupe = row.getBoolean("hasDupe")

        // Mirror only. TO DO
        //let is_overridden = row.getBoolean("is_overridden")

        // Use the struct initializer directly. Yes, this doesn't validate as strongly as
        // using the static constructors, but it'll be as valid as the contents of the DB.
        let type = BookmarkNodeType(rawValue: typeCode)!

        // This one might really be missing (it's local-only), so do this the hard way.
        let syncStatus: Int? = nil
        let item = BookmarkMirrorItem(guid: guid, type: type, dateAdded: date_added, serverModified: server_modified ?? 0,
                                      isDeleted: is_deleted, hasDupe: hasDupe, parentID: parentid, parentName: parentName,
                                      feedURI: feedUri, siteURI: siteUri,
                                      pos: pos,
                                      title: title, description: description,
                                      bookmarkURI: bmkUri, tags: tags, keyword: keyword,
                                      folderName: folderName, queryID: queryId,
                                      children: nil,
                                      faviconID: faviconID, localModified: local_modified,
                                      syncStatus: syncStatus)
        return item
    }
}

extension SQLiteBookmarks: SearchableBookmarks {
    public func bookmarksByURL(_ url: URL) -> Deferred<Maybe<Cursor<BookmarkItem>>> {
        let inner = """
            SELECT id, type, date_added, guid, bmkUri, title, faviconID
            FROM bookmarksLocal
            WHERE
                type = \(BookmarkNodeType.bookmark.rawValue) AND
                is_deleted IS NOT 1 AND
                bmkUri = ?
            UNION ALL
            SELECT id, type, date_added, guid, bmkUri, title, faviconID
            FROM bookmarksMirror
            WHERE
                type = \(BookmarkNodeType.bookmark.rawValue) AND
                is_overridden IS NOT 1 AND
                is_deleted IS NOT 1 AND
                bmkUri = ?
            """

        let sql = """
            SELECT bookmarks.id AS id, bookmarks.type AS type, bookmarks.date_added AS date_added, guid, bookmarks.bmkUri AS bmkUri, title, favicons.url AS iconURL, favicons.date AS iconDate, favicons.type AS iconType
            FROM (\(inner)) AS bookmarks LEFT OUTER JOIN favicons ON
                bookmarks.faviconID = favicons.id
            """

        let u = url.absoluteString
        let args: Args = [u, u]
        return db.runQuery(sql, args: args, factory: BookmarkFactory.itemFactory)
    }
}

extension SQLiteBookmarks {
    // We're in sync (even partially) if the mirror is non-empty.
    // We can show fallback desktop bookmarks if the mirror is empty and the buffer contains
    // children of the roots.
    func hasOnlyUnmergedRemoteBookmarks() -> Deferred<Maybe<Bool>> {
        let parents: Args = [
            BookmarkRoots.MenuFolderGUID,
            BookmarkRoots.ToolbarFolderGUID,
            BookmarkRoots.UnfiledFolderGUID,
            BookmarkRoots.MobileFolderGUID,
        ]
        let sql = "SELECT NOT EXISTS(SELECT 1 FROM bookmarksMirror) AND EXISTS(SELECT 1 FROM bookmarksBufferStructure WHERE parent IN (?, ?, ?, ?))"
        return self.db.runQuery(sql, args: parents, factory: { $0[0] as! Int == 1 })
            >>== { row in
                guard row.status == .success,
                    let result = row[0] else {
                        // if the query did not succeed, we should return false so that we can use local bookmarks
                        return deferMaybe(false)
                }
                return deferMaybe(result)
        }
    }
}

open class MergedSQLiteBookmarks: BookmarksModelFactorySource, KeywordSearchSource {
    let local: SQLiteBookmarks

    // Figuring out our factory can require hitting the DB, so this is async.
    // Note that we check *every time* -- we don't want to get stuck in a dead
    // end when you might sync soon.
    open var modelFactory: Deferred<Maybe<BookmarksModelFactory>> {
        return self.local.modelFactory
    }

    public init(db: BrowserDB) {
        self.local = SQLiteBookmarks(db: db)
    }

    open func getURLForKeywordSearch(_ keyword: String) -> Deferred<Maybe<String>> {
        return self.local.getURLForKeywordSearch(keyword)
    }
}
