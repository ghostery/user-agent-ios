//
//  LocaleConstants.swift
//  Cliqz
//
//  Created by Krzysztof Modras on 29.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

import Foundation
import Shared

@objc(LocaleConstants)
class LocaleConstants: NSObject {
    @objc
    func constantsToExport() -> [String: Any]! {
        return [
            "lang": Locale.current.languageCode ?? "en",
            "locale": Locale.current.identifier,
            "ActivityStream.TopSites.SectionTitle": Strings.ActivityStream.TopSites.Title,
            "ActivityStream.PinnedSites.SectionTitle": Strings.ActivityStream.PinnedSitesTitle,
            "ActivityStream.News.BreakingLabel": Strings.ActivityStream.News.BreakingLabel,
            "ActivityStream.News.Header": Strings.ActivityStream.News.Header,
            "ControlCenter.SearchStats.Title": Strings.ControlCenter.SearchStats.Title,
            "ControlCenter.SearchStats.CliqzSearch": Strings.ControlCenter.SearchStats.CliqzSearch,
            "ControlCenter.SearchStats.OtherSearch": Strings.ControlCenter.SearchStats.OtherSearch,
            "ControlCenter.PrivacyProtection.Title": Strings.ControlCenter.PrivacyProtection.Title,
            "ControlCenter.PrivacyProtection.AdsBlocked": Strings.ControlCenter.PrivacyProtection.AdsBlocked,
            "ControlCenter.PrivacyProtection.TrackersBlocked": Strings.ControlCenter.PrivacyProtection.TrackersBlocked,
            "Delete": Strings.HistoryPanel.DeleteTitle,
            "UrlBar.Placeholder": Strings.UrlBar.Placeholder,
            "Search.Visit": Strings.Search.Visit,
        ]
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
