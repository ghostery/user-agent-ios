/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import Storage
import CoreSpotlight
import MobileCoreServices
import WebKit

private let browsingActivityType: String = AppInfo.activityTypes

private let searchableIndex = CSSearchableIndex(name: AppInfo.displayName.lowercased())

class UserActivityHandler {

    private var profile: Profile

    init(profile: Profile) {
        self.profile = profile
        register(self, forTabEvents: .didClose, .didLoseFocus, .didGainFocus, .didChangeURL, .didLoadPageMetadata) // .didLoadFavicon, // TO DO : Bug 1390294
    }

    class func clearSearchIndex(completionHandler: ((Error?) -> Void)? = nil) {
        searchableIndex.deleteAllSearchableItems(completionHandler: completionHandler)
    }

    fileprivate func setUserActivityForTab(_ tab: Tab, url: URL) {
        guard !tab.isPrivate, url.isWebPage(includeDataURIs: false), !InternalURL.isValid(url: url) else {
            tab.userActivity?.resignCurrent()
            tab.userActivity = nil
            return
        }

        tab.userActivity?.invalidate()

        let userActivity = NSUserActivity(activityType: browsingActivityType)
        userActivity.webpageURL = url

        let query = self.profile.searchEngines.queryForSearchURL(url)
        if !tab.isPrivate && (query == nil || !self.profile.searchEngines.isSearchEngineRedirectURL(url: url, query: query!)) {
            let attributeSet = self.searchableItemAttribute(tab: tab, url: url)
            self.addIndexSearchableItem(attributeSet: attributeSet, url: url)
            userActivity.contentAttributeSet = attributeSet
            userActivity.userInfo = [CSSearchableItemActivityIdentifier: url.absoluteString]
        }

        userActivity.becomeCurrent()

        tab.userActivity = userActivity
    }

    private func searchableItemAttribute(tab: Tab, url: URL) -> CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
        attributeSet.title = tab.title
        attributeSet.relatedUniqueIdentifier = url.absoluteString
        attributeSet.contentDescription = url.absoluteString
        return attributeSet
    }

    fileprivate func addIndexSearchableItem(attributeSet: CSSearchableItemAttributeSet, url: URL) {
        let item = CSSearchableItem(uniqueIdentifier: attributeSet.relatedUniqueIdentifier!, domainIdentifier: url.baseDomain, attributeSet: attributeSet)
        CSSearchableIndex.default().indexSearchableItems([item])
    }

}

extension UserActivityHandler: TabEventHandler {
    func tabDidGainFocus(_ tab: Tab) {
        tab.userActivity?.becomeCurrent()
    }

    func tabDidLoseFocus(_ tab: Tab) {
        tab.userActivity?.resignCurrent()
    }

    func tab(_ tab: Tab, didChangeURL url: URL) {
        setUserActivityForTab(tab, url: url)
    }

    func tab(_ tab: Tab, didLoadPageMetadata metadata: PageMetadata) {
        guard let url = URL(string: metadata.siteURL) else {
            return
        }

        setUserActivityForTab(tab, url: url)
    }

    func tabDidClose(_ tab: Tab) {
        guard let userActivity = tab.userActivity else {
            return
        }
        tab.userActivity = nil
        userActivity.invalidate()
    }
}
