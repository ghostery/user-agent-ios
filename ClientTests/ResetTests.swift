/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client
import Shared
@testable import Storage
import UIKit

import XCTest

class MockBrowserProfile: BrowserProfile {
    var peekTabs: SQLiteRemoteClientsAndTabs {
        return self.remoteClientsAndTabs as! SQLiteRemoteClientsAndTabs
    }
}


func assertClientsHaveGUIDsFromStorage(_ storage: RemoteClientsAndTabs, expected: [GUID]) {
    let recs = storage.getClients().value.successValue
    XCTAssertNotNil(recs)
    XCTAssertEqual(expected, recs!.map { $0.guid! })
}
