//
//  VROChatAPIHandler.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "VROChatAPIHandler.h"
#import <AFNetworking/AFNetworking.h>

#define REG_URL @"https://vrocloud.com/vro_v3/users/"
#define BASE_URL @"https://vrocloud.com/production/v1/"

@interface VROChatAPIHandler ()
@property (nonatomic, strong) NSOperationQueue *apiOperationQueue;
@property (nonatomic ,strong)AFHTTPSessionManager *manager;

@end


@implementation VROChatAPIHandler

@end
