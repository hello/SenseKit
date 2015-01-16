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
    
    describe(@"+insightsFromResponse:", ^{
        
        it(@"returns nil, if response is not an array", ^{
            
            NSArray* insights = [SENAPIInsight insightsFromResponse:@{}];
            [[insights should] beNil];
            
        });
        
        it(@"returns an empty array, if response is an empty array", ^{
            
            NSArray* insights = [SENAPIInsight insightsFromResponse:@[]];
            [[insights should] beKindOfClass:[NSArray class]];
            [[@([insights count]) should] equal:@(0)];
            
        });
        
        it(@"returns an array with a SENInsight object, with proper response", ^{
            
            NSDictionary* response = @{@"title" : @"Lately",
                                       @"message" : @"You've been drinking too much coffee, it's destroying your sleep.",
                                       @"created_utc" : @(1414447740000)};
            NSArray* insights = [SENAPIInsight insightsFromResponse:@[response]];
            
            [[insights should] beKindOfClass:[NSArray class]];
            [[@([insights count]) should] equal:@(1)];
            [[insights[0] should] beKindOfClass:[SENInsight class]];
            
        });
        
    });
    
    describe(@"+getInsights:", ^{
        
        beforeAll(^{
            [[LSNocilla sharedInstance] start];
            stubRequest(@"GET", @".*".regex).andReturn(200).withBody(@"[]").withHeader(@"Content-Type", @"application/json");
        });
        
        afterEach(^{
            [[LSNocilla sharedInstance] clearStubs];
        });
        
        afterAll(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        it(@"callback should be made", ^{
            __block BOOL callbacked = NO;
            [SENAPIInsight getInsights:^(id data, NSError *error) {
                callbacked = YES;
            }];
            [[expectFutureValue(@(callbacked)) shouldEventually] equal:@(YES)];
        });
        
    });
    
    describe(@"+getInfoForInsight:", ^{
        
        beforeAll(^{
            [[LSNocilla sharedInstance] start];
            stubRequest(@"GET", @".*".regex).andReturn(200).withBody(@"[]").withHeader(@"Content-Type", @"application/json");
        });
        
        afterEach(^{
            [[LSNocilla sharedInstance] clearStubs];
        });
        
        afterAll(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        it(@"callback made with no error if insight specified", ^{
            
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"title" : @"test",
                                                                           @"category" : @"LIGHT",
                                                                           @"message" : @"testing",
                                                                           @"timestamp" : @(1421280960988)}];
            __block NSError* returnedError = nil;
            [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
                returnedError = error;
            }];
            [[expectFutureValue(returnedError) shouldEventually] beNil];
            
        });
        
        it(@"callback made with error if no insight specified", ^{
            
            __block NSError* returnedError = nil;
            [SENAPIInsight getInfoForInsight:nil completion:^(id data, NSError *error) {
                returnedError = error;
            }];
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
            [[expectFutureValue(@([returnedError code])) shouldEventually] equal:@(SENAPIInsightErrorInvalidArgument)];
            
        });
        
        it(@"callback made with error if insight category is missing", ^{
            
            SENInsight* insight = [[SENInsight alloc] initWithDictionary:@{@"title" : @"test",
                                                                           @"message" : @"testing",
                                                                           @"timestamp" : @(1421280960988)}];
            
            __block NSError* returnedError = nil;
            [SENAPIInsight getInfoForInsight:insight completion:^(id data, NSError *error) {
                returnedError = error;
            }];
            [[expectFutureValue(returnedError) shouldEventually] beNonNil];
            [[expectFutureValue(@([returnedError code])) shouldEventually] equal:@(SENAPIInsightErrorInvalidArgument)];
            
        });
        
    });
    
});

SPEC_END

