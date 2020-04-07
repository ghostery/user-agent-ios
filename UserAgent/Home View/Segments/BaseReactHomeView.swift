//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

/// Displays Top Sites and Pinned Sites in a React Native View
class BaseReactHomeView: UIView {
    // MARK: - Properties
    internal var profile: Profile
    internal let toolbarHeight: CGFloat

    internal var reactView: UIView?

    // MARK: - Initialization
    init(profile: Profile, toolbarHeight: CGFloat) {
        self.profile = profile
        self.toolbarHeight = toolbarHeight
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        fatalError("Use init(profile:) to initialize")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(profile:) to initialize")
    }

    func reloadData() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        self.setup()
    }

    func setup() {

    }
}
