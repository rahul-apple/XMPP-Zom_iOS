//
//  UIViewController+ZomViewController.h
//  Zom
//
//  Created by Bose on 04/03/17.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController (ZomViewController)
-(void)showWarning:(NSString *)message;
-(void)showSuccess:(NSString *)title withMessage:(NSString *)message;
-(void)showError:(NSString *)title withMessage:(NSString *)message;
-(void)hideNotifications;
@end
