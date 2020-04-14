//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Storage
import Shared

private struct MozActionParams: Codable {
    var url: String
}

class OpenLinkUseCases {

    private let tabManager: TabManager
    private (set) weak var viewController: UseCasesPresentationViewController?
    private let profile: Profile

    init(profile: Profile, tabManager: TabManager, viewController: UseCasesPresentationViewController?) {
        self.profile = profile
        self.tabManager = tabManager
        self.viewController = viewController
    }

    // MARK: - Open Link Methods

    func openLink(urlString: String, query: String) {
        var url: URL?

        if urlString.hasPrefix("moz-action:") {
            let decoder = JSONDecoder()
            let mozActionComponents = urlString.components(separatedBy: ",")

            guard
                let mozActionData = mozActionComponents[1].data(using: .ascii),
                let mozActionParams = try? decoder.decode(MozActionParams.self, from: mozActionData)
                else { return }

            url = URL(string: mozActionParams.url)

            guard let url = url else { return }
            self.viewController?.switchOrOpenTabWithURL(url)
            return
        }

        if let selectedUrl = URL(string: urlString as String) {
            url = selectedUrl
        } else if let encodedString = urlString.addingPercentEncoding(
            withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {
            url = URL(string: encodedString)
        }

        if let url = url {
            self.openLink(url: url, visitType: .link, query: query)
        }
    }

    func openLink(url: URL, visitType: VisitType, query: String) {
        guard let tab = self.tabManager.selectedTab else {
            return
        }
        var finalUrl: URL!

        if self.profile.searchEngines.isSearchEngineRedirectURL(url: url, query: query) || query.isEmpty {
            finalUrl = url
        } else {
            let searchUrl = SearchURL(
                domain: url.host ?? "",
                redirectUrl: url.absoluteString,
                query: query)
            finalUrl = searchUrl.url
        }
        self.viewController?.submitURL(finalUrl, visitType: visitType, forTab: tab)
    }

    // MARK: - New Tab Methods

    func openNewTab(url: URL? = nil) {
        guard let url = url else { return }
        self.viewController?.openURLInNewTab(url, isPrivate: false)
    }

    // MARK: - New Forget Mode Tab Methods

    func openNewForgetModeTab(url: URL? = nil) {
        guard let url = url else { return }
        self.viewController?.openURLInNewTab(url, isPrivate: true)
    }

}
