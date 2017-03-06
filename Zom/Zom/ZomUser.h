//
//  ZomUser.h
//  Zom
//
//  Created by Bose on 06/03/17.
//
//

#import <Foundation/Foundation.h>

@interface ZomUser : NSObject

- (void)setUserDetails:(NSDictionary *)details;
+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobileNumber;
@property (nonatomic, strong) NSString *xmppPassword;
@property (nonatomic, strong) NSString *xmppUsername;


@end
