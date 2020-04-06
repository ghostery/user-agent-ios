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
                    }
                    #search {
                        display: none;
                        align-items: center;
                        justify-content: center;
                        flex-direction: column;
                    }
                </style>
                <script>
                    function search() {
                        webkit.messageHandlers.trampoline.postMessage({
                            query: "\(searchUrl.query)",
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
                            requestAnimationFrame(() => {
                                window.location.href = "\(searchUrl.redirectUrl)";
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
                    <button onclick="search()">Search for "\(searchUrl.query)"</button>
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

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {}
}
