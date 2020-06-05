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
    public struct ForgetMode {
        public struct ShareExtension {
            public static var OpenInPrivateTab = NSLocalizedString("ForgetMode.ShareExtension.OpenInPrivateTab", tableName: "ForgetMode", comment: "Action label on share extension to immediately open page in Private.")
        }
        public struct AutomaticPrivateMode {
            public static let Title = NSLocalizedString("ForgetMode.AutomaticForgetMode.Title", tableName: "ForgetMode", comment: "Title for Automatic forget mode screen")
            public static let Description = String(format: NSLocalizedString("ForgetMode.AutomaticForgetMode.Description", tableName: "ForgetMode", comment: "Description for Automatic forget mode screen"), AppInfo.displayName)
        }
        public struct ContextMenu {
            public static let OpenInNewPrivateTab = NSLocalizedString("ForgetMode.ContextMenu.OpenInNewPrivateTab", tableName: "ForgetMode", comment: "The title for the Open in New Private Tab context menu action for sites in Home Panels")
        }
        public struct Hotkeys {
            public static let PrivateBrowsingModeTitle = NSLocalizedString("ForgetMode.Hotkeys.PrivateBrowsingModeTitle", tableName: "ForgetMode", comment: "Label to switch to private browsing mode")
        }
        public struct TabTray {
            public static let SwitchToPBMKeyCodeTitle = NSLocalizedString("ForgetMode.TabTray.SwitchToPBMKeyCodeTitle", tableName: "ForgetMode", comment: "Hardware shortcut switch to the private browsing tab or tab tray. Shown in the Discoverability overlay when the hardware Command Key is held down.")
        }
        public static let EmptyPrivateTabsTitle = NSLocalizedString("ForgetMode.EmptyPrivateTabsTitle", tableName: "ForgetMode", comment: "Title displayed for when there are no open tabs while in private mode")
        public static let EmptyPrivateTabsDescription = NSLocalizedString("ForgetMode.EmptyPrivateTabsDescription", tableName: "ForgetMode", comment: "Empty tab title")
        public static let ClosePrivateTabsDescription = NSLocalizedString("ForgetMode.ClosePrivateTabsDescription", tableName: "ForgetMode", comment: "Will be displayed in Settings under 'Close Private Tabs'")
        public static let ToggleAccessibilityLabel = NSLocalizedString("ForgetMode.ToggleAccessibilityLabel", tableName: "ForgetMode", comment: "Accessibility label for toggling on/off private mode")
        public static let ToggleAccessibilityHint = NSLocalizedString("ForgetMode.ToggleAccessibilityHint", tableName: "ForgetMode", comment: "Accessiblity hint for toggling on/off private mode")
    }
}
