/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client
import Foundation
import Shared
import Storage
import XCTest

open class MockTabQueue: TabQueue {
    open func addToQueue(_ tab: ShareItem) -> Success {
        return succeed()
    }

    open func getQueuedTabs() -> Deferred<Maybe<Cursor<ShareItem>>> {
        return deferMaybe(ArrayCursor<ShareItem>(data: []))
    }

    open func clearQueuedTabs() -> Success {
        return succeed()
    }
}

open class MockPanelDataObservers: PanelDataObservers {
    override init(profile: Client.Profile) {
        super.init(profile: profile)
        self.activityStream = MockActivityStreamDataObserver(profile: profile)
    }
}

open class MockActivityStreamDataObserver: DataObserver {
    public func refreshIfNeeded(forceTopSites topSites: Bool, completion: (() -> Void)?) {
    }

    public var profile: Client.Profile
    public weak var delegate: DataObserverDelegate?

    init(profile: Client.Profile) {
        self.profile = profile
    }
}

class MockFiles: FileAccessor {
    init() {
        let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        super.init(rootPath: (docPath as NSString).appendingPathComponent("testing"))
    }
}

open class MockProfile: Client.Profile {
    // Read/Writeable properties for mocking
    public var recommendations: HistoryRecommendations
    public var places: BrowserHistory & SyncableHistory & HistoryRecommendations
    public var files: FileAccessor
    public var history: BrowserHistory & SyncableHistory

    public lazy var panelDataObservers: PanelDataObservers = {
        return MockPanelDataObservers(profile: self)
    }()

    var db: BrowserDB

    fileprivate let name: String = "mockaccount"

    init(databasePrefix: String = "mock") {
        files = MockFiles()
        db = BrowserDB(filename: "\(databasePrefix).db", schema: BrowserSchema(), files: files)
        places = SQLiteHistory(db: self.db, prefs: MockProfilePrefs())
        recommendations = places
        history = places
    }

    public func localName() -> String {
        return name
    }

    public func _reopen() {
        isShutdown = false

        db.reopenIfClosed()
    }

    public func _shutdown() {
        isShutdown = true

        db.forceClose()
    }

    public var isShutdown: Bool = false

    lazy public var queue: TabQueue = {
        return MockTabQueue()
    }()

    lazy public var metadata: Metadata = {
        return SQLiteMetadata(db: self.db)
    }()

    lazy public var certStore: CertStore = {
        return CertStore()
    }()

    lazy public var bookmarks: BookmarksModelFactorySource & KeywordSearchSource  & LocalItemSource & ShareToDestination = {
        // Make sure the rest of our tables are initialized before we try to read them!
        // This expression is for side-effects only.
        let p = self.places

        return MergedSQLiteBookmarks(db: self.db)
    }()

    lazy public var searchEngines: SearchEngines = {
        return SearchEngines(prefs: self.prefs, files: self.files)
    }()

    lazy public var prefs: Prefs = {
        return MockProfilePrefs()
    }()

    lazy public var recentlyClosedTabs: ClosedTabsStore = {
        return ClosedTabsStore(prefs: self.prefs)
    }()

    public func cleanupHistoryIfNeeded() {}
}
