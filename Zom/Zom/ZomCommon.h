//
//  ZomCommon.h
//  Zom
//
//  Created by Rahul Ramachandra on 02/03/17.
//
//

#import <Foundation/Foundation.h>
#import <Reachability/Reachability.h>
#import "ZomConstants.h"
@interface ZomCommon : NSObject
+ (BOOL)isNetworkAvailable;
@end
