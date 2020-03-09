//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ContextMenu, NSObject)

RCT_EXTERN_METHOD(speedDial:(nonnull NSString *)url isPinned:(BOOL)isPinned)
RCT_EXTERN_METHOD(result:(nonnull NSString *)url
                  title:(nonnull NSString)title
                  isHistory:(BOOL)isHistory
                  query:(nonnull NSString)query)
RCT_EXTERN_METHOD(visit:(nonnull NSString *)url
                  title:(nonnull NSString)title
                  isHistory:(BOOL)isHistory
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

@end
