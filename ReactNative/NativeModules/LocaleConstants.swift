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
            "ControlCenter.SearchStats.CliqzSearch": String(format: Strings.ControlCenter.SearchStats.CliqzSearch, AppInfo.displayName),
            "ControlCenter.SearchStats.OtherSearch": Strings.ControlCenter.SearchStats.OtherSearch,
            "ControlCenter.PrivacyProtection.Title": Strings.ControlCenter.PrivacyProtection.Title,
            "ControlCenter.PrivacyProtection.AdsBlocked": Strings.ControlCenter.PrivacyProtection.AdsBlocked,
            "ControlCenter.PrivacyProtection.TrackersBlocked": Strings.ControlCenter.PrivacyProtection.TrackersBlocked,
            "Delete": Strings.General.DeleteString,
            "UrlBar.Placeholder": Strings.UrlBar.Placeholder,
            "Search.UI.Visit": Strings.Search.UI.Visit,
            "Search.UI.NoResults": Strings.Search.UI.NoResults,
            "Search.UI.Footer": Strings.Search.UI.Footer,
            "Search.UI.AdditionalSearchEnginesHeader": Strings.Search.UI.AdditionalSearchEnginesHeader,
            "Search.UI.SwitchToTab": Strings.Search.UI.SwitchToTab,
            "HomeView.CliqzOffboarding.Header": Strings.HomeView.CliqzOffboarding.Header,
            "HomeView.CliqzOffboarding.Text1": Strings.HomeView.CliqzOffboarding.Text1,
            "HomeView.CliqzOffboarding.Text2": Strings.HomeView.CliqzOffboarding.Text2,
            "HomeView.CliqzOffboarding.Text3": Strings.HomeView.CliqzOffboarding.Text3,
            "HomeView.CliqzOffboarding.Alternatives": Strings.HomeView.CliqzOffboarding.Alternatives,
            "HomeView.CliqzOffboarding.CTA": Strings.HomeView.CliqzOffboarding.CTA,
            "HomeView.CliqzOffboarding.Footer": Strings.HomeView.CliqzOffboarding.Footer,
        ]
    }

    @objc
    static func requiresMainQueueSetup() -> Bool {
        return false
    }
}
