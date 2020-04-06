//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit

protocol TrampolineDelegate: AnyObject {
    func trampoline(startSearch query: String, fromTab tab: Tab)
}

class TrampolineTabContentScript: TabContentScript {
    weak var delegate: TrampolineDelegate?
    fileprivate weak var tab: Tab?

    required init(tab: Tab) {
        self.tab = tab
    }

    func scriptMessageHandlerName() -> String? {
        return "trampoline"
    }

    func userContentController(_ userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        guard
            let data = message.body as? [String: AnyObject],
            let query = data["query"] as? String,
            let tab = self.tab
        else { return }

        DispatchQueue.main.async {
            self.delegate?.trampoline(startSearch: query, fromTab: tab)
        }
    }

    class func name() -> String {
        return "Trampoline"
    }
}
