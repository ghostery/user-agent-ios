//
// Copyright (c) 2017-2020 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>
#import <Client-Swift.h>

@interface NativeFavicon : RCTViewManager

@end

@implementation NativeFavicon

RCT_EXPORT_MODULE()

- (UIImageView *)view {
    UIImageView* view = [[UIImageView alloc] init];
    return view;
}

RCT_CUSTOM_VIEW_PROPERTY(url, NSString, UIImageView) {
    NSString *url_str = (NSString*)json;
    [NativeFaviconFetcher fetchImageWithUrl:url_str completion:^(UIImage * _Nonnull image) {
        view.image = image;
    }];
}

@end
