//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import Shared
import Storage

class HistoryView: BaseReactHomeView {
    override func setup() {
        let view = DomainsView(toolbarHeight: self.toolbarHeight)

        addSubview(view)

        view.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }

        self.reactView = view
    }
}
