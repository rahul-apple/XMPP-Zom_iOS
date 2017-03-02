//
//  ZomCommon.m
//  Zom
//
//  Created by Rahul Ramachandra on 02/03/17.
//
//

#import "ZomCommon.h"

@implementation ZomCommon
+ (BOOL)isNetworkAvailable {
    Reachability *networkReachability =
    [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        return false;
    } else {
        return true;
    }
}
@end
