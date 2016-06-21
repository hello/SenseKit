//
//  SENAPIShareSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 6/21/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import "SENAPIShare.h"

SPEC_BEGIN(SENAPIShareSpec)

describe(@"SENAPIShare", ^{
    
    describe(@"+shareURLFor:completion:", ^{
        
        context(@"share insight with id and returns url", ^{
            
            __block SENInsight* insight = nil;
            __block NSError* apiError = nil;
            __block id urlObj = nil;
            
            beforeEach(^{
                NSDictionary* insightDict = @{@"id" : @"uuid"};
                insight = [[SENInsight alloc] initWithDictionary:insightDict];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:)
                         withBlock:^id(NSArray *params) {
                             SENAPIDataBlock cb = [params lastObject];
                             cb (@{@"url" : @"https://share.hello.is"}, nil);
                             return nil;
                         }];
                
                [SENAPIShare shareURLFor:insight completion:^(id data, NSError *error) {
                    apiError = error;
                    urlObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                insight = nil;
                urlObj = nil;
                apiError = nil;
            });
            
            it(@"response should be a string", ^{
                [[urlObj should] beKindOfClass:[NSString class]];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"shared object does not contain identifier", ^{
            
            __block SENInsight* shareObj = nil;
            __block NSError* apiError = nil;
            __block id urlObj = nil;
            
            beforeEach(^{
                shareObj = [SENInsight new];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:)
                         withBlock:^id(NSArray *params) {
                             SENAPIDataBlock cb = [params lastObject];
                             cb (@{@"url" : @"https://share.hello.is"}, nil);
                             return nil;
                         }];
                
                [SENAPIShare shareURLFor:shareObj completion:^(id data, NSError *error) {
                    apiError = error;
                    urlObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                shareObj = nil;
                urlObj = nil;
                apiError = nil;
            });
            
            it(@"response should be nil", ^{
                [[urlObj should] beNil];
            });
            
            it(@"should return an invalid arg error", ^{
                [[apiError should] beNonNil];
                [[@([apiError code]) should] equal:@(SENAPIShareErrorInvalidArgument)];
            });
            
        });
        
        context(@"api returns an error", ^{
            
            __block SENInsight* shareObj = nil;
            __block NSError* apiError = nil;
            __block id urlObj = nil;
            
            beforeEach(^{
                NSDictionary* insightDict = @{@"id" : @"uuid"};
                shareObj = [[SENInsight alloc] initWithDictionary:insightDict];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:)
                         withBlock:^id(NSArray *params) {
                             SENAPIDataBlock cb = [params lastObject];
                             NSError* error = [NSError errorWithDomain:@"test"
                                                                  code:-1
                                                              userInfo:nil];
                             cb (nil, error);
                             return nil;
                         }];
                
                [SENAPIShare shareURLFor:shareObj completion:^(id data, NSError *error) {
                    apiError = error;
                    urlObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                shareObj = nil;
                urlObj = nil;
                apiError = nil;
            });
            
            it(@"response should be nil", ^{
                [[urlObj should] beNil];
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
    });
    
});

SPEC_END