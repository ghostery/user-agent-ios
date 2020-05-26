//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension Strings {

    public struct Accessibility {
        public struct Intro {
            public static let TourCarousel = NSLocalizedString("Accessibility.Intro.TourCarousel", tableName: "Accessibility", comment: "Accessibility label for the introduction tour carousel")
        }
        public struct FindInPage {
            public static let Previous = NSLocalizedString("Accessibility.FindInPage.Previous", tableName: "Accessibility", comment: "Accessibility label for previous result button in Find in Page Toolbar.")
            public static let Next = NSLocalizedString("Accessibility.FindInPage.Next", tableName: "Accessibility", comment: "Accessibility label for next result button in Find in Page Toolbar.")
        }
        public struct ReaderMode {
            public static let DisplaySettings = NSLocalizedString("Accessibility.ReaderMode.DisplaySettings", tableName: "Accessibility", comment: "Name for display settings button in reader mode. Display in the meaning of presentation, not monitor.")
            public static let ResetFontSize = NSLocalizedString("Accessibility.ReaderMode.ResetFontSize", tableName: "Accessibility", comment: "Accessibility label for button resetting font size in display settings of reader mode")
            public static let Brightness = NSLocalizedString("Accessibility.ReaderMode.Brightness", tableName: "Accessibility", comment: "Accessibility label for brightness adjustment slider in Reader Mode display settings")
            public static let ChangesFontType = NSLocalizedString("Accessibility.ReaderMode.ChangesFontType", tableName: "Accessibility", comment: "Accessibility hint for the font type buttons in reader mode display settings")
            public static let DecreaseTextSize = NSLocalizedString("Accessibility.ReaderMode.DecreaseTextSize", tableName: "Accessibility", comment: "Accessibility label for button decreasing font size in display settings of reader mode")
            public static let IncreaseTextSize = NSLocalizedString("Accessibility.ReaderMode.IncreaseTextSize", tableName: "Accessibility", comment: "Accessibility label for button increasing font size in display settings of reader mode")
            public static let ChangesColorTheme = NSLocalizedString("Accessibility.ReaderMode.ChangesColorTheme", tableName: "Accessibility", comment: "Accessibility hint for the color theme setting buttons in reader mode display settings")
        }
        public struct URLBar {
            public static let LockImageView = NSLocalizedString("Accessibility.URLBar.LockImageView", tableName: "Accessibility", comment: "Accessibility label for the lock icon, which is only present if the connection is secure")
            public static let PageOptionsButton = NSLocalizedString("Accessibility.URLBar.PageOptionsButton", tableName: "Accessibility", comment: "Accessibility label for the Page Options menu button")
            public static let AddressAndSearch = NSLocalizedString("Accessibility.URLBar.AddressAndSearch", comment: "Accessibility label for address and search field, both words (Address, Search) are therefore nouns.")
        }
        public struct ForceTouchActions {
            public static let Preview = NSLocalizedString("Accessibility.ForceTouch.Preview", tableName: "Accessibility", comment: "Accessibility label, associated to the 3D Touch action on the current tab in the tab tray, used to display a larger preview of the tab.")
        }
        public struct TabToolbar {
            public static let Stop = NSLocalizedString("Accessibility.TabToolbar.Stop", tableName: "Accessibility", comment: "Accessibility Label for the tab toolbar Stop button")
            public static let Reload = NSLocalizedString("Accessibility.TabToolbar.Reload", tableName: "Accessibility", comment: "Accessibility Label for the tab toolbar Reload button")
            public static let Back = NSLocalizedString("Accessibility.TabToolbar.Back", tableName: "Accessibility", comment: "Accessibility label for the Back button in the tab toolbar.")
            public static let Forward = NSLocalizedString("Accessibility.TabToolbar.Forward", tableName: "Accessibility", comment: "Accessibility Label for the tab toolbar Forward button")
            public static let Toolbar = NSLocalizedString("Accessibility.TabToolbar.Toolbar", tableName: "Accessibility", comment: "Accessibility label for the navigation toolbar displayed at the bottom of the screen.")
        }
        public struct TabTray {
            public static let TabsTray = NSLocalizedString("Accessibility.TabTray.TabsTray", tableName: "Accessibility", comment: "Accessibility label for the Tabs Tray view.")
            public static let NoTabs = NSLocalizedString("Accessibility.TabTray.NoTabs", tableName: "Accessibility", comment: "Message spoken by VoiceOver to indicate that there are no tabs in the Tabs Tray")
            public static let SingleTab = NSLocalizedString("Accessibility.TabTray.SingleTab", tableName: "Accessibility", comment: "Message spoken by VoiceOver saying the position of the single currently visible tab in Tabs Tray, along with the total number of tabs. E.g. \"Tab 2 of 5\" says that tab 2 is visible (and is the only visible tab), out of 5 tabs total.")
            public static let RangeOfTabs = NSLocalizedString("Accessibility.TabTray.RangeOfTabs", tableName: "Accessibility", comment: "Message spoken by VoiceOver saying the range of tabs that are currently visible in Tabs Tray, along with the total number of tabs. E.g. \"Tabs 8 to 10 of 15\" says tabs 8, 9 and 10 are visible, out of 15 tabs total.")
            public static let ClosingTab = NSLocalizedString("Accessibility.TabTray.ClosingTab", tableName: "Accessibility", comment: "Accessibility label (used by assistive technology) notifying the user that the tab is being closed.")
            public static let AddTab = NSLocalizedString("Accessibility.TabTray.AddTab", tableName: "Accessibility", comment: "Accessibility label for the Add Tab button in the Tab Tray.")
            public static let Close = NSLocalizedString("Accessibility.TabTray.Close", tableName: "Accessibility", comment: "Accessibility label for action denoting closing a tab in tab list (tray)")
            public static let Swipe = NSLocalizedString("Accessibility.TabTray.Swipe", tableName: "Accessibility", comment: "Accessibility hint for tab tray's displayed tab.")
            public static let ShowTabs = NSLocalizedString("Accessibility.TabTray.ShowTabs", tableName: "Accessibility", comment: "Accessibility Label for the tabs button in the tab toolbar")
            public static let NewTab = NSLocalizedString("Accessibility.TabTray.NewTab", tableName: "Accessibility", comment: "Accessibility label for the New Tab button in the tab toolbar.")
        }
        public struct PrivateBrowsing {
            public static let ToggleAccessibilityValueOn = NSLocalizedString("Accessibility.PrivateBrowsing.On", tableName: "Accessibility", comment: "Toggled ON accessibility value")
            public static let ToggleAccessibilityValueOff = NSLocalizedString("Accessibility.PrivateBrowsing.Off", tableName: "Accessibility", comment: "Toggled OFF accessibility value")
        }
        public static let WebContent = NSLocalizedString("Accessibility.WebContent", tableName: "Accessibility", comment: "Accessibility label for the main web content view")
    }

}
