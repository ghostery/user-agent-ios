//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

protocol InterceptorPolicy {
    func canProcessWith(url: URL, completion:(() -> Void)?) -> Bool
}

class Interceptor: NSObject {
    private var interceptorPolicies: [InterceptorPolicy] = []

    func register(policy: InterceptorPolicy) {
        interceptorPolicies.append(policy)
    }

    private func canProcessWith(url: URL, completion:(() -> Void)?) -> Bool {
        for policy in self.interceptorPolicies {
            if !policy.canProcessWith(url: url, completion: nil) {
                return false
            }
        }
        return true
    }
}

extension Interceptor: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        for policy in self.interceptorPolicies {
            if !policy.canProcessWith(url: url, completion: nil) {
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}
