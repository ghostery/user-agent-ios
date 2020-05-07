/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Storage

import Shared
import XCGLogger

enum ShortcutType: String {
    case newTab = "NewTab"
    case newPrivateTab = "NewPrivateTab"

    init?(fullType: String) {
        guard let last = fullType.components(separatedBy: ".").last else { return nil }

        self.init(rawValue: last)
    }

    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
}

protocol QuickActionHandlerDelegate {
    func handleShortCutItemType(_ type: ShortcutType, userData: [String: NSSecureCoding]?)
}

class QuickActions: NSObject {

    fileprivate let log = Logger.browserLogger

    static let QuickActionsVersion = "1.0"
    static let QuickActionsVersionKey = "dynamicQuickActionsVersion"

    static let TabURLKey = "url"
    static let TabTitleKey = "title"

    static var sharedInstance = QuickActions()

    var launchedShortcutItem: UIApplicationShortcutItem?

    // MARK: Handling Quick Actions
    @discardableResult
    func canHandleShortCutItem(_ shortcutItem: UIApplicationShortcutItem ) -> Bool {

        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard let _ = ShortcutType(fullType: shortcutItem.type) else { return false }

        return true
    }

    func handleShortCutItem(_ shortcutItem: UIApplicationShortcutItem, withBrowserViewController bvc: BrowserViewController ) {

        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard let shortCutType = ShortcutType(fullType: shortcutItem.type) else { return }

        DispatchQueue.main.async {
            self.handleShortCutItemOfType(shortCutType, userData: shortcutItem.userInfo, browserViewController: bvc)
        }
    }

    func filterOutUnsupportedShortcutItems(application: UIApplication) {
        application.shortcutItems = application.shortcutItems?.filter({ (item) -> Bool in
            return ShortcutType(fullType: item.type) != nil
        })
    }

    // MARK: - Private methods

    fileprivate func handleShortCutItemOfType(_ type: ShortcutType, userData: [String: NSSecureCoding]?, browserViewController: BrowserViewController) {
        switch type {
        case .newTab:
            handleOpenNewTab(withBrowserViewController: browserViewController, isPrivate: false)
        case .newPrivateTab:
            handleOpenNewTab(withBrowserViewController: browserViewController, isPrivate: true)
        }
    }

    fileprivate func handleOpenNewTab(withBrowserViewController bvc: BrowserViewController, isPrivate: Bool) {
        bvc.openBlankNewTab(focusLocationField: true, isPrivate: isPrivate)
    }

    fileprivate func handleOpenURL(withBrowserViewController bvc: BrowserViewController, urlToOpen: URL) {
        // open bookmark in a non-private browsing tab
        bvc.switchToPrivacyMode(isPrivate: false)

        // find out if bookmarked URL is currently open
        // if so, open to that tab,
        // otherwise, create a new tab with the bookmarked URL
        bvc.switchToTabForURLOrOpen(urlToOpen, isPrivileged: true)
    }
}
