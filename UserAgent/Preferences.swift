//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import Shared

struct Pref<T> {
    var key: String
    var defaultValue: T

    private let prefix = "profile."

    var prefName: String {
        self.prefix + self.key
    }

    func get() -> T {
        guard let value = Preference.store.object(forKey: self.prefName) as? T else {
            return self.defaultValue
        }
        return value
    }
}

enum Preference {
    public static var store: UserDefaults {
        return UserDefaults(suiteName: AppInfo.sharedContainerIdentifier)!
    }

    public static let SendUsageData = Pref<Bool>(
        key: "settings.sendUsageData",
        defaultValue: true)
}
