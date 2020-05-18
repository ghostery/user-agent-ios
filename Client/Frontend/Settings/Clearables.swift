/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import WebKit
import SDWebImage
import CoreSpotlight

private let log = Logger.browserLogger

// A base protocol for something that can be cleared.
protocol Clearable {
    func clear() -> Success
    var label: String { get }
}

class ClearableError: MaybeErrorType {
    fileprivate let msg: String
    init(msg: String) {
        self.msg = msg
    }

    var description: String { return msg }
}

// Clears our browsing history, including favicons and thumbnails.
class HistoryClearable: Clearable {
    let profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.BrowsingHistory
    }

    func clear() -> Success {

        // Treat desktop sites as part of browsing history.
        Tab.ChangeUserAgent.clear()

        return profile.history.clearHistory().bindQueue(.main) { success in
            SDImageCache.shared.clearDisk()
            SDImageCache.shared.clearMemory()
            self.profile.recentlyClosedTabs.clearTabs()
            CSSearchableIndex.default().deleteAllSearchableItems()
            NotificationCenter.default.post(name: .PrivateDataClearedHistory, object: nil)
            log.debug("HistoryClearable succeeded: \(success).")
            return Deferred(value: success)
        }
    }
}

struct ClearableErrorType: MaybeErrorType {
    let err: Error

    init(err: Error) {
        self.err = err
    }

    var description: String {
        return "Couldn't clear: \(err)."
    }
}

// Clear the web cache. Note, this has to close all open tabs in order to ensure the data
// cached in them isn't flushed to disk.
class CacheClearable: Clearable {
    let tabManager: TabManager
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.Cache
    }

    func clear() -> Success {
        let dataTypes = Set([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        MemoryReaderModeCache.sharedInstance.clear()
        DiskReaderModeCache.sharedInstance.clear()

        log.debug("CacheClearable succeeded.")
        return succeed()
    }
}

private func deleteLibraryFolderContents(_ folder: String) throws {
    let manager = FileManager.default
    let library = manager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    let dir = library.appendingPathComponent(folder)
    let contents = try manager.contentsOfDirectory(atPath: dir.path)
    for content in contents {
        do {
            try manager.removeItem(at: dir.appendingPathComponent(content))
        } catch where ((error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError)?.code == Int(EPERM) {
            // "Not permitted". We ignore this.
            log.debug("Couldn't delete some library contents.")
        }
    }
}

private func deleteLibraryFolder(_ folder: String) throws {
    let manager = FileManager.default
    let library = manager.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    let dir = library.appendingPathComponent(folder)
    try manager.removeItem(at: dir)
}

// Removes all app cache storage.
class SiteDataClearable: Clearable {
    let tabManager: TabManager
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.OfflineWebsiteData
    }

    func clear() -> Success {
        let dataTypes = Set([WKWebsiteDataTypeOfflineWebApplicationCache])
        WKWebsiteDataStore.default().removeData(ofTypes: dataTypes, modifiedSince: .distantPast, completionHandler: {})

        log.debug("SiteDataClearable succeeded.")
        return succeed()
    }
}

// Remove all cookies stored by the site. This includes localStorage, sessionStorage, and WebSQL/IndexedDB.
class CookiesClearable: Clearable {

    static let dataTypes = Set([WKWebsiteDataTypeCookies, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeWebSQLDatabases, WKWebsiteDataTypeIndexedDBDatabases])

    let tabManager: TabManager
    init(tabManager: TabManager) {
        self.tabManager = tabManager
    }

    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.Cookies
    }

    func clear() -> Success {
        WKWebsiteDataStore.default().removeData(ofTypes: CookiesClearable.dataTypes, modifiedSince: .distantPast, completionHandler: {})

        log.debug("CookiesClearable succeeded.")
        return succeed()
    }
}

class TrackingProtectionClearable: Clearable {
    //TO DO: re-using string because we are too late in cycle to change strings
    var label: String {
        return Strings.Settings.PrivacyDashboard.Title
    }

    func clear() -> Success {
        let result = Success()
        ContentBlocker.shared.clearAllowLists() {
            result.fill(Maybe(success: ()))
        }
        return result
    }
}

// Clears our downloaded files in the `~/Documents/Downloads` folder.
class DownloadedFilesClearable: Clearable {
    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.DownloadedFiles
    }

    func clear() -> Success {
        if let downloadsPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("Downloads"),
            let files = try? FileManager.default.contentsOfDirectory(at: downloadsPath, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }

        NotificationCenter.default.post(name: .PrivateDataClearedDownloadedFiles, object: nil)

        return succeed()
    }
}

// Clears privacy stats.
class PrivacyStatsClearable: Clearable {
    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.PrivacyStats
    }

    func clear() -> Success {
        let result = Success()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return result
        }
        appDelegate.insightsFeature.clearStats()
        return result
    }
}

// Removing search history.
class SearchHistoryClearable: Clearable {
    let profile: Profile
    init(profile: Profile) {
        self.profile = profile
    }

    var label: String {
        return Strings.Settings.Privacy.DataManagement.PrivateData.SearchHistory
    }

    func clear() -> Success {
        return self.profile.history.clearQueryLog().bindQueue(.main) { success in
            log.debug("SearchHistoryClearable succeeded: \(success).")
            return Deferred(value: success)
        }
    }
}
