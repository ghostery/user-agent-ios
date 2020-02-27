//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Storage

private struct MozActionParams: Codable {
    var url: String
}

class OpenLinkUseCases {

    private let tabManager: TabManager
    private let browserViewController: BrowserViewController

    init(tabManager: TabManager, browserViewController: BrowserViewController) {
        self.tabManager = tabManager
        self.browserViewController = browserViewController
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
            self.browserViewController.switchToTabForURLOrOpen(url, isPrivileged: true)
            return
        }

        if let selectedUrl = URL(string: urlString as String) {
            url = selectedUrl
        } else if let encodedString = urlString.addingPercentEncoding(
            withAllowedCharacters: NSCharacterSet.urlFragmentAllowed) {
            url = URL(string: encodedString)
        }

        if let url = url {
            self.openLink(url: url, query: query)
        }
    }

    func openLink(url: URL, query: String) {
        guard let tab = self.tabManager.selectedTab else {
            return
        }
        self.browserViewController.finishEditingAndSubmit(url, visitType: VisitType.link, forTab: tab)
        if !query.isEmpty {
            tab.queries[url] = String(query)
        }
    }

    // MARK: - New Tab Methods

    func openNewTab(url: URL? = nil) {
        guard let url = url else { return }
        self.browserViewController.switchToTabForURLOrOpen(url, isPrivate: false, isPrivileged: true)
    }

    // MARK: - New Private Tab Methods

    func openNewPrivateTab(url: URL? = nil) {
        guard let url = url else { return }
        self.browserViewController.switchToTabForURLOrOpen(url, isPrivate: true, isPrivileged: true)
    }

}
