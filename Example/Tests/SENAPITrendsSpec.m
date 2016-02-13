//
//  SENAPITrendsSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/API.h>
#import <SenseKit/SENTrends.h>
#import <SenseKit/SENTrendsGraph.h>

SPEC_BEGIN(SENAPITrendsSpec)

describe(@"SENAPITrends", ^{
    
    describe(@"+trendsForTimeScale:completion:", ^{
        
        context(@"API returned an error", ^{
            
            __block NSError* apiError = nil;
            __block id trends = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPITrends trendsForTimeScale:SENTrendsTimeScaleWeek completion:^(id data, NSError *error) {
                    apiError = error;
                    trends = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                trends = nil;
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
            it(@"should not return any trends", ^{
                [[trends should] beNil];
            });
            
        });

        context(@"API succeeded and returned data", ^{
            
            __block NSError* apiError = nil;
            __block id trends = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"available_time_scales" : @[@"LAST_WEEK"],
                          @"graphs" : @[@{@"time_scale" : @"LAST_WEEK",
                                          @"min_value" : @0,
                                          @"max_value" : @0,
                                          @"sections" : @[],
                                          @"data_type" : @"SCORES",
                                          @"title" : @"SLEEP SCORES",
                                          @"graph_type" : @"GRID"}]}, nil);
                    return nil;
                }];
                
                [SENAPITrends trendsForTimeScale:SENTrendsTimeScaleWeek completion:^(id data, NSError *error) {
                    apiError = error;
                    trends = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                trends = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENTrends object", ^{
                [[trends should] beKindOfClass:[SENTrends class]];
            });
            
            it(@"should contain available time scales", ^{
                [[@([[trends availableTimeScales] count]) should] equal:@1];
            });
            
            it(@"should contain available graphs", ^{
                [[@([[trends graphs] count]) should] equal:@1];
            });
            
            it(@"should return graphs of type SENTrendsGraph", ^{
                id graph = [[trends graphs] firstObject];
                [[graph should] beKindOfClass:[SENTrendsGraph class]];
            });
            
        });
        
    });
    
});

SPEC_END
