//
//  BrowserActions.m
//  Client
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BrowserActions, NSObject)

RCT_EXTERN_METHOD(openLink:(nonnull NSString *)url query:(nonnull NSString *)query)
RCT_EXTERN_METHOD(openDomain:(nonnull NSString *)name)
RCT_EXTERN_METHOD(searchHistory:(nonnull NSString *)query callback:(RCTResponseSenderBlock))
RCT_EXTERN_METHOD(hideKeyboard)
RCT_EXTERN_METHOD(startSearch:(nonnull NSString *)query)
RCT_EXTERN_METHOD(showQuerySuggestions:(nullable NSString *)query suggestions:(nullable NSArray*)suggestions)
RCT_EXTERN_METHOD(getQuerySuggestions:(NSString)query
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
@end
