//
//  ZomAppDelegate.h
//  ChatSecure
//
//  Created by Christopher Ballinger on 6/10/15.
//  Copyright (c) 2015 Chris Ballinger. All rights reserved.
//

@import ChatSecureCore;

@interface ZomAppDelegate : OTRAppDelegate

@property (nonatomic, strong) NSOperationQueue *apiOperationQueue;

- (OTRAccount *)getDefaultAccount;
- (void) setDefaultAccount:(OTRAccount *)account;

@end
