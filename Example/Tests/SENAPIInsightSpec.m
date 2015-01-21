//
//  SENAPIInsightSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 10/28/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENInsight.h>
#import <SenseKit/SENAPIInsight.h>

@interface SENAPIInsight (Private)

+ (NSArray*)insightsFromResponse:(id)response;

@end

SPEC_BEGIN(SENAPIInsightSpec)

describe(@"SENAPIInsight", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"+insightsFromResponse:", ^{

        __block NSArray* insights;

        afterEach(^{
            insights = nil;
        });

        context(@"response is not an array", ^{

            beforeEach(^{
                insights = [SENAPIInsight insightsFromResponse:@{}];
            });

            it(@"returns nil", ^{
                [[insights should] beNil];
            });
        });

        context(@"response is an empty array", ^{

            beforeEach(^{
                insights = [SENAPIInsight insightsFromResponse:@[]];
            });

            it(@"returns an empty array", ^{
                [[insights should] haveCountOf:0];
            });
        });

        context(@"response is a non-empty array", ^{

            NSDictionary* response = @{@"title" : @"Lately",
                                       @"message" : @"You've been drinking too much coffee, it's destroying your sleep.",
                                       @"created_utc" : @(1414447740000)};

            beforeEach(^{
                insights = [SENAPIInsight insightsFromResponse:@[response]];
            });

            it(@"returns an array of SENInsight objects", ^{
                [[insights should] haveCountOf:1];
                [[[insights firstObject] should] beKindOfClass:[SENInsight class]];
            });
        });
    });
    
    describe(@"+getInsights:", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });
        
        it(@"callback should be made", ^{
            __block BOOL callbacked = NO;
            [SENAPIInsight getInsights:^(id data, NSError *error) {
                callbacked = YES;
            }];
            [[@(callbacked) should] beYes];
        });
        
    });
    
    describe(@"+getInfoForInsight:", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });

        context(@"no insight is specified", ^{

            it(@"invokes the callback with an error", ^{
                __block NSError* returnedError = nil;
                [SENAPIInsight getInfoForInsight:nil completion:^(id data, NSError *error) {
                    returnedError = error;
                }];
                [[@([returnedError code]) should] equal:@(SENAPIInsightErrorInvalidArgument)];
            });
        });

        context(@"category is missing from insight", ^{

            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"title" : @"test",
                                                                           @"message" : @"testing",
                                                                           @"timestamp" : @(1421280960988)}];


            it(@"calls back with error", ^{
                __block NSError* returnedError = nil;
                [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
                    returnedError = error;
                }];
                [[@([returnedError code]) should] equal:@(SENAPIInsightErrorInvalidArgument)];
            });
        });

        context(@"insight is valid", ^{

            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"title" : @"test",
                                                                           @"category" : @"LIGHT",
                                                                           @"message" : @"testing",
                                                                           @"timestamp" : @(1421280960988)}];

            it(@"calls back with no error", ^{
                __block NSError* returnedError = nil;
                [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
                    returnedError = error;
                }];
                [[returnedError should] beNil];
            });
        });
    });
    
});

SPEC_END

