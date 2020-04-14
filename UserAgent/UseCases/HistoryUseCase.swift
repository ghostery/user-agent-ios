//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation
import WebKit
import CoreSpotlight

class HistoryUseCase {
    private let profile: Profile
    private weak var viewController: UseCasesPresentationViewController?

    init(profile: Profile, viewController: UseCasesPresentationViewController?) {
        self.profile = profile
        self.viewController = viewController
    }

    func deleteAllTracesOfDomain(_ domainName: String, completion: @escaping () -> Void) {
        self.profile.history.removeAllTracesForDomain(domainName).uponQueue(.main) { result in
            CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainName])
            WKWebsiteDataStore.default().fetchDataRecords(ofTypes: CookiesClearable.dataTypes) { (records) in
                let filteredRecords = records.filter({ $0.displayName.contains(domainName) })
                WKWebsiteDataStore.default().removeData(ofTypes: CookiesClearable.dataTypes, for: filteredRecords) {
                    completion()
                }
            }
            self.viewController?.showWipeAllTracesContextualOnboarding()
        }
    }
}
