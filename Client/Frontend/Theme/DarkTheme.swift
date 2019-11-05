/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

// Convenience reference to these normal mode colors which are used in a few color classes.
private var defaultBackground: UIColor {
    if #available(iOS 13.0, *) {
        return UIColor.systemGray6
    } else {
        // Fallback on earlier versions
        return UIColor.Grey80
    }
}

private let defaultSeparator = UIColor.Grey60
private let defaultTextAndTint = UIColor.Grey10

private class DarkTableViewColor: TableViewColor {
    override var rowText: UIColor { return defaultTextAndTint }
    override var rowDetailText: UIColor { return UIColor.Grey30 }
    override var disabledRowText: UIColor { return UIColor.Grey40 }
    override var headerTextLight: UIColor { return UIColor.Grey30 }
    override var headerTextDark: UIColor { return UIColor.Grey30 }
    override var syncText: UIColor { return defaultTextAndTint }
}

private class DarkActionMenuColor: ActionMenuColor {
    override var foreground: UIColor { return defaultTextAndTint }
    override var iPhoneBackgroundBlurStyle: UIBlurEffect.Style { return UIBlurEffect.Style.dark }
    override var closeButtonBackground: UIColor { return defaultBackground }
    override var closeButtonTitleColor: UIColor { return UIColor.CliqzBlue }
}

private class DarkURLBarColor: URLBarColor {
    override func textSelectionHighlight(_ isPrivate: Bool) -> TextSelectionHighlight {
        let color = isPrivate ? UIColor.Defaults.MobilePrivatePurple : UIColor(rgb: 0x3d89cc)
        return (labelMode: color.withAlphaComponent(0.25), textFieldMode: color)

    }
    override var background: UIColor {
        return UIColor.LightSky.withAlphaComponent(0.2)
    }
}

private class DarkBrowserColor: BrowserColor {
    override var background: UIColor { return defaultBackground }
    override var tint: UIColor { return defaultTextAndTint }
}

// The back/forward/refresh/menu button (bottom toolbar)
private class DarkToolbarButtonColor: ToolbarButtonColor {

}

private class DarkTabTrayColor: TabTrayColor {
    override var tabTitleText: UIColor { return defaultTextAndTint }
    override var tabTitleBlur: UIBlurEffect.Style { return UIBlurEffect.Style.dark }
    override var background: UIColor { return defaultBackground }
    override var cellBackground: UIColor { return defaultBackground }
    override var toolbar: UIColor { return UIColor.black.withAlphaComponent(0.8) }
    override var toolbarButtonTint: UIColor { return defaultTextAndTint }
    override var cellCloseButton: UIColor { return defaultTextAndTint }
    override var cellTitleBackground: UIColor { return UIColor.Grey70 }
    override var searchBackground: UIColor { return UIColor.Grey60 }
}

private class DarkTextFieldColor: TextFieldColor {
    override var background: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            return UIColor.Grey60
        }
    }

    override var backgroundInOverlay: UIColor { return self.background }

    override var textAndTint: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            // Fallback on earlier versions
            return defaultTextAndTint
        }
    }
    override var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            return super.separator.withAlphaComponent(0.3)
        }
    }
}

private class DarkHomePanelColor: HomePanelColor {
    override var toolbarBackground: UIColor { return defaultBackground }
    override var toolbarHighlight: UIColor { return UIColor.Blue40 }
    override var toolbarTint: UIColor { return UIColor.Grey30 }
    override var panelBackground: UIColor { return defaultBackground }
    override var separator: UIColor { return defaultSeparator }
    override var border: UIColor { return UIColor.Grey60 }
    override var buttonContainerBorder: UIColor { return separator }

    override var welcomeScreenText: UIColor { return UIColor.Grey30 }
    override var bookmarkIconBorder: UIColor { return UIColor.Grey30 }
    override var bookmarkFolderBackground: UIColor { return UIColor.Grey80 }
    override var bookmarkFolderText: UIColor { return UIColor.White }
    override var bookmarkCurrentFolderText: UIColor { return UIColor.White }
    override var bookmarkBackNavCellBackground: UIColor { return UIColor.Grey70 }

    override var activityStreamHeaderText: UIColor { return UIColor.Grey30 }
    override var activityStreamCellTitle: UIColor { return UIColor.Grey20 }
    override var activityStreamCellDescription: UIColor { return UIColor.Grey30 }

    override var topSiteDomain: UIColor { return defaultTextAndTint }
    override var topSitesGradientStart: UIColor { return UIColor(rgb: 0x29282d) }
    override var topSitesGradientEnd: UIColor { return UIColor(rgb: 0x212104) }
    override var topSitesBackground: UIColor { return UIColor(rgb: 0x29282d) }

    override var downloadedFileIcon: UIColor { return UIColor.Grey30 }

    override var historyHeaderIconsBackground: UIColor { return UIColor.clear }

    override var readingListActive: UIColor { return UIColor.Grey10 }
    override var readingListDimmed: UIColor { return UIColor.Grey40 }

    override var searchSuggestionPillBackground: UIColor { return UIColor.Grey70 }
    override var searchSuggestionPillForeground: UIColor { return defaultTextAndTint }
}

private class DarkSnackBarColor: SnackBarColor {
// Use defaults
}

private class DarkGeneralColor: GeneralColor {
    override var settingsTextPlaceholder: UIColor? { return UIColor.black }
    override var faviconBackground: UIColor { return UIColor.White }
    override var passcodeDot: UIColor { return UIColor.Grey40 }
    override var controlTint: UIColor { return UIColor.CliqzBlue }
}

class DarkTheme: NormalTheme {
    override var name: String { return BuiltinThemeName.dark.rawValue }
    override var tableView: TableViewColor { return DarkTableViewColor() }
    override var urlbar: URLBarColor { return DarkURLBarColor() }
    override var browser: BrowserColor { return DarkBrowserColor() }
    override var toolbarButton: ToolbarButtonColor { return DarkToolbarButtonColor() }
    override var tabTray: TabTrayColor { return DarkTabTrayColor() }
    override var topTabs: TopTabsColor { return TopTabsColor() }
    override var textField: TextFieldColor { return DarkTextFieldColor() }
    override var homePanel: HomePanelColor { return DarkHomePanelColor() }
    override var snackbar: SnackBarColor { return DarkSnackBarColor() }
    override var general: GeneralColor { return DarkGeneralColor() }
    override var actionMenu: ActionMenuColor { return DarkActionMenuColor() }
}
