/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import UIKit
import XCTest

import Shared
import Storage
import WebKit
@testable import Client

class ClientTests: XCTestCase {
    // Simple test to make sure the WKWebView UA matches the expected FxiOS pattern.
    func testUserAgent() {
        let compare: (String) -> Bool = { ua in
            let range = ua.range(of: "^Mozilla/5\\.0 \\(.+\\) AppleWebKit/[0-9\\.]+ \\(KHTML, like Gecko\\)", options: .regularExpression)
            return range != nil
        }

        XCTAssertTrue(compare(UserAgent.getUserAgent()), "User agent computes correctly.")
        //XCTAssertTrue(compare(UserAgent.cachedUserAgent(checkiOSVersion: true)!), "User agent is cached correctly.")
        let expectation = self.expectation(description: "Found Firefox user agent")

        let webView = WKWebView()
        webView.evaluateJavaScript("navigator.userAgent") { result, error in
            let userAgent = result as! String
            if compare(userAgent) {
                expectation.fulfill()
            } else {
                XCTFail("User agent did not match expected pattern! \(userAgent)")
            }
        }

        waitForExpectations(timeout: 5, handler: nil)
    }

    func testDesktopUserAgent() {
        let compare: (String) -> Bool = { ua in
            let range = ua.range(of: "^Mozilla/5\\.0 \\(Macintosh; Intel Mac OS X [0-9\\_]+\\)", options: .regularExpression)
            return range != nil
        }

        XCTAssertTrue(compare(UserAgent.desktopUserAgent()), "Desktop user agent computes correctly.")
    }
}
