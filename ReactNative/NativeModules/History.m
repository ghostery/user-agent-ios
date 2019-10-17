//
//  History.m
//  Client
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(History, NSObject)

RCT_EXTERN_METHOD(getTopSites:(RCTPromiseResolveBlock)resolve reject:(RCTPromiseRejectBlock)reject)

@end
