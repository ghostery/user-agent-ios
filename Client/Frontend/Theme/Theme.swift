/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

struct Theme {
    static var tableView: TableViewColor { return TableViewColor() }
    static var urlbar: URLBarColor { return URLBarColor() }
    static var browser: BrowserColor { return BrowserColor() }
    static var toolbarButton: ToolbarButtonColor { return ToolbarButtonColor() }
    static var loadingBar: LoadingBarColor { return LoadingBarColor() }
    static var tabTray: TabTrayColor { return TabTrayColor() }
    static var topTabs: TopTabsColor { return TopTabsColor() }
    static var textField: TextFieldColor { return TextFieldColor() }
    static var homePanel: HomePanelColor { return HomePanelColor() }
    static var snackbar: SnackBarColor { return SnackBarColor() }
    static var general: GeneralColor { return GeneralColor() }
    static var actionMenu: ActionMenuColor { return ActionMenuColor() }

    static var statusBarStyle: UIStatusBarStyle { return .default }

    static let defaultSeparator = UIColor.Grey40
    static let defaultTextAndTint = UIColor.Grey80

    @available(iOS 13.0, *)
    private static var currentTheme: UIUserInterfaceStyle?
    @available(iOS 13.0, *)
    static func updateTheme(_ theme: UIUserInterfaceStyle) {
        if self.currentTheme == nil {
            self.currentTheme = theme
            return
        }

        if self.currentTheme != theme {
            NotificationCenter.default.post(name: .DisplayThemeChanged, object: nil)
            self.currentTheme = theme
        }
    }
}

protocol Themeable: AnyObject {
    func applyTheme()
}

protocol PrivateModeUI {
    func applyUIMode(isPrivate: Bool)
}

class TableViewColor {
    var rowBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.secondarySystemGroupedBackground
        } else {
            // Fallback on earlier versions
            return UIColor.White
        }
    }
    var rowText: UIColor { return UIColor.Grey90 }
    var rowDetailText: UIColor { return UIColor.Grey80 }
    var disabledRowText: UIColor { return UIColor.Grey60 }
    var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.opaqueSeparator
        } else {
            // Fallback on earlier versions
            return Theme.defaultSeparator
        }
    }
    var headerBackground: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGroupedBackground
        } else {
            // Fallback on earlier versions
            return UIColor.defaultBackground
        }
    }
    // Used for table headers in Settings and Photon menus
    var headerTextLight: UIColor { return UIColor.DarkBlue }
    // Used for table headers in home panel tables
    var headerTextDark: UIColor { return UIColor.Grey90 }
    var rowActionAccessory: UIColor { return UIColor.CliqzBlue }
    var controlTint: UIColor { return rowActionAccessory }
    var syncText: UIColor { return Theme.defaultTextAndTint }
    var errorText: UIColor { return UIColor.BrightRed }
    var warningText: UIColor { return UIColor.Orange }
    var accessoryViewTint: UIColor { return UIColor.Grey40 }
}

class ActionMenuColor {
    var separatorColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            return Theme.defaultTextAndTint
        }
    }
    var foreground: UIColor { return Theme.defaultTextAndTint }
    var iPhoneBackgroundBlurStyle: UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            return UIBlurEffect.Style.systemThickMaterial
        } else {
            return UIBlurEffect.Style.prominent
        }

    }
    var iPhoneBackground: UIColor { return Theme.browser.background.withAlphaComponent(0.7) }
    var closeButtonBackground: UIColor { return UIColor.defaultBackground }
    var closeButtonTitleColor: UIColor { return UIColor.BrightBlue }
}

class URLBarColor {
    var border: UIColor { return UIColor.Grey90.with(alpha: .tenPercent) }
    func activeBorder(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.CliqzBlue.with(alpha: .eightyPercent) : UIColor.ForgetMode
    }
    var tint: UIColor { return UIColor.Blue40.with(alpha: .thirtyPercent) }
    var background: UIColor {
        return UIColor.Grey60.withAlphaComponent(0.2)
    }
    // This text selection color is used in two ways:
    // 1) <UILabel>.background = textSelectionHighlight.withAlphaComponent(textSelectionHighlightAlpha)
    // To simulate text highlighting when the URL bar is tapped once, this is a background color to create a simulated selected text effect. The color will have an alpha applied when assigning it to the background.
    // 2) <UITextField>.tintColor = textSelectionHighlight.
    // When the text is in edit mode (tapping URL bar second time), this is assigned to the to set the selection (and cursor) color. The color is assigned directly to the tintColor.
    typealias TextSelectionHighlight = (labelMode: UIColor, textFieldMode: UIColor?)
    func textSelectionHighlight(_ isPrivate: Bool) -> TextSelectionHighlight {
        return (labelMode: UIColor.TextHighlightBlue, textFieldMode: nil)
    }

    var readerModeButtonSelected: UIColor { return UIColor.Blue40 }
    var readerModeButtonUnselected: UIColor { return UIColor.Grey50 }
    var pageOptionsSelected: UIColor { return readerModeButtonSelected }
    var pageOptionsUnselected: UIColor { return Theme.browser.tint }
}

class BrowserColor {
    var background: UIColor { return UIColor.defaultBackground }
    var homeBackground: UIColor { return UIColor.homeBackground }
    var urlBarDivider: UIColor { return UIColor.Grey90.with(alpha: .tenPercent) }
    var tint: UIColor { return Theme.defaultTextAndTint }
    var barBackgroundColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray6
        } else {
            return UIColor.Grey20
        }
    }
}

// The back/forward/refresh/menu button (bottom toolbar)
class ToolbarButtonColor {
    var selectedTint: UIColor { return UIColor.CliqzBlue }
    var disabledTint: UIColor { return UIColor.Grey30 }
}

