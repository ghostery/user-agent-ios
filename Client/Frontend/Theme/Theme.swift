/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
import Foundation

protocol Themeable: AnyObject {
    func applyTheme()
}

protocol PrivateModeUI {
    func applyUIMode(isPrivate: Bool)
}

extension UIColor {
    static var theme: Themeprotocol {
        return ThemeManager.instance.current
    }
}

enum BuiltinThemeName: String {
    case normal
    case dark
}

private let defaultSeparator = UIColor.Grey40
private let defaultTextAndTint = UIColor.Grey80

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
            return defaultSeparator
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
    var syncText: UIColor { return defaultTextAndTint }
    var errorText: UIColor { return UIColor.BrightRed }
    var warningText: UIColor { return UIColor.Orange }
}

class ActionMenuColor {
    var separatorColor: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray2
        } else {
            // Fallback on earlier versions
            return defaultTextAndTint
        }
    }
    var foreground: UIColor { return defaultTextAndTint }
    var iPhoneBackgroundBlurStyle: UIBlurEffect.Style { return UIBlurEffect.Style.light }
    var iPhoneBackground: UIColor { return UIColor.theme.browser.background.withAlphaComponent(0.9) }
    var closeButtonBackground: UIColor { return UIColor.defaultBackground }
    var closeButtonTitleColor: UIColor { return UIColor.BrightBlue }
}

class URLBarColor {
    var border: UIColor { return UIColor.Grey90.with(alpha: .tenPercent) }
    func activeBorder(_ isPrivate: Bool) -> UIColor {
        return !isPrivate ? UIColor.CliqzBlue.with(alpha: .eightyPercent) : UIColor.Defaults.MobilePrivatePurple
    }
    var tint: UIColor { return UIColor.Blue40.with(alpha: .thirtyPercent) }
    var background: UIColor {
        return UIColor.systemGray.withAlphaComponent(0.15)
    }
    // This text selection color is used in two ways:
    // 1) <UILabel>.background = textSelectionHighlight.withAlphaComponent(textSelectionHighlightAlpha)
    // To simulate text highlighting when the URL bar is tapped once, this is a background color to create a simulated selected text effect. The color will have an alpha applied when assigning it to the background.
    // 2) <UITextField>.tintColor = textSelectionHighlight.
    // When the text is in edit mode (tapping URL bar second time), this is assigned to the to set the selection (and cursor) color. The color is assigned directly to the tintColor.
    typealias TextSelectionHighlight = (labelMode: UIColor, textFieldMode: UIColor?)
    func textSelectionHighlight(_ isPrivate: Bool) -> TextSelectionHighlight {
        if isPrivate {
            let color = UIColor.Defaults.MobilePrivatePurple
            return (labelMode: color.withAlphaComponent(0.25), textFieldMode: color)
        } else {
            return (labelMode: UIColor.Defaults.iOSTextHighlightBlue, textFieldMode: nil)
        }
    }

    var readerModeButtonSelected: UIColor { return UIColor.Blue40 }
    var readerModeButtonUnselected: UIColor { return UIColor.Grey50 }
    var pageOptionsSelected: UIColor { return readerModeButtonSelected }
    var pageOptionsUnselected: UIColor { return UIColor.theme.browser.tint }
}

