//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

protocol InterceptorUI: class {
    func showAntiPhishingAlert(tab: Tab, url: URL, policy: InterceptorPolicy)
}

class InterceptorFeature {
    private let interceptor: Interceptor!
    private weak var tabManager: TabManager!
    private weak var ui: InterceptorUI!
    private var useCases: UseCases

    init(tabManager: TabManager, ui: InterceptorUI, useCases: UseCases) {
        self.useCases = useCases
        self.interceptor = Interceptor(tabManager: tabManager)
        self.interceptor.delegate = self
        self.tabManager = tabManager
        self.tabManager.addNavigationDelegate(self.interceptor)
        self.ui = ui
        self.registerInterceptors()
    }

    // MARK: Private methods
    private func registerInterceptors() {
        self.interceptor.register(policy: AntiPhishingPolicy())
        self.interceptor.register(policy: AutomaticForgetModePolicy())
    }
}

extension InterceptorFeature: InterceptorDelegate {
    func intercept(webView: WKWebView, url: URL, policy: InterceptorPolicy) {
        guard let tab = tabManager[webView] else {
            return
        }
        tab.stop()
        switch policy.type {
        case .phishing:
            ui.showAntiPhishingAlert(tab: tab, url: url, policy: policy)
        case .automaticForgetMode:
            self.useCases.openLink.openNewForgetModeTab(url: url)
            self.useCases.viewController?.showAutomaticForgetModeContextualOnboarding()
            if let query = url.getQuery()["query"] {
                self.useCases.viewController?.removeQueryFromQueryList(query)
            }
        default:
            break
        }
    }
}
