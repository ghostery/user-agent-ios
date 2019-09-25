//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

enum InterceptorType {
    case phishing
    case tracking
}

protocol InterceptorPolicy: AnyObject {
    var type: InterceptorType { get }
    func whiteListUrl(url: URL)
    func canProcessWith(url: URL, riskDetected: ((URL, InterceptorPolicy) -> Void)?) -> Bool
}

protocol InterceptorDelegate: AnyObject {
    func stopLoading(url: URL, policy: InterceptorPolicy)
}

class Interceptor: NSObject {
    weak var delegate: InterceptorDelegate?

    private var interceptorPolicies: [InterceptorPolicy] = []

    func register(policy: InterceptorPolicy) {
        interceptorPolicies.append(policy)
    }
}

extension Interceptor: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }

        let riskDetected: (URL, InterceptorPolicy) -> Void = { url, policy in
            self.delegate?.stopLoading(url: url, policy: policy)
        }

        for policy in self.interceptorPolicies {
            if !policy.canProcessWith(url: url, riskDetected: riskDetected) {
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}
