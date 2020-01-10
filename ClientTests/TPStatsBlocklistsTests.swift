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
        
        let whitelistedRegexs = ["*google.com"].compactMap { (domain) -> String? in
            return wildcardContentBlockerDomainToRegex(domain: domain)
        }
        
        self.measureMetrics([.wallClockTime], automaticallyStartMeasuring: true) {
            for _ in 0..<100 {
                _ = blocklists.urlIsInCategory(URL(string: "https://www.firefox.com")!, whitelistedDomains: whitelistedRegexs)
            }
            self.stopMeasuring()
        }
    }
    
    func testURLInList() {
        blocklists.load()
        
        func blocklist(_ urlString: String, _ whitelistedDomains: [String] = []) -> (WTMCategory, String)? {
            let whitelistedRegexs = whitelistedDomains.compactMap { (domain) -> String? in
                return wildcardContentBlockerDomainToRegex(domain: domain)
            }

            return blocklists.urlIsInCategory(URL(string: urlString)!, whitelistedDomains: whitelistedRegexs)
        }
        
        XCTAssertEqual(blocklist("https://www.firefox.com")?.0 ?? nil, nil)
        XCTAssertEqual(blocklist("https://2leep.com/track")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://sub.2leep.com/ad")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://admeld.com")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://admeld.com/popup")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://sub.admeld.com")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://subadmeld.com")?.0 ?? nil, nil)

//        XCTAssertEqual(blocklist("https://aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://sub.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://aolanswers.com/track"), .content)
//        XCTAssertEqual(blocklist("https://aol.com.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://aol.com.aolanswers.com", ["ers.com"]), nil)
//        XCTAssertEqual(blocklist("https://games.com.aolanswers.com"), .content)
//        XCTAssertEqual(blocklist("https://bluesky.com.aolanswers.com"), .content)

        XCTAssertEqual(blocklist("https://sub.xiti.com/track")?.0 ?? nil, .analytics)
        XCTAssertEqual(blocklist("https://backtype.com")?.0 ?? nil, .advertising)
        XCTAssertEqual(blocklist("https://backtype.com", ["*firefox.com", "*e.com"])?.0 ?? nil, nil)
    }
}
