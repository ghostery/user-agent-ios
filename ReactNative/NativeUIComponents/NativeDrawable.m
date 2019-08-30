//
//  NativeDrawable.m
//  Client
//
//  Created by Krzysztof Modras on 29.08.19.
//  Copyright © 2019 Cliqz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <React/RCTViewManager.h>

@interface NativeDrawableImageView : UIImageView
@property BOOL hasTint;
@end

@implementation NativeDrawableImageView
@end

@interface NativeDrawable : RCTViewManager
@end

@implementation NativeDrawable

RCT_EXPORT_MODULE()

- (UIImageView *)view {
    NativeDrawableImageView* imageView = [[NativeDrawableImageView alloc] init];
    [imageView setContentMode:UIViewContentModeScaleAspectFit];
    return imageView;
}

RCT_CUSTOM_VIEW_PROPERTY(color, NSString, UIImageView) {
    NSString *color_str = (NSString*)json;
    UIColor* uicolor = [NativeDrawable colorFromHexString:color_str];
    if (uicolor) {
        view.image = [view.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [view setTintColor: uicolor];
        [(NativeDrawableImageView*)view setHasTint:YES];
    } else {
        NSLog(@"color %@ is not valid", json);
    }
}

RCT_CUSTOM_VIEW_PROPERTY(source, NSString, UIImageView) {
    NSString *imageName = (NSString*)json;
    if (imageName) {
        UIImage* image = [UIImage imageNamed:imageName];
        if (((NativeDrawableImageView*) view).hasTint) {
            image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }

        if (image) {
            [view setImage:image];
        } else {
            NSLog(@"image %@ is missing", imageName);
        }
    }
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
