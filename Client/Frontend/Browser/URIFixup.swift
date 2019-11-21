/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

class URIFixup {
    static func getURL(_ entry: String) -> URL? {
        if let url = URL(string: entry), InternalURL.isValid(url: url) {
            return URL(string: entry)
        }

        let trimmed = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var escaped = trimmed.addingPercentEncoding(withAllowedCharacters: .URLAllowed) else {
            return nil
        }
        escaped = replaceBrackets(url: escaped)

        // Then check if the URL includes a scheme. This will handle
        // all valid requests starting with "http://", "about:", etc.
        // However, we ensure that the scheme is one that is listed in
        // the official URI scheme list, so that other such search phrases
        // like "filetype:" are recognised as searches rather than URLs.
        if let url = URLComponents(string: escaped)?.url, url.schemeIsValid {
            return url
        }

        // If there's no scheme, we're going to prepend "http://". First,
        // make sure there's at least one "." in the host. This means
        // we'll allow single-word searches (e.g., "foo") at the expense
        // of breaking single-word hosts without a scheme (e.g., "localhost").
        if trimmed.range(of: ".") == nil {
            return nil
        }

        if trimmed.range(of: " ") != nil {
            return nil
        }

        // If there is a ".", prepend "http://" and try again. Since this
        // is strictly an "http://" URL, we also require a host.
        if let url = URLComponents(string: "http://\(escaped)")?.url, url.host != nil {
            return url
        }

        return nil
    }

    static func replaceBrackets(url: String) -> String {
        return url.replacingOccurrences(of: "[", with: "%5B").replacingOccurrences(of: "]", with: "%5D")
    }
}
