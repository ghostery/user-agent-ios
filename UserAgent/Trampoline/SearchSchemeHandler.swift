//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit
import Shared
import UIKit

class SearchSchemeHandler: NSObject, WKURLSchemeHandler {
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let url = urlSchemeTask.request.url else {
            urlSchemeTask.didFailWithError(InternalPageSchemeHandlerError.badURL)
            return
        }

        if !urlSchemeTask.request.isPrivileged,
            urlSchemeTask.request.mainDocumentURL != urlSchemeTask.request.url,
            downloadResource(urlSchemeTask: urlSchemeTask) {
            return
        }

        let response = InternalSchemeHandler.response(forUrl: url)
        // Blank page with a color matching the background of the panels which is displayed for a split-second until the panel shows.
        let bg = Theme.browser.background.hexString
        let searchUrl = SearchURL(url)!
        let query = searchUrl.query
        let redirectUrl = searchUrl.redirectUrl
        let title = searchUrl.title
        let didRedirectParam = "redirected"
        let html = """
        <!DOCTYPE html>
            <html>
            <head>
                <meta content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" name="viewport"/>
                <meta name='apple-mobile-web-app-capable' content='yes' />
                <title>\(title)</title>
                <style>
                    html, body, #search {
                        background-color: \(bg);
                        height: 100%;
                        margin: 0;
                        font-family: -apple-system,system-ui,BlinkMacSystemFont;
                    }
                    #search {
                        display: none;
                        align-items: center;
                        justify-content: center;
                        flex-direction: column;
                    }
                    #search img {
                        width: 150px;
                        height: 150px;
                        margin-bottom: 40px;
                    }
                    #search span {
                        color: #C1C8CB;
                    }
                </style>
                <script>
                    function search() {
                        webkit.messageHandlers.trampoline.postMessage({
                            query: "\(query)",
                        });
                    }
                    function checkIfRedirected() {
                        const url = new URL(window.location.href);
                        const searchParams = new URLSearchParams(url.search);
                        return searchParams.has("\(didRedirectParam)");
                    }
                    function run() {
                        const url = new URL(window.location.href);
                        if (!checkIfRedirected()) {
                            history.replaceState(
                                {},
                                "\(title)",
                                url.search + "&\(didRedirectParam)",
                            );
                            setTimeout(() => {
                                // it takes at least two ticks for WKWebView to permanently commit visit
                                // into navigation history
                                setTimeout(() => {
                                    window.location.href = "\(redirectUrl)";
                                });
                            });
                        } else {
                            search();
                            const showUi = () => {
                                const ui = document.querySelector("#search");
                                ui.style.display = 'flex';
                            };
                            if (document.readyState !== 'complete') {
                                document.addEventListener('DOMContentLoaded', showUi);
                            } else {
                                showUi();
                            }
                        }
                    }
                    window.addEventListener('popstate', () => {
                        run();
                    });
                    run();
                </script>
            </head>
            <body>
                <div id="search">
                    <img src="search://local/trampoline.png"/>
                    <span>\(Strings.UrlBar.Placeholder)</span>
                </div>
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

    private func downloadResource(urlSchemeTask: WKURLSchemeTask) -> Bool {
        guard let url = urlSchemeTask.request.url else { return false }

        if
            url.lastPathComponent == "trampoline.png",
            let res = UIImage.templateImageNamed("trampoline"),
            let data = res.pngData()
        {
            urlSchemeTask.didReceive(URLResponse(url: url, mimeType: nil, expectedContentLength: -1, textEncodingName: nil))
            urlSchemeTask.didReceive(data)
            urlSchemeTask.didFinish()
            return true
        }

        return false
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
