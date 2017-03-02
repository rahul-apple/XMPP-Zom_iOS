//
//  VROChatAPIHandler.m
//  Zom
//
//  Created by RAHUL'S MAC MINI on 01/03/17.
//
//

#import "VROChatAPIHandler.h"
#import <AFNetworking/AFNetworking.h>
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

#pragma mark -Register User with Email

-(void)registerUserEmail:(NSString *)emailId fullName:(NSString *)fullName andPassWord:(NSString *)password success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure{
        [self.apiOperationQueue addOperationWithBlock:^{
            if(![ZomCommon isNetworkAvailable])
            {
                failure(nil);
            }else{
                [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
                [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                [_manager.requestSerializer clearAuthorizationHeader];
                NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                if (emailId) {
                    [dictionary setObject:emailId forKey:@"email"];
                }
                if (fullName) {
                    [dictionary setObject:fullName forKey:@"full_name"];
                }
                if (password) {
                    [dictionary setObject:password forKey:@"password"];
                }
                [dictionary setObject:@"email" forKey:@"regType"];
                [dictionary setObject:VRO_CLIENT_ID forKey:@"client_id"];
                [dictionary setObject:VRO_CLIENT_SECRET forKey:@"client_secret"];
                [_manager POST:[NSString stringWithFormat:@"%@users",REG_URL] parameters:[dictionary mutableCopy] progress:^(NSProgress * _Nonnull uploadProgress) {
                    
                } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    if (responseObject) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            success(responseObject);
                        }];
                    }else{
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            failure(nil);
                        }];
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    failure(error);
                }];
            }
        }];    
}

@end
