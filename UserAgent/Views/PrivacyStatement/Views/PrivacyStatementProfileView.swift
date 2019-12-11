//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit

class PrivacyStatementProfileView: UIView {

    let profile: PrivacyStatementProfile
    init(profile: PrivacyStatementProfile) {
        self.profile = profile
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setup() {
        // TODO: setup screens to show profile
    }
}
