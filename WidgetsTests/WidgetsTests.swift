import Foundation
import XCTest
@testable import Widgets

class WidgetsTests: XCTestCase {
    func testCircleRangeInit() {
        let r = Widgets.PrivacyIndicator.utils.CircleRange(count: 1)
        XCTAssert(r.first == 0 && r.first == r.last)
    }
    func testCircleRangeAdvance() {
        var r = Widgets.PrivacyIndicator.utils.CircleRange(count: 100)
        r.advance(CGFloat(10))
        XCTAssert(r.first == 0 && r.last == 0.1)
    }
    func testCircleRangeAdvanceTwice() {
        var r = Widgets.PrivacyIndicator.utils.CircleRange(count: 100)
        r.advance(CGFloat(10))
        r.advance(CGFloat(20))
        XCTAssert((10 * r.first).rounded() == 1)
        XCTAssert((10 * r.last).rounded() == 3)
    }
    func testCircleRangeAdvanceTenTimes() {
        var r = Widgets.PrivacyIndicator.utils.CircleRange(count: 100)
        for _ in 0..<10 { r.advance(CGFloat(10)) }
        XCTAssert((10 * r.first).rounded() == 9)
        XCTAssert((10 * r.last).rounded() == 10)
    }
    func testPercentToRadian() {
        XCTAssert(Widgets.PrivacyIndicator.utils.percentToRadian(0.25) == 0.0)
        XCTAssert(4.7...4.8 ~= Widgets.PrivacyIndicator.utils.percentToRadian(0))
        XCTAssert(1.5...1.6 ~= Widgets.PrivacyIndicator.utils.percentToRadian(0.5))
        XCTAssert(3.1...3.2 ~= Widgets.PrivacyIndicator.utils.percentToRadian(0.75))
        XCTAssert(4.7...4.8 ~= Widgets.PrivacyIndicator.utils.percentToRadian(0.9999))
    }
}
