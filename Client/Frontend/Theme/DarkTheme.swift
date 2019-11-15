/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation

private let defaultSeparator = UIColor.Grey60
private let defaultTextAndTint = UIColor.Grey10

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
    override var homePanel: HomePanelColor { return HomePanelColor() }
    override var snackbar: SnackBarColor { return SnackBarColor() }
    override var general: GeneralColor { return DarkGeneralColor() }
    override var actionMenu: ActionMenuColor { return ActionMenuColor() }
}
