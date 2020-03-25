//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Intents

class IntentHandler: INExtension {

    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        if intent is SearchWithQliqzIntent {
            return SearchWithQliqzHandling()
        }
        return self
    }

}

class SearchWithQliqzHandling: NSObject, SearchWithQliqzIntentHandling {

    func resolveQuery(for intent: SearchWithQliqzIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        print(intent.query ?? "Empty")
        guard let query = intent.query, !query.isEmpty else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        print(query)
        completion(.success(with: query))
    }

    func handle(intent: SearchWithQliqzIntent, completion: @escaping (SearchWithQliqzIntentResponse) -> Void) {
        print(intent.query ?? "Empty handle")
        guard let query = intent.query, !query.isEmpty else {
            completion(.init(code: .unspecified, userActivity: nil))
            return
        }
        let activity = NSUserActivity(activityType: "org.cliqz.searchWithQliqz")
        activity.userInfo = ["query": query]
        completion(SearchWithQliqzIntentResponse(code: .continueInApp, userActivity: activity))
    }

    func confirm(intent: SearchWithQliqzIntent, completion: @escaping (SearchWithQliqzIntentResponse) -> Void) {
        print(intent.query ?? "Empty confirm")
        guard let query = intent.query, !query.isEmpty else {
            completion(.init(code: .failure, userActivity: nil))
            return
        }
        completion(.init(code: .success, userActivity: nil))
    }

}
