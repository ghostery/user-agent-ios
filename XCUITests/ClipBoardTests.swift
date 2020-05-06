/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import XCTest

class ClipBoardTests: BaseTestCase {
    let url = "www.example.com"

    //Copy url from the browser
    func copyUrl() {
        navigator.goto(URLBarOpen)
        waitForExistence(app.textFields["address"])
        app.textFields["address"].tap()
        waitForExistence(app.menuItems["Copy"])
        app.menuItems["Copy"].tap()
        app.typeText("\r")
        navigator.nowAt(BrowserTab)
    }

    // This test is disabled in release, but can still run on master
    func testClipboard() {
        navigator.openURL(url)
        waitUntilPageLoad()
        copyUrl()

        navigator.createNewTab()
        navigator.goto(URLBarOpen)
        app.textFields["address"].press(forDuration: 3)
        app.menuItems["Paste"].tap()
        waitForValueContains(app.textFields["address"], value: "www.example.com")
    }

    // Smoketest
    func testClipboardPasteAndGo() {
        navigator.openURL(url)
        waitUntilPageLoad()
        app.textFields["url"].press(forDuration: 3)
        waitForExistence(app.tables["Context Menu"])
        app.cells["menu-Copy-Link"].tap()

        navigator.createNewTab()
        app.textFields["url"].press(forDuration: 3)
        waitForExistence(app.tables["Context Menu"])
        app.cells["menu-PasteAndGo"].tap()
        waitForValueContains(app.textFields["url"], value: "www.example.com")
    }
}
