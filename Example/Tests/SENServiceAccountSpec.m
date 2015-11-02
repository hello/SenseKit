//
//  SENServiceAccountSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <AFNetworking/AFNetworking.h>
#import <Nocilla/Nocilla.h>
#import "SENServiceAccount.h"
#import "SENAPIAccount.h"
#import "SENAPIPreferences.h"
#import "SENPreference.h"
#import "SENAuthorizationService.h"
#import "SENPreference.h"
#import "SENAccount.h"

@interface SENServiceAccount()

- (NSError*)commonServiceErrorFromAPIError:(NSError*)error
                    unrecognizedStatusCode:(NSInteger*)statusCode;

@end

SPEC_BEGIN(SENServiceAccountSpec)

describe(@"SENServiceAccountSpec", ^{

    describe(@"- commonServiceErrorFromAPIError:unrecognizedStatusCode", ^{
        
        context(@"api error is unknown, but status code is 409", ^{
            
            __block NSInteger code = 0;
            __block NSError* error = nil;
            
            beforeEach(^{
                code = 409;
                
                [SENAPIAccount stub:@selector(errorForAPIResponseError:)
                          andReturn:[KWValue valueWithInteger:SENAPIAccountErrorUnknown]];
                
                NSHTTPURLResponse* response = [NSHTTPURLResponse new];
                [response stub:@selector(statusCode) andReturn:[KWValue valueWithInteger:code]];
                
                NSDictionary* userInfo = @{AFNetworkingOperationFailingURLResponseErrorKey : response};
                error = [NSError errorWithDomain:@"test" code:-1011 userInfo:userInfo];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                error = nil;
                code = 0;
            });
            
            it(@"should return a unrecognized status code", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSInteger unrecognizedCode = 0;
                [service commonServiceErrorFromAPIError:error unrecognizedStatusCode:&unrecognizedCode];
                [[@(unrecognizedCode) should] equal:@(code)];
            });
            
            it(@"should not return a service error", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSError* serviceError = [service commonServiceErrorFromAPIError:error
                                                         unrecognizedStatusCode:NULL];
                [[serviceError should] beNil];
            });
            
        });
        
        context(@"api error is unknown, but status code is 412 (pre-condition failed)", ^{
            
            __block NSInteger code = 0;
            __block NSError* error = nil;
            
            beforeEach(^{
                code = 412;
                
                [SENAPIAccount stub:@selector(errorForAPIResponseError:)
                          andReturn:[KWValue valueWithInteger:SENAPIAccountErrorUnknown]];
                
                NSHTTPURLResponse* response = [NSHTTPURLResponse new];
                [response stub:@selector(statusCode) andReturn:[KWValue valueWithInteger:code]];
                
                NSDictionary* userInfo = @{AFNetworkingOperationFailingURLResponseErrorKey : response};
                error = [NSError errorWithDomain:@"test" code:-1011 userInfo:userInfo];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                error = nil;
                code = 0;
            });
            
            it(@"should NOT return a unrecognized status code", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSInteger unrecognizedCode = 0;
                [service commonServiceErrorFromAPIError:error unrecognizedStatusCode:&unrecognizedCode];
                [[@(unrecognizedCode) should] equal:@0];
            });
            
            it(@"should return a service error suggesting account not up to date", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSError* serviceError = [service commonServiceErrorFromAPIError:error
                                                         unrecognizedStatusCode:NULL];
                [[@([serviceError code]) should] equal:@(SENServiceAccountErrorAccountNotUpToDate)];
            });
            
        });
        
        context(@"api error is email being invalid", ^{
            
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIAccount stub:@selector(errorForAPIResponseError:)
                          andReturn:[KWValue valueWithInteger:SENAPIAccountErrorEmailInvalid]];
                
                NSHTTPURLResponse* response = [NSHTTPURLResponse new];
                [response stub:@selector(statusCode) andReturn:[KWValue valueWithInteger:400]];
                
                NSDictionary* userInfo = @{AFNetworkingOperationFailingURLResponseErrorKey : response};
                error = [NSError errorWithDomain:@"test" code:-1011 userInfo:userInfo];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                error = nil;
            });
            
            it(@"should NOT return a unrecognized status code", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSInteger unrecognizedCode = 0;
                [service commonServiceErrorFromAPIError:error unrecognizedStatusCode:&unrecognizedCode];
                [[@(unrecognizedCode) should] equal:@0];
            });
            
            it(@"should return a service error suggesting email is invalid", ^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                NSError* serviceError = [service commonServiceErrorFromAPIError:error
                                                         unrecognizedStatusCode:NULL];
                [[@([serviceError code]) should] equal:@(SENServiceAccountErrorEmailInvalid)];
            });
            
        });
        
    });
    
    describe(@"- refreshAccount:", ^{
        
        context(@"no API errors", ^{
            
            __block BOOL calledGetAccount = NO;
            __block BOOL calledGetPreferences = NO;
            __block BOOL calledBack;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIAccount stub:@selector(getAccount:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    calledGetAccount = YES;
                    block (nil, nil);
                    return nil;
                }];
                
                [SENAPIPreferences stub:@selector(getPreferences:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    calledGetPreferences = YES;
                    block (nil, nil);
                    return nil;
                }];
                
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [service refreshAccount:^(NSError *error) {
                    calledBack = YES;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                [SENAPIPreferences clearStubs];
                calledGetAccount = NO;
                calledGetPreferences = NO;
                calledBack = NO;
                error = nil;
            });
            
            it(@"should call getAccount on API", ^{
                [[@(calledGetAccount) should] beYes];
            });
            
            it(@"should call getPreferences on API", ^{
                [[@(calledGetPreferences) should] beYes];
            });
            
            it(@"should call back after done", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[error should] beNil];
            });
            
        });
        
        context(@"API error when trying to get latest account changes", ^{
        
            __block BOOL calledGetAccount = NO;
            __block BOOL calledGetPreferences = NO;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIAccount stub:@selector(getAccount:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    calledGetAccount = YES;
                    block (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIPreferences stub:@selector(getPreferences:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    calledGetPreferences = YES;
                    block (nil, nil);
                    return nil;
                }];
                
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [service refreshAccount:^(NSError *serviceError) {
                    error = serviceError;
                }];
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                [SENAPIPreferences clearStubs];
                calledGetAccount = NO;
                calledGetPreferences = NO;
                error = nil;
            });
            
            it(@"should call getAccount on API", ^{
                [[@(calledGetAccount) should] beYes];
            });
            
            it(@"should call getPreferences on API", ^{
                [[@(calledGetPreferences) should] beYes];
            });
            
            it(@"should have returned an error", ^{
                [[error should] beNonNil];
            });
            
        });
        
    });
    
    describe(@"-changePassword:newPassword:forUsername:completion", ^{
        
        context(@"not all arguments passed in", ^{
            
            __block NSError* serviceError = nil;
            
            beforeEach(^{
                SENServiceAccount* accountService = [SENServiceAccount sharedService];
                [accountService changePassword:@"test" toNewPassword:nil forUsername:nil completion:^(NSError *error) {
                    serviceError = error;
                }];
            });
            
            afterEach(^{
                serviceError = nil;
            });
            
            it(@"should return an error with invalid argument coe", ^{
                [[@([serviceError code]) should] equal:@(SENServiceAccountErrorInvalidArg)];
            });
            
        });
        
        context(@"all arguments are valid with no API errors", ^{
            
            __block NSError* serviceError = nil;
            __block BOOL didReauthorize = NO;
            
            beforeEach(^{
                
                [SENAPIAccount stub:@selector(changePassword:toNewPassword:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                [SENAuthorizationService stub:@selector(reauthorizeUser:password:callback:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSError* error) = [params lastObject];
                    didReauthorize = YES;
                    callback (nil);
                    return nil;
                }];
                
                SENServiceAccount* accountService = [SENServiceAccount sharedService];
                [accountService changePassword:@"test" toNewPassword:@"new-test" forUsername:@"tester" completion:^(NSError *error) {
                    serviceError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                serviceError = nil;
                didReauthorize = NO;
            });
            
            it(@"should not return an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have reauthorized", ^{
                [[@(didReauthorize) should] beYes];
            });
            
        });
        
        context(@"API returned an error when changing password", ^{
            
            __block NSError* serviceError = nil;
            __block BOOL didReauthorize = NO;
            
            beforeEach(^{
                
                [SENAPIAccount stub:@selector(changePassword:toNewPassword:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAuthorizationService stub:@selector(reauthorizeUser:password:callback:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSError* error) = [params lastObject];
                    didReauthorize = YES;
                    callback (nil);
                    return nil;
                }];
                
                SENServiceAccount* accountService = [SENServiceAccount sharedService];
                [accountService changePassword:@"test" toNewPassword:@"new-test" forUsername:@"tester" completion:^(NSError *error) {
                    serviceError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIAccount clearStubs];
                serviceError = nil;
                didReauthorize = NO;
            });
            
            it(@"should return an error", ^{
                [[serviceError should] beNonNil];
            });
            
            it(@"should not reauthorize", ^{
                [[@(didReauthorize) should] beNo];
            });
            
        });
        
    });
    
    describe(@"-changeEmail:completion:", ^{
        
        context(@"email contains trailing spaces", ^{
            
            __block SENAccount* fakeAccount = nil;
            __block NSError* serviceError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                
                fakeAccount = [SENAccount new];
                
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [service stub:@selector(account) andReturn:fakeAccount];
                [service stub:@selector(refreshAccount:) withBlock:^id(NSArray *params) {
                    SENAccountResponseBlock block = [params lastObject];
                    block (nil);
                    return nil;
                }];
                
                [SENAPIAccount stub:@selector(changeEmailInAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                [service changeEmail:@"test@test.com     " completion:^(NSError *error) {
                    serviceError = error;
                    calledBack = YES;
                }];
                
            });
            
            afterEach(^{
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [service clearStubs];
                [SENAPIAccount clearStubs];
                fakeAccount = nil;
                serviceError = nil;
                calledBack = NO;
            });
            
            it(@"should have submitted a trimmed email", ^{
                [[[fakeAccount email] should] equal:@"test@test.com"];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[serviceError should] beNil];
            });
            
        });
        
    });
    
});

SPEC_END
