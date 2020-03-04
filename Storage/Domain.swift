//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Shared

open class Domain: Identifiable {
    open var id: Int?

    public let name: String
    public let latestVisitDate: MicrosecondTimestamp

    public init(name: String, latestVisitDate: MicrosecondTimestamp, id: Int? = nil) {
        self.latestVisitDate = latestVisitDate
        self.name = name
        self.id = id
    }

    public func toDict() -> [String: Any] {
        return ["name": self.name, "latestVisitDate": self.latestVisitDate]
    }
}
