/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

@testable import Client
import Shared
@testable import Storage
import UIKit

import XCTest

// This class used to contain methods for mocking syncing.
// Now it's just a stand in for BrowserProfile in the Test, because I'd prefer not to change every single test case.
class MockBrowserProfile: BrowserProfile {}
