//
//  ZomTheme.h
//  ChatSecure
//
//  Created by Christopher Ballinger on 6/10/15.
//  Copyright (c) 2015 Chris Ballinger. All rights reserved.
//

#define DEFAULT_ZOM_COLOR @"#FF00B371"

@import ChatSecureCore;

@interface ZomTheme : OTRTheme

- (void) selectMainThemeColor:(UIColor*)color;
+ (UIColor*) colorWithHexString:(NSString*)hexColorString;
@end
