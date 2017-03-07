//
//  VROShowActivity.m
//  Vro
//
//  Created by Anand R Nair on 26/09/14.
//  Copyright (c) 2014 Nagainfo Solutions. All rights reserved.
//

#import "VROShowActivity.h"
#import <MONActivityIndicatorView/MONActivityIndicatorView.h>

@interface VROShowActivity ()<MONActivityIndicatorViewDelegate>

@property (nonatomic,strong) MONActivityIndicatorView *indicatorView;
@property (nonatomic) UIView *parentView;

@end

@implementation VROShowActivity
@synthesize indicatorView;

+ (instancetype)shared
{
    static id instance_ = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance_ = [[self alloc] init];
    });
    
    return instance_;
}

-(instancetype)init {
    self = [super init];
    if(self)
    {
        indicatorView = [[MONActivityIndicatorView alloc] init];
        indicatorView.numberOfCircles = 3;
        indicatorView.radius = 10;
        indicatorView.internalSpacing = 3;
        indicatorView.duration = 0.3;
        indicatorView.delay = 0.1;
        indicatorView.delegate = self;
    }
    return self;
}

//- (id) initWithView:(UIView *)view
//{
//    self = [super init];
//    // self = [VROShowActivity shared];
//    if(self)
//    {
//        self.parentView = view;
//        indicatorView = [[MONActivityIndicatorView alloc] init];
//        indicatorView.numberOfCircles = 3;
//        indicatorView.radius = 10;
//        indicatorView.internalSpacing = 3;
//        indicatorView.duration = 0.3;
//        indicatorView.delay = 0.1;
//        indicatorView.delegate = self;
//        indicatorView.center = view.center;
//        [view addSubview:indicatorView];
//        [self placeAtTheCenterWithView:indicatorView];
//    }
//    return self;
//}


- (void)placeAtTheCenterWithView:(UIView *)view {
    [self.parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.parentView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0f
                                                           constant:0.0f]];
    
    [self.parentView addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.parentView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0f
                                                           constant:0.0f]];
}

- (void)bringViewToFront
{
    [indicatorView.superview bringSubviewToFront:indicatorView];
}

- (void)startActivityInView:(UIView *)view  andDisabled:(BOOL)shouldDisableView {
    self.parentView = view;
    indicatorView.center = view.center;
    [view addSubview:indicatorView];
    [self placeAtTheCenterWithView:indicatorView];
    [self startActivity:shouldDisableView];
}



- (void)startActivity:(BOOL)shouldDisableView
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [self bringViewToFront];
                       [indicatorView.superview bringSubviewToFront:indicatorView];
                       [indicatorView.superview setUserInteractionEnabled:!shouldDisableView];
                       [self bringViewToFront];
                       indicatorView.hidden = false;
                       [indicatorView startAnimating];
                       [self performSelector:@selector(stopActivity) withObject:nil afterDelay:40];
                   });
}

- (void)stopActivity
{
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [indicatorView.superview setUserInteractionEnabled:true];
                       indicatorView.hidden = true;
                       [indicatorView stopAnimating];
                       [UIViewController cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopActivity) object:nil];
                       [indicatorView removeFromSuperview];
                   });
}

#pragma mark - Indicator
- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    // For a random background color for a particular circle
    
    UIColor *blue = [UIColor colorWithRed:(88/255.0) green:(194/255.0) blue:(194/255.0) alpha:1.0];
    UIColor *orange = [UIColor colorWithRed:(237/255.0) green:(89/255.0) blue:(49/255.0) alpha:1.0];
    UIColor *green = [UIColor colorWithRed:(152/255.0) green:(200/255.0) blue:(78/255.0) alpha:1.0];
    
    NSArray *colors=@[blue, orange, green];
    
    return colors[index];
    
}

@end
