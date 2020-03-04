//
//  History.m
//  Client
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(History, NSObject)

RCT_EXTERN_METHOD(getTopSites:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(removeDomain:(NSString)domainName
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getDomains:(NSInteger)limit
                  offset:(NSInteger)offset
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
RCT_EXTERN_METHOD(getVisits:(NSString)domainName
                  limit:(NSInteger)limit
                  offset:(NSInteger)offset
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)

@end
