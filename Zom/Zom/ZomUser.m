//
//  ZomUser.m
//  Zom
//
//  Created by Bose on 06/03/17.
//
//

#import "ZomUser.h"

@implementation ZomUser


+ (instancetype)sharedInstance
{
    static ZomUser *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [ZomUser new];
    });
    return sharedInstance;
}


- (void)setUserDetails:(NSDictionary *)details
{
    self.userId = details[@"id"];
    self.email = details[@"email"];
    
    self.xmppPassword = [details valueForKeyPath:@"user.xmpp_sip_password"];
    self.xmppUsername = [details valueForKeyPath:@"user.xmpp_sip_user_name"];
    self.userName = [details valueForKeyPath:@"user.user_name"];
    self.fullName = [details valueForKeyPath:@"user.full_name"];
    self.mobileNumber = [details valueForKeyPath:@"user.mobile"];
}





@end