class LoadingBarColor {
    func start(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.CliqzBlue : UIColor.Grey40
    }

    func end(_ isPrivate: Bool) -> UIColor {
        return start(isPrivate)
    }
}

class TabTrayColor {
    var tabTitleText: UIColor { return Theme.defaultTextAndTint }
    var tabTitleBlur: UIBlurEffect.Style {
        if #available(iOS 13.0, *) {
            return UIBlurEffect.Style.systemUltraThinMaterial
        } else {
            return UIBlurEffect.Style.extraLight
        }
    }
    var background: UIColor { return UIColor.DarkGrey }
    var cellBackground: UIColor { return UIColor.Grey30 }
    var toolbar: UIColor { return UIColor.defaultBackground }
    var toolbarButtonTint: UIColor { return Theme.defaultTextAndTint }
    var privateModeLearnMore: UIColor { return UIColor.Grey70 }
    var privateModePurple: UIColor { return UIColor.Grey70 }
    var privateModeButtonOffTint: UIColor { return toolbarButtonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Grey10 }
    var cellCloseButton: UIColor { return UIColor.Grey50 }
    var cellTitleBackground: UIColor { return UIColor.Grey30 }
    var faviconTint: UIColor { return UIColor.defaultBackground }
    var searchBackground: UIColor { return UIColor.Grey30 }
}

class TopTabsColor {
    var background: UIColor { return UIColor.clear }
    var tabBackgroundSelected: UIColor {
        return self.background
    }
    var tabBackgroundUnselected: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray3.withAlphaComponent(0.5)
        } else {
            return UIColor.CloudySky.withAlphaComponent(0.5)
        }
    }
    var tabForegroundSelected: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.Grey90
        }
    }
    var tabForegroundUnselected: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray
        } else {
            return UIColor.DarkRain
        }
    }

    var buttonTint: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            return UIColor.Grey90
        }
    }
    var privateModeButtonOffTint: UIColor { return buttonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Grey10 }
    var closeButtonSelectedTab: UIColor { return tabForegroundSelected }
    var closeButtonUnselectedTab: UIColor { return tabForegroundUnselected }
    var separator: UIColor {
        return background
    }
}

class TextFieldColor {
    var background: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            return UIColor.Grey60
        }
    }
    var backgroundInOverlay: UIColor { return UIColor.defaultBackground }
    var textAndTint: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            // Fallback on earlier versions
            return Theme.defaultTextAndTint
        }
    }
    var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            return .white
        }
    }

    var placeholder: UIColor {
        return .systemGray
    }
}

class HomePanelColor {
    var toolbarBackground: UIColor { return UIColor.defaultBackground }
    var toolbarHighlight: UIColor { return UIColor.Blue40 }
    var toolbarTint: UIColor { return UIColor.Grey50 }

    var panelBackground: UIColor { return UIColor.defaultBackground }
    var separatorColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray5
        } else {
            // Fallback on earlier versions
            return Theme.defaultSeparator
        }
    }
    var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            // Fallback on earlier versions
            return Theme.defaultSeparator
        }
    }

    var border: UIColor { return UIColor.Grey60 }
    var buttonContainerBorder: UIColor { return separator }

    var welcomeScreenText: UIColor { return UIColor.Grey50 }
    var bookmarkIconBorder: UIColor { return UIColor.Grey30 }
    var bookmarkFolderBackground: UIColor { return UIColor.Grey10.withAlphaComponent(0.3) }
    var bookmarkFolderText: UIColor { return UIColor.Grey80 }
    var bookmarkCurrentFolderText: UIColor { return UIColor.Blue40 }
    var bookmarkBackNavCellBackground: UIColor { return UIColor.Grey30 }

    var siteTableHeaderBorder: UIColor { return UIColor.Grey30.withAlphaComponent(0.8) }

    var topSiteDomain: UIColor { return UIColor.black }
    var topSitesGradientStart: UIColor { return UIColor.Grey10 }
    var topSitesGradientEnd: UIColor { return UIColor.Grey30 }
    var topSitesBackground: UIColor { return UIColor.Grey10 }

    var activityStreamHeaderText: UIColor { return UIColor.Grey50 }
    var activityStreamCellTitle: UIColor { return UIColor.Grey80 }
    var activityStreamCellDescription: UIColor { return UIColor.Grey60 }

    var readingListActive: UIColor { return Theme.defaultTextAndTint }
    var readingListDimmed: UIColor { return UIColor.Grey40 }

    var downloadedFileIcon: UIColor { return UIColor.Grey60 }

    var historyHeaderIconsBackground: UIColor { return UIColor.clear }

    var searchSuggestionPillBackground: UIColor { return UIColor.Grey30 }
    var searchSuggestionPillForeground: UIColor { return UIColor.Blue40 }
}

class SnackBarColor {
    var highlight: UIColor { return UIColor.TextHighlightBlue.withAlphaComponent(0.9) }
    var highlightText: UIColor { return UIColor.Blue40 }
    var border: UIColor { return UIColor.Grey30 }
    var title: UIColor { return UIColor.Blue40 }
}

class GeneralColor {
    var MobilePrivatePurple: UIColor { return UIColor.Grey70 }
    var faviconBackground: UIColor { return UIColor.Grey20 }
    var passcodeDot: UIColor { return UIColor.Grey60 }
    var highlightBlue: UIColor { return UIColor.Blue40 }
    var destructiveRed: UIColor { return UIColor.BrightRed }
    var separator: UIColor { return Theme.defaultSeparator }
    var controlTint: UIColor { return UIColor.BrightBlue }

    var settingsTextPlaceholder: UIColor? {
        if #available(iOS 13.0, *) {
            return UIColor.systemBackground
        } else {
            return nil
        }
    }
}
