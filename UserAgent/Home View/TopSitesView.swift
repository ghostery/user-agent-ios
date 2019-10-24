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

/// Displays Top Sites and Pinned Sites in a React Native View
class TopSitesView: UIView {
    // MARK: - Properties
    var profile: Profile

    private var homeView: HomeView?

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
                let speedDials = (topSites.successValue?.asArray() ?? []).map { site -> Site? in
                    guard
                        let url = URL(string: site.url),
                        let scheme = url.scheme,
                        let host = url.host
                    else { return nil }
                    return Site(url: "\(scheme)://\(host)/", title: site.title)
                }.compactMap { $0 }

                self.addHomeView(
                    speedDials: speedDials,
                    pinnedSites: pinned.successValue?.asArray() ?? []
                )
                return succeed()
        }
    }

    private func addHomeView(speedDials: [Site], pinnedSites: [Site]) {
        let homeView = HomeView(speedDials: speedDials, pinnedSites: pinnedSites)

        addSubview(homeView)

        homeView.snp.makeConstraints { make in
            make.bottom.top.leading.trailing.equalTo(self)
        }

        self.homeView = homeView
    }
}

// MARK: - Themeable
extension TopSitesView: Themeable {
    func applyTheme() {
        self.homeView?.applyTheme()
    }
}
