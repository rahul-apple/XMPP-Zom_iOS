//
//  VROChatAPIHandler.h
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "ZomAppDelegate.h"
#import "ZomCommon.h"

@interface VROChatAPIHandler : NSObject

-(void)registerUserEmail:(NSString *)emailId fullName:(NSString *)fullName andPassWord:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
-(void)registerUserMobile:(NSString *)mobileNumber fullName:(NSString *)fullName password:(NSString *)password andCountryCode:(NSString *)mobile_country_code success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure;
-(void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void)listCountryCodes:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
