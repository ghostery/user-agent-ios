//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_REMAP_MODULE(InsightsFeature, InsightsFeatureReactNativeModule, NSObject)

RCT_EXTERN_METHOD(getTabsState:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
