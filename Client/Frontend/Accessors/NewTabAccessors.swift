/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import XCGLogger

///// Enum to encode what should happen when the user opens a new tab without a URL.
enum NewTabPage: String {
    case topSites = "TopSites"

    var settingTitle: String {
        switch self {
        case .topSites:
            return Strings.Settings.NewTab.TopSites
        }
    }

    var homePanelType: HomePanelType? {
        switch self {
        case .topSites:
            return HomePanelType.topSites
        }
    }

    var url: URL? {
        guard let homePanel = self.homePanelType else {
            return nil
        }
        return homePanel.internalUrl as URL
    }

    static func fromAboutHomeURL(url: URL) -> NewTabPage? {
        guard let internalUrl = InternalURL(url), internalUrl.isAboutHomeURL else { return nil}
        guard let panelNumber = url.fragment?.split(separator: "=").last else { return nil }
        switch panelNumber {
        case "0":
            return NewTabPage.topSites
        default:
            return nil
        }
    }

}
