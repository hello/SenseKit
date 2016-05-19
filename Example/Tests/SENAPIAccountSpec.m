//
//  SENAPIAccountSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"
#import "SENAccount.h"

SPEC_BEGIN(SENAPIAccountSpec)

describe(@"SENAPIAccount", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
        stubRequest(@"POST", @".*".regex).andReturn(204).withHeader(@"Content-Type", @"application/json");
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });
    
    describe(@"+changePassword:toNewPassword:completionBlock:", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });
        
        it(@"should make a callback", ^{
            __block BOOL calledback = NO;
            [SENAPIAccount changePassword:@"TEST" toNewPassword:@"test123" completionBlock:^(id data, NSError *error) {
                calledback = YES;
            }];
            [[@(calledback) should] beYes];
        });
        
        it(@"should return invalid argument error if current password is not set", ^{
            __block NSError* apiError = nil;
            [SENAPIAccount changePassword:@"" toNewPassword:@"TEST" completionBlock:^(id data, NSError *error) {
                apiError = error;
            }];
            [[@([apiError code]) should] equal:@(SENAPIAccountErrorInvalidArgument)];
        });
        
        it(@"should return invalid argument error if new password is not set", ^{
            __block NSError* apiError = nil;
            [SENAPIAccount changePassword:@"test" toNewPassword:nil completionBlock:^(id data, NSError *error) {
                apiError = error;
            }];
            [[@([apiError code]) should] equal:@(SENAPIAccountErrorInvalidArgument)];
        });
        
    });
    
    describe(@"+errorForAPIResponseError", ^{
        
        it(@"should properly return an error code for api error response", ^{
            
            NSDictionary* serverResponse = @{@"message" : @"PASSWORD_TOO_SHORT",
                                             @"code" : @(400)};
            NSData* responseData = [NSJSONSerialization dataWithJSONObject:serverResponse
                                                                   options:NSJSONWritingPrettyPrinted
                                                                     error:nil];
            NSDictionary* userInfo = @{AFNetworkingOperationFailingURLResponseDataErrorKey : responseData};
            NSError* error = [NSError errorWithDomain:@"is.hello.api" code:400 userInfo:userInfo];
            SENAPIAccountError errorType = [SENAPIAccount errorForAPIResponseError:error];
            [[@(errorType) should] equal:@(SENAPIAccountErrorPasswordTooShort)];
            
        });
        
        it(@"should return error unknown type if no response in error object", ^{
            
            NSError* error = [NSError errorWithDomain:@"is.hello.api" code:400 userInfo:nil];
            SENAPIAccountError errorType = [SENAPIAccount errorForAPIResponseError:error];
            [[@(errorType) should] equal:@(SENAPIAccountErrorUnknown)];
            
        });
        
    });
    
    describe(@"+createAccount:withPassword:completion:", ^{
        
        context(@"no errors encountered", ^{
            
            __block NSString* path = nil;
            __block NSDictionary* accountDict = nil;
            __block NSError* apiError = nil;
            __block SENAccount* accountReturned = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    path = [params firstObject];
                    accountDict = params[1];
                    SENAPIDataBlock success = [params lastObject];
                    success (@{}, nil);
                    return nil;
                }];
                
                [SENAPIAccount createAccount:[SENAccount new] withPassword:@"test123" completion:^(id data, NSError *error) {
                    accountReturned = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should have sent a time_zone", ^{
                [[accountDict[@"time_zone"] should] beNonNil];
            });
            
            it(@"should not have error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return an account object", ^{
                [[accountReturned should] beKindOfClass:[SENAccount class]];
            });
            
            it(@"should have sent a password", ^{
                [[accountDict[@"password"] should] beNonNil];
            });
            
        });
        
    });

});

SPEC_END
