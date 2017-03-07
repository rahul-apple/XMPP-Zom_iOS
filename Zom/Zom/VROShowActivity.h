//
//  VROShowActivity.h
//  Vro
//
//  Created by Anand R Nair on 26/09/14.
//  Copyright (c) 2014 Nagainfo Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface VROShowActivity : NSObject

+ (instancetype)shared;

- (void)startActivityInView:(UIView *)view  andDisabled:(BOOL)shouldDisableView;
- (void)stopActivity;
//- (id) initWithView:(UIView *)view;
- (void)bringViewToFront;
@end
