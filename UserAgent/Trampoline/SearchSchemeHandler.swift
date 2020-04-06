//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit
import Shared

class SearchSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(InternalPageSchemeHandlerError.badURL)
            return
        }
        let response = InternalSchemeHandler.response(forUrl: url)
        // Blank page with a color matching the background of the panels which is displayed for a split-second until the panel shows.
        let bg = Theme.browser.background.hexString
        let searchUrl = SearchURL(url)!
        let title = "Search: \(searchUrl.query)"
        let html = """
        <!DOCTYPE html>
            <html style='background-color: \(bg);'>
            <head>
                <title>\(title)</title>
                <script>
                    function run() {
                        if (!history.state) {
                            history.replaceState(
                                { query: "\(searchUrl.query)" },
                                "\(title)",
                            );
                            requestAnimationFrame(() => {
                                window.location.href = "\(searchUrl.redirectUrl)";
                            });
                        } else {
                            const query = history.state.query;
                            history.replaceState(null, "\(title)");
                            webkit.messageHandlers.trampoline.postMessage({
                                query,
                            });
                        }
                    }
                    window.addEventListener('popstate', () => {
                        run();
                    });
                    run();
                </script>
            </head>
            <body>
            </body>
        </html>
        """
        guard let data = html.data(using: .utf8) else {
            urlSchemeTask.didFailWithError(InternalPageSchemeHandlerError.responderUnableToHandle)
            return
        }
        urlSchemeTask.didReceive(response)
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
