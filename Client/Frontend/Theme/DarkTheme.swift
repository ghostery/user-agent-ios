/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

private let defaultSeparator = UIColor.Grey60
private let defaultTextAndTint = UIColor.Grey10

private class DarkHomePanelColor: HomePanelColor {
    override var toolbarBackground: UIColor { return UIColor.defaultBackground }
    override var toolbarHighlight: UIColor { return UIColor.Blue40 }
    override var toolbarTint: UIColor { return UIColor.Grey30 }
    override var panelBackground: UIColor { return UIColor.defaultBackground }
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

class DarkTheme: Theme {
    override var name: String { return BuiltinThemeName.dark.rawValue }
    override var tableView: TableViewColor { return TableViewColor() }
    override var urlbar: URLBarColor { return URLBarColor() }
    override var browser: BrowserColor { return BrowserColor() }
    override var toolbarButton: ToolbarButtonColor { return ToolbarButtonColor() }
    override var tabTray: TabTrayColor { return TabTrayColor() }
    override var topTabs: TopTabsColor { return TopTabsColor() }
    override var textField: TextFieldColor { return TextFieldColor() }
    override var homePanel: HomePanelColor { return DarkHomePanelColor() }
    override var snackbar: SnackBarColor { return DarkSnackBarColor() }
    override var general: GeneralColor { return DarkGeneralColor() }
    override var actionMenu: ActionMenuColor { return ActionMenuColor() }
}
