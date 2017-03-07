//
//  UIViewController+ZomViewController.m
//  Zom
//
//  Created by Bose on 04/03/17.
//
//

#import "UIViewController+ZomViewController.h"
#import <RMessage/RMessage.h>
#import "VROShowActivity.h"


@implementation UIViewController (ZomViewController)



-(void)showWarning:(NSString *)message {
    [RMessage showNotificationWithTitle:message type:RMessageTypeWarning customTypeName:nil callback:^{
        
    }];
}

-(void)showSuccess:(NSString *)title withMessage:(NSString *)message {
    [RMessage showNotificationWithTitle:title subtitle:message type:RMessageTypeSuccess customTypeName:nil callback:^{
        
    }];
}

-(void)showError:(NSString *)title withMessage:(NSString *)message {
    [RMessage showNotificationWithTitle:title subtitle:message type:RMessageTypeError customTypeName:nil callback:^{
        
    }];
}

-(void)hideNotifications {
    [RMessage dismissActiveNotification];
}


- (void)startActivity:(BOOL)shouldDisableView {
    [[VROShowActivity shared] startActivityInView:self.view andDisabled:shouldDisableView];
}

-(void)stopActivity {
    [[VROShowActivity shared] stopActivity];
}

@end
