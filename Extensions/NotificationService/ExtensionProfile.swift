/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Shared

// This is a cut down version of the Profile.
// This will only ever be used in the NotificationService extension.
// It allows us to customize the SyncDelegate, and later the SyncManager.
class ExtensionProfile: BrowserProfile {
    init(localName: String) {
        super.init(localName: localName, clear: false)
    }
}

fileprivate let extensionSafeNames = Set(["clients"])

// Mock class required by `BrowserProfile`
open class PanelDataObservers {
    init(profile: Any) {}
}

// Mock class required by `BrowserProfile`
open class SearchEngines {
    init(prefs: Any, files: Any) {}
}
