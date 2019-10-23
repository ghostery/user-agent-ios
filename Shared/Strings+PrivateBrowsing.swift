//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

// PrivateBrowsing {
extension Strings {
    public static let PrivateTabsViewButtonTitle = NSLocalizedString("TabsView.Private.Title", tableName: "PrivateBrowsing", comment: "Button displayed at the bottom of the tabs view")
    public static let DoneTabsViewButtonTitle = NSLocalizedString("TabsView.Done.Title", tableName: "PrivateBrowsing", comment: "Button displayed at the bottom of the tabs view")
    public static let PrivateBrowsingEmptyPrivateTabsTitle = NSLocalizedString("Private Browsing", tableName: "PrivateBrowsing", comment: "Title displayed for when there are no open tabs while in private mode")
    public static let PrivateBrowsingEmptyPrivateTabsDescription = String(format: NSLocalizedString("Empty.Private.Tab.Description", tableName: "PrivateBrowsing", comment: "Empty tab title"), AppInfo.displayName)
    public static let ClosePrivateTabsLabel = NSLocalizedString("Close Private Tabs", tableName: "PrivateBrowsing", comment: "Setting for closing private tabs")
    public static let ClosePrivateTabsDescription = NSLocalizedString("When Leaving Private Browsing", tableName: "PrivateBrowsing", comment: "Will be displayed in Settings under 'Close Private Tabs'")
    public static let ContextMenuOpenInNewPrivateTab = NSLocalizedString("ContextMenu.OpenInNewPrivateTabButtonTitle", tableName: "PrivateBrowsing", comment: "Context menu option for opening a link in a new private tab")
    public static let PrivateBrowsingToggleAccessibilityLabel = NSLocalizedString("Private Mode", tableName: "PrivateBrowsing", comment: "Accessibility label for toggling on/off private mode")
    public static let PrivateBrowsingToggleAccessibilityHint = NSLocalizedString("Turns private mode on or off", tableName: "PrivateBrowsing", comment: "Accessiblity hint for toggling on/off private mode")
    public static let PrivateBrowsingToggleAccessibilityValueOn = NSLocalizedString("On", tableName: "PrivateBrowsing", comment: "Toggled ON accessibility value")
    public static let PrivateBrowsingToggleAccessibilityValueOff = NSLocalizedString("Off", tableName: "PrivateBrowsing", comment: "Toggled OFF accessibility value")
}
