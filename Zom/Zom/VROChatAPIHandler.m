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
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
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
                [_manager POST:@"users" parameters:[dictionary mutableCopy] progress:^(NSProgress * _Nonnull uploadProgress) {
                    
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

#pragma mark -Register User with MobileNumber

-(void)registerUserMobile:(NSString *)mobileNumber fullName:(NSString *)fullName password:(NSString *)password andCountryCode:(NSString *)mobile_country_code success:(void (^)(id responseObject))success
                 failure:(void (^)(NSError *error))failure {
    [self.apiOperationQueue addOperationWithBlock:^{
        if(![ZomCommon isNetworkAvailable])
        {
            failure(nil);
        }else{
            [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
            [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [_manager.requestSerializer clearAuthorizationHeader];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            if (mobileNumber) {
                [dictionary setObject:mobileNumber forKey:@"mobile"];
            }
            if (mobile_country_code) {
                [dictionary setObject:mobile_country_code forKey:@"mobile_country_code"];
            }
            if (fullName) {
                [dictionary setObject:fullName forKey:@"full_name"];
            }
            [dictionary setObject:password forKey:@"password"];
            [dictionary setObject:@"mobile" forKey:@"regType"];
            [dictionary setObject:VRO_CLIENT_ID forKey:@"client_id"];
            [dictionary setObject:VRO_CLIENT_SECRET forKey:@"client_secret"];
            [_manager POST:@"users" parameters:[dictionary mutableCopy] progress:^(NSProgress * _Nonnull uploadProgress) {
                
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

#pragma mark - Login User with Email

-(void)loginWithEmail:(NSString *)email password:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    [self.apiOperationQueue addOperationWithBlock:^{
        if(![ZomCommon isNetworkAvailable])
        {
            failure(nil);
        }else{
            [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
            [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [_manager.requestSerializer clearAuthorizationHeader];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:email forKey:@"email"];
            [dictionary setObject:password forKey:@"password"];
            [dictionary setObject:@"vro_oauth" forKey:@"grant_type"];
            [dictionary setObject:@"email" forKey:@"regType"];
            [dictionary setObject:VRO_CLIENT_ID forKey:@"client_id"];
            [dictionary setObject:VRO_CLIENT_SECRET forKey:@"client_secret"];
            [_manager POST:@"oauth/token" parameters:[dictionary mutableCopy] progress:^(NSProgress * _Nonnull uploadProgress) {
                
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

-(void)loginWithMobile:(NSString *)mobile password:(NSString *)password success:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    [self.apiOperationQueue addOperationWithBlock:^{
        if(![ZomCommon isNetworkAvailable])
        {
            failure(nil);
        }else{
            [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
            [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [_manager.requestSerializer clearAuthorizationHeader];
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:mobile forKey:@"mobile"];
            [dictionary setObject:password forKey:@"password"];
            [dictionary setObject:@"vro_oauth" forKey:@"grant_type"];
            [dictionary setObject:@"mobile" forKey:@"regType"];
            [dictionary setObject:VRO_CLIENT_ID forKey:@"client_id"];
            [dictionary setObject:VRO_CLIENT_SECRET forKey:@"client_secret"];
            [_manager POST:@"oauth/token" parameters:[dictionary mutableCopy] progress:^(NSProgress * _Nonnull uploadProgress) {
                
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

- (void)listCountryCodes:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure
{
    [self.apiOperationQueue addOperationWithBlock:^{
        if(![ZomCommon isNetworkAvailable])
        {
            failure(nil);
            return ;
        }
        
        [_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [_manager.requestSerializer clearAuthorizationHeader];

        [_manager GET:@"mobile/country_codes" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            
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
    }];
}


@end
