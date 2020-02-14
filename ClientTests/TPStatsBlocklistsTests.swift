/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client

import XCTest

class TPStatsBlocklistsTests: XCTestCase {
    var blocklists: TPStatsBlocklists!
    
    override func setUp() {
        super.setUp()
        
        blocklists = TPStatsBlocklists()
    }
    
    override func tearDown() {
        super.tearDown()
        blocklists = nil
    }
    
    func testLoadPerformance() {
        self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
            blocklists.load()
            self.stopMeasuring()
        }
    }
    
    func testURLInListPerformance() {
        blocklists.load()
        
        let allowListedRegexs = ["*google.com"].compactMap { (domain) -> String? in
            return wildcardContentBlockerDomainToRegex(domain: domain)
        }
        
        self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
            for _ in 0..<100 {
                _ = blocklists.urlIsInCategory(URL(string: "https://www.firefox.com")!, allowListedDomains: allowListedRegexs)
            }
            self.stopMeasuring()
        }
    }
    
    func testURLInList() {
        blocklists.load()
        
        func blocklist(_ urlString: String, _ allowListedDomains: [String] = []) -> (Tracker)? {
            let allowListedRegexs = allowListedDomains.compactMap { (domain) -> String? in
                return wildcardContentBlockerDomainToRegex(domain: domain)
            }

            return blocklists.urlIsInCategory(URL(string: urlString)!, allowListedDomains: allowListedRegexs)
        }
        
        XCTAssertEqual(blocklist("https://www.firefox.com")?.category ?? nil, nil)
        XCTAssertEqual(blocklist("https://2leep.com/track")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://sub.2leep.com/ad")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://admeld.com")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://admeld.com/popup")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://sub.admeld.com")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://subadmeld.com")?.category ?? nil, nil)

//        XCTAssertEqual(blocklist("https://aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://sub.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://aolanswers.com/track"), .content)
//        XCTAssertEqual(blocklist("https://aol.com.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://aol.com.aolanswers.com", ["ers.com"]), nil)
//        XCTAssertEqual(blocklist("https://games.com.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://bluesky.com.aolanswers.com"), .content)

        XCTAssertEqual(blocklist("https://sub.xiti.com/track")?.category ?? nil, .analytics)
        XCTAssertEqual(blocklist("https://backtype.com")?.category ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://backtype.com", ["*firefox.com", "*e.com"])?.id ?? nil, nil)
    }
}
