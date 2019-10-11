//
//  JSBridge.m
//  Client
//
//  Created by Krzysztof Modras on 29.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(JSBridge, RCTEventEmitter)
RCT_EXTERN_METHOD(ready)
RCT_EXTERN_METHOD(replyToAction:(nonnull NSInteger *)actionId result:(NSDictionary *)result)
@end
