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
@property (nonatomic) BOOL isRefreshingToken;

@end


@implementation VROChatAPIHandler

#pragma mark - init Fucntions

- (id) init
{
    self = [super init];
    if(self)
    {
        
        ZomAppDelegate *delegate = (ZomAppDelegate *)[UIApplication sharedApplication].delegate;
        if (!delegate.apiOperationQueue) {
            delegate.apiOperationQueue = [[NSOperationQueue alloc]init];
            delegate.apiOperationQueue.maxConcurrentOperationCount = 2;
        }
        self.apiOperationQueue = delegate.apiOperationQueue;
        self.isRefreshingToken = false;
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"https://vrocloud.com/develop/v1"]];
        _manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
    }
    return self;
}


@end
