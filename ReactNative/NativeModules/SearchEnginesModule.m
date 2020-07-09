//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RCT_EXTERN_MODULE(SearchEnginesModule, NSObject)
RCT_EXTERN_METHOD(getSearchEngines:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)
@end
