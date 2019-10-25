/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
@testable import Client
import UIKit

import XCTest

class DefaultSearchPrefsTests: XCTestCase {

    func testParsing() {
        // setup the list json
        let searchPrefs = DefaultSearchPrefs(with: Bundle.main.resourceURL!.appendingPathComponent("SearchPlugins").appendingPathComponent("list.json"))!

        // setup the most popular locales
        let us = (lang: ["en-US", "en"], region: "US", resultList: ["cliqz", "google-b-1-m", "bing", "amazondotcom", "ddg", "twitter", "wikipedia"], resultDefault: "google-b-m")
        let england = (lang: ["en-GB", "en"], region: "GB", resultList: ["cliqz", "google-b-m", "bing", "amazon-co-uk", "ddg", "qwant", "twitter", "wikipedia"], resultDefault: "google-b-m")
        let france = (lang: ["fr-FR", "fr"], region: "FR", resultList: ["cliqz", "google-b-m", "bing", "ddg", "qwant", "twitter", "wikipedia-fr"], resultDefault: "google-b-m")
        let japan = (lang: ["ja-JP", "ja"], region: "JP", resultList: ["cliqz", "google-b-m", "amazon-jp", "bing", "twitter-ja", "wikipedia-ja", "yahoo-jp"], resultDefault: "google-b-m")
        let canada = (lang: ["en-CA", "en"], region: "CA", resultList: ["cliqz", "google-b-m", "bing", "amazondotcom", "ddg", "twitter", "wikipedia"], resultDefault: "google-b-m")
        let russia = (lang: ["ru-RU", "ru"], region: "RU", resultList: ["cliqz", "google-b-m", "yandex-ru", "twitter", "wikipedia-ru"], resultDefault: "Яндекс")
        let taiwan = (lang: ["zh-TW", "zh"], region: "TW", resultList: ["cliqz", "google-b-m", "bing", "ddg", "wikipedia-zh-TW"], resultDefault: "google-b-m")
        let china = (lang: ["zh-hans-CN", "zh-CN", "zh"], region: "CN", resultList: ["cliqz", "google-b-m", "baidu", "bing", "wikipedia-zh-CN"], resultDefault: "百度")
        let germany = (lang: ["de-DE", "de"], region: "DE", resultList: ["cliqz", "google-b-m", "bing", "amazon-de", "ddg", "qwant", "twitter", "wikipedia-de"], resultDefault: "google-b-m")
        let southAfrica = (lang: ["en-SA", "en"], region: "SA", resultList: ["cliqz", "google-b-m", "bing", "amazondotcom", "ddg", "twitter", "wikipedia"], resultDefault: "google-b-m")
        let testLocales = [us, england, france, japan, canada, russia, taiwan, china, germany, southAfrica]

        // run tests
        testLocales.forEach { locale in
            XCTAssertEqual(searchPrefs.searchDefault(for: locale.lang, and: locale.region), locale.resultDefault, "incorrect for \(locale.lang) and \(locale.region)")
            XCTAssertEqual(searchPrefs.visibleDefaultEngines(for: locale.lang, and: locale.region), locale.resultList)
        }
    }
}
