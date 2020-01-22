/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client
import Shared
import Storage
import UIKit
import WebKit

import XCTest

class TabManagerStoreTests: XCTestCase {
    let profile = TabManagerMockProfile()
    var manager: TabManager!
    let configuration = WKWebViewConfiguration()

    override func setUp() {
        super.setUp()

        manager = TabManager(profile: profile, imageStore: nil)
        configuration.processPool = WKProcessPool()

        if UIDevice.current.userInterfaceIdiom == .pad {
            // BVC.viewWillAppear() calls restoreTabs() which interferes with these tests. (On iPhone, ClientTests never dismiss the intro screen, on iPad the intro is a popover on the BVC).
            // Wait for this to happen (UIView.window only gets assigned after viewWillAppear()), then begin testing.
            let bvc = (UIApplication.shared.delegate as! AppDelegate).browserViewController
            let predicate = XCTNSPredicateExpectation(predicate: NSPredicate(format: "view.window != nil"), object: bvc)
            wait(for: [predicate], timeout: 20)
        }

        manager.testClearArchive()
    }

    override func tearDown() {
        super.tearDown()
    }

    // Without session data, a Tab can't become a SavedTab and get archived
    func addTabWithSessionData(isPrivate: Bool = false, url: URL? = URL(string: "http://yahoo.com")!) {
        let tab = Tab(bvc: BrowserViewController.foregroundBVC(), configuration: configuration, isPrivate: isPrivate)
        tab.url = url
        let request: URLRequest? = url == nil ? nil : URLRequest(url: url!)
        _ = manager.configureTab(tab, request: request, flushToDisk: false, zombie: false)
        tab.sessionData = SessionData(currentPage: 0, urls: [tab.url!], lastUsedTime: Date.now())
    }

    func testNoData() {
        XCTAssertEqual(manager.testTabCountOnDisk(), 0, "Expected 0 tabs on disk")
        XCTAssertEqual(manager.testCountRestoredTabs(), 0)
    }

    func testPrivateTabsAreArchived() {
        for _ in 0..<2 {
            addTabWithSessionData(isPrivate: true)
        }
        let e = expectation(description: "saved")
        manager.storeChanges().uponQueue(.main) {_ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 2)
            e.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testAddedTabsAreStored() {
        // Add 2 tabs
        for _ in 0..<2 {
            addTabWithSessionData()
        }

        var e = expectation(description: "saved")
        manager.storeChanges().uponQueue(.main) { _ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 2)
            e.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)

        // Add 2 more
        for _ in 0..<2 {
            addTabWithSessionData()
        }

        e = expectation(description: "saved")
        manager.storeChanges().uponQueue(.main) { _ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 4)
            e.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)

        // Remove all tabs, and add just 1 tab
        manager.removeAll()
        addTabWithSessionData()

        e = expectation(description: "saved")
        manager.storeChanges().uponQueue(.main) {_ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 1)
            e.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }

    func testRestoreTabsWithNewTab() {
        self.addTabWithSessionData()
        self.addTabWithSessionData(url: nil)

        let e = expectation(description: "saved")
        self.manager.storeChanges().uponQueue(.main) { _ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 2)
            e.fulfill()
        }
        self.manager.testClearTabs()
        XCTAssertEqual(self.manager.normalTabs.count, 0)
        self.waitForExpectations(timeout: 2, handler: nil)
        let restoredTabsCount = self.manager.testCountRestoredTabs(clearPrivateTabs: false)
        XCTAssertEqual(restoredTabsCount, 2)
        XCTAssertEqual(self.manager.normalTabs.count, 2)
        self.manager.addTab()
        XCTAssertEqual(self.manager.normalTabs.count, 2)
    }

    func testRestoreTabsWithNewPrivateTab() {
        self.addTabWithSessionData(isPrivate: true)
        self.addTabWithSessionData(isPrivate: true, url: nil)

        let e = expectation(description: "saved")
        self.manager.storeChanges().uponQueue(.main) { _ in
            XCTAssertEqual(self.manager.testTabCountOnDisk(), 2)
            e.fulfill()
        }
        self.manager.testClearTabs()
        XCTAssertEqual(self.manager.privateTabs.count, 0)
        self.waitForExpectations(timeout: 2, handler: nil)
        let restoredTabsCount = self.manager.testCountRestoredTabs(clearPrivateTabs: false)
        XCTAssertEqual(restoredTabsCount, 2)
        XCTAssertEqual(self.manager.privateTabs.count, 2)
        self.manager.addTab()
        XCTAssertEqual(self.manager.privateTabs.count, 2)
    }

}

