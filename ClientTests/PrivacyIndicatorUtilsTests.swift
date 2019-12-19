@testable import Client
import Foundation

import XCTest

class PrivacyIndicatorUtilsTest: XCTestCase {
    func testCircleRangeInit() {
        let r = PrivacyIndicatorUtils.CircleRange(count: 1)
        XCTAssert(r.first == 0 && r.first == r.last)
    }
    func testCircleRangeAdvance() {
        var r = PrivacyIndicatorUtils.CircleRange(count: 100)
        r.advance(CGFloat(10))
        XCTAssert(r.first == 0 && r.last == 0.1)
    }
    func testCircleRangeAdvanceTwice() {
        var r = PrivacyIndicatorUtils.CircleRange(count: 100)
        r.advance(CGFloat(10))
        r.advance(CGFloat(20))
        XCTAssert((10 * r.first).rounded() == 1)
        XCTAssert((10 * r.last).rounded() == 3)
    }
    func testCircleRangeAdvanceTenTimes() {
        var r = PrivacyIndicatorUtils.CircleRange(count: 100)
        for _ in 0..<10 { r.advance(CGFloat(10)) }
        XCTAssert((10 * r.first).rounded() == 9)
        XCTAssert((10 * r.last).rounded() == 10)
    }
    func testPercentToRadian() {
        XCTAssert(PrivacyIndicatorUtils.percentToRadian(0.25) == 0.0)
        XCTAssert(4.7...4.8 ~= PrivacyIndicatorUtils.percentToRadian(0))
        XCTAssert(1.5...1.6 ~= PrivacyIndicatorUtils.percentToRadian(0.5))
        XCTAssert(3.1...3.2 ~= PrivacyIndicatorUtils.percentToRadian(0.75))
        XCTAssert(4.7...4.8 ~= PrivacyIndicatorUtils.percentToRadian(0.9999))
    }

    func testCreateStrikePath() {
        let path: PathFake = PrivacyIndicatorUtils.createStrikePath(1000, 500, 250)
        XCTAssert(347...347.5 ~= path.moved.x)
        XCTAssert(347...347.5 ~= path.moved.y)
        XCTAssert(152.5...153 ~= path.addedLine.x)
        XCTAssert(-97.5...(-97) ~= path.addedLine.y)
    }
}

class PathFake {
    var cgPath: CGPath = CGPath(rect: CGRect.zero, transform: nil)
    var moved: CGPoint = CGPoint(x: 0, y: 0)
    var addedLine: CGPoint = CGPoint(x: 0, y: 0)
    required init() {}
}
extension PathFake: PrivacyIndicatorUtilsPath {
    func move(to: CGPoint) { moved = to }
    func addLine(to: CGPoint) { addedLine = to }
}
