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

-(void)registerUserEmail:(NSString *)emailId fullName:(NSString *)fullName andPassWord:(NSString *)password success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure;
@end
