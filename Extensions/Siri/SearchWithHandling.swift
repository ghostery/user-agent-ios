//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Intents

class SearchWithHandling: NSObject, SearchWithIntentHandling {

    func resolveQuery(for intent: SearchWithIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let query = intent.query, !query.isEmpty else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(.success(with: query))
    }

    func handle(intent: SearchWithIntent, completion: @escaping (SearchWithIntentResponse) -> Void) {
        guard let query = intent.query, !query.isEmpty else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        let activity = NSUserActivity(activityType: SiriActivityTypes.searchWith.rawValue)
        activity.userInfo = ["query": query]
        completion(SearchWithIntentResponse(code: .continueInApp, userActivity: activity))
    }

    func confirm(intent: SearchWithIntent, completion: @escaping (SearchWithIntentResponse) -> Void) {
        guard let query = intent.query, !query.isEmpty else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        completion(.init(code: .success, userActivity: nil))
    }

}
