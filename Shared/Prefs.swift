/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

public struct PrefsKeys {
    public static let KeyDefaultHomePageURL = "KeyDefaultHomePageURL"
    public static let KeyMailToOption = "MailToOption"
    public static let IntroSeen = "IntroViewControllerSeen-3.0.0"
    public static let ShowAppReview = "ShowAppReview-\(AppInfo.appVersion)"

    public static let WhatsNewBubble = "WhatsNewBubble-\(AppInfo.appVersion)"
    public static let NewTabPageDefaultView = "NewTabPageDefaultView"
    public static let OpenLinks = "OpenLinks"
    public static let OnBrowserStartTab = "OnBrowserStartTab"

    // Today Widget
    public static let TodayWidgetWeatherLocation = "WeatherLocation"

    // Pull to refresh
    public static let RefreshControlEnabled = "RefreshControlEnabled"

    // Contextual Onboarding
    public static let WipeAllTraces = "WipeAllTraces"
    public static let AutomaticForgetMode = "AutomaticForgetMode"

    // Privacy Dashboard
    public static let AntiTracking = "AntiTracking"
    public static let Adblocker = "Adblocker"
    public static let PopupBlocker = "PopupBlocker"

    // News
    public static let NewTabNewsEnabled = "NewTabNewsEnabled"
    public static let NewTabNewsImagesEnabled = "NewTabNewsImagesEnabled"

    public static let ContextMenuShowLinkPreviews = "showLinkPreviews"

    public static let NewTabCustomUrlPrefKey = "HomePageURLPref"
    // Activity Stream
    public static let KeyTopSitesCacheIsValid = "topSitesCacheIsValid"
    public static let KeyTopSitesCacheSize = "topSitesCacheSize"

    public static let UseStageServer = "useStageSyncService"

    public static let AppExtensionTelemetryOpenUrl = "AppExtensionTelemetryOpenUrl"
    public static let AppExtensionTelemetryEventArray = "AppExtensionTelemetryEvents"
    public static let KeyBlockPopups = "blockPopups"
}

public protocol Prefs {
    func getBranchPrefix() -> String
    func branch(_ branch: String) -> Prefs
    func setTimestamp(_ value: Timestamp, forKey defaultName: String)
    func setLong(_ value: UInt64, forKey defaultName: String)
    func setLong(_ value: Int64, forKey defaultName: String)
    func setInt(_ value: Int32, forKey defaultName: String)
    func setString(_ value: String, forKey defaultName: String)
    func setBool(_ value: Bool, forKey defaultName: String)
    func setObject(_ value: Any?, forKey defaultName: String)
    func stringForKey(_ defaultName: String) -> String?
    func objectForKey<T: Any>(_ defaultName: String) -> T?
    func boolForKey(_ defaultName: String) -> Bool?
    func intForKey(_ defaultName: String) -> Int32?
    func timestampForKey(_ defaultName: String) -> Timestamp?
    func longForKey(_ defaultName: String) -> Int64?
    func unsignedLongForKey(_ defaultName: String) -> UInt64?
    func stringArrayForKey(_ defaultName: String) -> [String]?
    func arrayForKey(_ defaultName: String) -> [Any]?
    func dictionaryForKey(_ defaultName: String) -> [String: Any]?
    func removeObjectForKey(_ defaultName: String)
    func clearAll()
    func addListener(_ defaultName: String, callback: @escaping () -> Void)
    func removeListener(_ defaultName: String)
}

open class MockProfilePrefs: Prefs {
    let prefix: String

    open func getBranchPrefix() -> String {
        return self.prefix
    }

    // Public for testing.
    open var things = NSMutableDictionary()

    public init(things: NSMutableDictionary, prefix: String) {
        self.things = things
        self.prefix = prefix
    }

    public init() {
        self.prefix = ""
    }

    open func branch(_ branch: String) -> Prefs {
        return MockProfilePrefs(things: self.things, prefix: self.prefix + branch + ".")
    }

    private func name(_ name: String) -> String {
        return self.prefix + name
    }

    open func setTimestamp(_ value: Timestamp, forKey defaultName: String) {
        self.setLong(value, forKey: defaultName)
    }

    open func setLong(_ value: UInt64, forKey defaultName: String) {
        setObject(NSNumber(value: value as UInt64), forKey: defaultName)
    }

    open func setLong(_ value: Int64, forKey defaultName: String) {
        setObject(NSNumber(value: value as Int64), forKey: defaultName)
    }

    open func setInt(_ value: Int32, forKey defaultName: String) {
        things[name(defaultName)] = NSNumber(value: value as Int32)
    }

    open func setString(_ value: String, forKey defaultName: String) {
        things[name(defaultName)] = value
    }

    open func setBool(_ value: Bool, forKey defaultName: String) {
        things[name(defaultName)] = value
    }

    open func setObject(_ value: Any?, forKey defaultName: String) {
        things[name(defaultName)] = value
    }

    open func stringForKey(_ defaultName: String) -> String? {
        return things[name(defaultName)] as? String
    }

    open func boolForKey(_ defaultName: String) -> Bool? {
        return things[name(defaultName)] as? Bool
    }

    open func objectForKey<T: Any>(_ defaultName: String) -> T? {
        return things[name(defaultName)] as? T
    }

    open func timestampForKey(_ defaultName: String) -> Timestamp? {
        return unsignedLongForKey(defaultName)
    }

    open func unsignedLongForKey(_ defaultName: String) -> UInt64? {
        return things[name(defaultName)] as? UInt64
    }

    open func longForKey(_ defaultName: String) -> Int64? {
        return things[name(defaultName)] as? Int64
    }

    open func intForKey(_ defaultName: String) -> Int32? {
        return things[name(defaultName)] as? Int32
    }

    open func stringArrayForKey(_ defaultName: String) -> [String]? {
        if let arr = self.arrayForKey(defaultName) {
            if let arr = arr as? [String] {
                return arr
            }
        }
        return nil
    }

    open func arrayForKey(_ defaultName: String) -> [Any]? {
        let r: Any? = things.object(forKey: name(defaultName)) as Any?
        if r == nil {
            return nil
        }
        if let arr = r as? [Any] {
            return arr
        }
        return nil
    }

    open func dictionaryForKey(_ defaultName: String) -> [String: Any]? {
        return things.object(forKey: name(defaultName)) as? [String: Any]
    }

    open func removeObjectForKey(_ defaultName: String) {
        self.things.removeObject(forKey: name(defaultName))
    }

    open func clearAll() {
        let dictionary = things as! [String: Any]
        let keysToDelete: [String] = dictionary.keys.filter { $0.hasPrefix(self.prefix) }
        things.removeObjects(forKeys: keysToDelete)
    }

    open func addListener(_ defaultName: String, callback: @escaping () -> Void) {

    }

    open func removeListener(_ defaultName: String) {

    }
}
