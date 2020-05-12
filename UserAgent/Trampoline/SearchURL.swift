//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

public struct SearchURL {
    public static let queryItemNameQuery = "query"
    public static let queryItemNameRedirectUrl = "redirectUrl"
    public static let queryItemNameIsRedirected = "redirected"

    public static let scheme = "search"

    public let url: URL

    public static func isValid(url: URL?) -> Bool {
        if url == nil {
            return false
        }
        return Self.scheme == url?.scheme
    }

    public init(domain: String, redirectUrl: String, query: String) {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = domain
        components.queryItems = [
            URLQueryItem(name: Self.queryItemNameRedirectUrl,
                         value: redirectUrl),
            URLQueryItem(name: Self.queryItemNameQuery,
                         value: query),
        ]
        self.url = components.url!
    }

    public init?(_ url: URL) {
        guard SearchURL.isValid(url: url) else {
            return nil
        }

        self.url = url
    }

    public var redirectUrl: String {
        return (self.url.getQuery()[Self.queryItemNameRedirectUrl] ?? "").removingPercentEncoding ?? ""
    }

    public var query: String {
        return (self.url.getQuery()[Self.queryItemNameQuery] ?? "").removingPercentEncoding ?? ""
    }

    public var title: String {
        return "Search: \(self.query)"
    }

    public var isRedirected: Bool {
        guard
            let components = URLComponents(url: self.url, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else { return false }
        return queryItems.contains(URLQueryItem(name: Self.queryItemNameIsRedirected, value: nil))
    }
}
