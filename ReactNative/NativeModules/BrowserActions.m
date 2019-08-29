//
//  Tabs.m
//  Client
//
//  Created by Krzysztof Modras on 28.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

// CalendarManagerBridge.m
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(BrowserActions, NSObject)

RCT_EXTERN_METHOD(openLink:(nonnull NSString *)url query:(nonnull NSString *)query isSearchEngine:(BOOL)isSearchEngine)
RCT_EXTERN_METHOD(searchHistory:(nonnull NSString *)query callback:(RCTResponseSenderBlock))

@end