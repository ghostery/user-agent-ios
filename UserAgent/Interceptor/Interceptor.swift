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
    case automaticForgetMode
}

typealias PostFactumCallback = (URL, InterceptorPolicy) -> Void

protocol InterceptorPolicy: AnyObject {
    var type: InterceptorType { get }
    func allowListUrl(_ url: URL)
    func canLoad(url: URL, onPostFactumCheck: PostFactumCallback?) -> Bool
}

protocol InterceptorDelegate: AnyObject {
    func intercept(webView: WKWebView, url: URL, policy: InterceptorPolicy)
}

class Interceptor: NSObject {
    weak var delegate: InterceptorDelegate?

    private weak var tabManager: TabManager!

    private var interceptorPolicies: [InterceptorPolicy] = []

    init(tabManager: TabManager) {
        super.init()
        self.tabManager = tabManager
    }

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

        var blocked = false
        let onPostFactumCheck: PostFactumCallback = { url, policy in
            if blocked {
                return
            }
            self.delegate?.intercept(webView: webView, url: url, policy: policy)
        }

        for policy in self.interceptorPolicies {
            switch policy.type {
            case .automaticForgetMode:
                guard let tab = tabManager[webView], !tab.isPrivate else {
                    decisionHandler(.allow)
                    return
                }
            default: break
            }
            if !policy.canLoad(url: url, onPostFactumCheck: onPostFactumCheck) {
                blocked = true
                decisionHandler(.cancel)
                return
            }
        }

        decisionHandler(.allow)
    }
}
