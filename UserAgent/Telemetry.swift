//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

class Telemetry {
    static func reportReaderMode() {
        send(signal: ["component": "urlbar", "view": "page-actions", "target": "reader-mode", "action": "click"],
             schema: "ui.metric.interaction")
    }
}

extension Telemetry: BrowserCoreClient {
    private static func send(signal: [String: Any], schema: String) {
        browserCore.callAction(
            module: "core",
            action: "sendTelemetry",
            args: [signal, false, schema]
        )
    }
}