class BrowserColor {
    var background: UIColor { return UIColor.defaultBackground }
    var urlBarDivider: UIColor { return UIColor.Grey90.with(alpha: .tenPercent) }
    var tint: UIColor { return defaultTextAndTint }
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
    var tabTitleText: UIColor { return UIColor.black }
    var tabTitleBlur: UIBlurEffect.Style { return UIBlurEffect.Style.extraLight }
    var background: UIColor { return UIColor.Grey80 }
    var cellBackground: UIColor { return UIColor.defaultBackground }
    var toolbar: UIColor { return UIColor.defaultBackground }
    var toolbarButtonTint: UIColor { return defaultTextAndTint }
    var privateModeLearnMore: UIColor { return UIColor.Grey70 }
    var privateModePurple: UIColor { return UIColor.Grey70 }
    var privateModeButtonOffTint: UIColor { return toolbarButtonTint }
    var privateModeButtonOnTint: UIColor { return UIColor.Grey10 }
    var cellCloseButton: UIColor { return UIColor.Grey50 }
    var cellTitleBackground: UIColor { return UIColor.clear }
    var faviconTint: UIColor { return UIColor.White }
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
            return UIColor.CloudySky
        }
    }
    var backgroundInOverlay: UIColor { return UIColor.white }
    var textAndTint: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.label
        } else {
            // Fallback on earlier versions
            return defaultTextAndTint
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
            return defaultSeparator
        }
    }
    var separator: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor.systemGray4
        } else {
            // Fallback on earlier versions
            return defaultSeparator
        }
    }

    var border: UIColor { return UIColor.Grey60 }
    var buttonContainerBorder: UIColor { return separator }

    var welcomeScreenText: UIColor { return UIColor.Grey50 }
    var bookmarkIconBorder: UIColor { return UIColor.Grey30 }
    var bookmarkFolderBackground: UIColor { return UIColor.Grey10.withAlphaComponent(0.3) }
    var bookmarkFolderText: UIColor { return UIColor.Grey80 }
    var bookmarkCurrentFolderText: UIColor { return UIColor.Blue40 }
    var bookmarkBackNavCellBackground: UIColor { return UIColor.clear }

    var siteTableHeaderBorder: UIColor { return UIColor.Grey30.withAlphaComponent(0.8) }

    var topSiteDomain: UIColor { return UIColor.black }
    var topSitesGradientStart: UIColor { return UIColor.white }
    var topSitesGradientEnd: UIColor { return UIColor(rgb: 0xf8f8f8) }
    var topSitesBackground: UIColor { return UIColor.white }

    var activityStreamHeaderText: UIColor { return UIColor.Grey50 }
    var activityStreamCellTitle: UIColor { return UIColor.black }
    var activityStreamCellDescription: UIColor { return UIColor.Grey60 }

    var readingListActive: UIColor { return defaultTextAndTint }
    var readingListDimmed: UIColor { return UIColor.Grey40 }

    var downloadedFileIcon: UIColor { return UIColor.Grey60 }

    var historyHeaderIconsBackground: UIColor { return UIColor.White }

    var searchSuggestionPillBackground: UIColor { return UIColor.White }
    var searchSuggestionPillForeground: UIColor { return UIColor.Blue40 }
}

class SnackBarColor {
    var highlight: UIColor { return UIColor.Defaults.iOSTextHighlightBlue.withAlphaComponent(0.9) }
    var highlightText: UIColor { return UIColor.Blue40 }
    var border: UIColor { return UIColor.Grey30 }
    var title: UIColor { return UIColor.Blue40 }
}

class GeneralColor {
    var faviconBackground: UIColor { return UIColor.clear }
    var passcodeDot: UIColor { return UIColor.Grey60 }
    var highlightBlue: UIColor { return UIColor.Blue40 }
    var destructiveRed: UIColor { return UIColor.BrightRed }
    var separator: UIColor { return defaultSeparator }
    var settingsTextPlaceholder: UIColor? { return nil }
    var controlTint: UIColor { return UIColor.BrightBlue }
}

protocol Themeprotocol {
    var name: String { get }
    var tableView: TableViewColor { get }
    var urlbar: URLBarColor { get }
    var browser: BrowserColor { get }
    var toolbarButton: ToolbarButtonColor { get }
    var loadingBar: LoadingBarColor { get }
    var tabTray: TabTrayColor { get }
    var topTabs: TopTabsColor { get }
    var textField: TextFieldColor { get }
    var homePanel: HomePanelColor { get }
    var snackbar: SnackBarColor { get }
    var general: GeneralColor { get }
    var actionMenu: ActionMenuColor { get }
}

class Theme: Themeprotocol {
    var name: String { return BuiltinThemeName.normal.rawValue }
    var tableView: TableViewColor { return TableViewColor() }
    var urlbar: URLBarColor { return URLBarColor() }
    var browser: BrowserColor { return BrowserColor() }
    var toolbarButton: ToolbarButtonColor { return ToolbarButtonColor() }
    var loadingBar: LoadingBarColor { return LoadingBarColor() }
    var tabTray: TabTrayColor { return TabTrayColor() }
    var topTabs: TopTabsColor { return TopTabsColor() }
    var textField: TextFieldColor { return TextFieldColor() }
    var homePanel: HomePanelColor { return HomePanelColor() }
    var snackbar: SnackBarColor { return SnackBarColor() }
    var general: GeneralColor { return GeneralColor() }
    var actionMenu: ActionMenuColor { return ActionMenuColor() }
}
