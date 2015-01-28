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

@interface SENAPIAccount (Private)

+ (SENAccount*)accountFromResponse:(id)responseObject;
+ (NSDictionary*)dictionaryValue:(SENAccount*)account;

@end

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

    describe(@"+accountFromResponse:", ^{
        
        it(@"if response is not a dictionary, should be nil", ^{
            
            SENAccount* account = [SENAPIAccount accountFromResponse:@[]];
            [[account should] beNil];
            
        });
        
        it(@"if response is a dictionary, account should be instantiated", ^{
            
            SENAccount* account = [SENAPIAccount accountFromResponse:@{}];
            [[account should] beNonNil];
            
        });
        
        it(@"if response contains null value, corresponding property should be nil", ^{
            
            NSDictionary* response = @{
                @"id" : @"0000-00-00000",
                @"last_modified" : @(1409861723884),
                @"name" : [NSNull null]
            };
            SENAccount* account = [SENAPIAccount accountFromResponse:response];
            [[account should] beNonNil];
            [[[account accountId] should] equal:@"0000-00-00000"];
            [[[account name] should] beNil];
        });
        
        it(@"birthdate returned as millis should be properly formatted", ^{
            NSDictionary* response = @{
                @"id" : @"0000-00-00000",
                @"last_modified" : @(1409861723884),
                @"dob" : @"1980-11-19"
            };
            
            SENAccount* account = [SENAPIAccount accountFromResponse:response];
            [[[account birthdate] should] equal:@"1980-11-19"];
            
        });
        
    });
    
    describe(@"+dictionaryValue:", ^{
        __block SENAccount* account;
        
        beforeAll(^{
            account = [[SENAccount alloc] initWithAccountId:@"0" lastModified:@(123)];
        });
        
        it(@"make sure account id is not set in the dictionary since it will fail the request", ^{
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"id"] should] beNil];
        });
        
        it(@"if value in account object is nil, dictionary does not contain key", ^{
            [account setWeight:@(165)];
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"name"] should] beNil];
        });
        
        it(@"make sure gender is properly converted", ^{
            
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"OTHER"];
            
            [account setGender:SENAccountGenderMale];
            dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"MALE"];
            
            [account setGender:SENAccountGenderFemale];
            dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"FEMALE"];
        });
        
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
    
    
});

SPEC_END
