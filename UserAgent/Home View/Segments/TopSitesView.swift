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
class TopSitesView: BaseReactHomeView {
    override func setup() {
        profile.panelDataObservers.activityStream.refreshIfNeeded(forceTopSites: false, completion: nil)
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

            let homeView = HomeView(
                toolbarHeight: self.toolbarHeight,
                speedDials: speedDials,
                pinnedSites: pinned.successValue?.asArray() ?? [],
                isNewsEnabled: Features.News.isEnabled && (self.profile.prefs.boolForKey(PrefsKeys.NewTabNewsEnabled) ?? true),
                isNewsImagesEnabled: Features.News.isEnabled && (self.profile.prefs.boolForKey(PrefsKeys.NewTabNewsImagesEnabled) ?? true)
            )

            self.addSubview(homeView)

            homeView.snp.makeConstraints { make in
                make.bottom.top.leading.trailing.equalTo(self)
            }

            self.reactView = homeView

            return succeed()
        }
    }
}
