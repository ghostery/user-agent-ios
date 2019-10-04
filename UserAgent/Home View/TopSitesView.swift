//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import UIKit
import React
import Shared
import Storage

/// Displays Top Sites and Pinned Sites in a React Native View
class TopSitesView: UIView {
    // MARK: - Properties
    var profile: Profile

    // MARK: - Initialization
    init(profile: Profile) {
        self.profile = profile
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        fatalError("Use init(profile:) to initialize")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(profile:) to initialize")
    }
}

// MARK: - Private Implementation
private extension TopSitesView {
    private func setup() {
        profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: true)

        _ = profile.history.getTopSitesWithLimit(8).both(
            profile.history.getPinnedTopSites()
            ).bindQueue(.main) { (topSites, pinned) -> Success in
                self.addHomeView(
                    speedDials: topSites.successValue?.asArray() ?? [],
                    pinnedSites: pinned.successValue?.asArray() ?? []
                )
                return succeed()
        }
    }

    private func addHomeView(speedDials: [Site], pinnedSites: [Site]) {
        func toDial(site: Site) -> [String: String] {
            return [
                "url": site.url,
                "title": site.title,
            ]
        }

        let topSitesView = RCTRootView(
            bridge: ReactNativeBridge.sharedInstance.bridge,
            moduleName: "Home",
            initialProperties: [
                "speedDials": speedDials.map(toDial),
                "pinnedSites": pinnedSites.map(toDial),
            ]
        )

        guard let homeView = topSitesView else { return }

        addSubview(homeView)

        homeView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }
    }
}
