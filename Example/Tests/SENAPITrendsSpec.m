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
#import <SenseKit/SENTrend.h>
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

NSArray* trendData = @[@{
        @"title": @"SLEEP SCORE BY DAY OF WEEK",
        @"data_type": @"SLEEP_SCORE",
        @"time_period": @"DOW",
    },
    @{
        @"title": @"SLEEP DURATION BY DAY OF WEEK",
        @"data_type": @"SLEEP_DURATION",
        @"time_period": @"DOW",
    },
    @{
        @"title": @"SLEEP SCORE OVER TIME",
        @"data_type": @"SLEEP_SCORE",
        @"time_period": @"ALL",
}];

beforeAll(^{
    [[LSNocilla sharedInstance] start];
});

afterEach(^{
    [[LSNocilla sharedInstance] clearStubs];
});

afterAll(^{
    [[LSNocilla sharedInstance] stop];
});

describe(@"+defaultTrendsListWithCompletion:", ^{

    it(@"sends a GET request", ^{
        [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
        [SENAPITrends defaultTrendsListWithCompletion:^(id data, NSError *error) {}];
    });

    context(@"the request succeeds", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(trendData, nil);
                return nil;
            }];
        });

        it(@"creates SENTrend objects", ^{
            __block NSArray* trends = nil;
            [SENAPITrends defaultTrendsListWithCompletion:^(id data, NSError *error) {
                trends = data;
            }];
            [[trends should] haveCountOf:3];
            [[[trends firstObject] should] beKindOfClass:[SENTrend class]];
        });
    });

    context(@"the request fails", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"is.hello.test" code:500 userInfo:nil]);
                return nil;
            }];
        });

        it(@"invokes the completion block", ^{
            __block NSError* error = nil;
            [SENAPITrends defaultTrendsListWithCompletion:^(id data, NSError *blockError) {
                error = blockError;
            }];
            [[error shouldNot] beNil];
        });
    });
});

describe(@"+allTrendsListWithCompletion:", ^{

    it(@"sends a GET request", ^{
        [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
        [SENAPITrends allTrendsListWithCompletion:^(id data, NSError *error) {}];
    });

    context(@"the request succeeds", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(trendData, nil);
                return nil;
            }];
        });

        it(@"invokes the completion block", ^{
            __block BOOL blockInvoked = NO;
            [SENAPITrends allTrendsListWithCompletion:^(id data, NSError *error) {
                blockInvoked = YES;
            }];
            [[@(blockInvoked) should] beYes];
        });

        it(@"creates SENTrend objects", ^{
            __block NSArray* trends = nil;
            [SENAPITrends allTrendsListWithCompletion:^(id data, NSError *error) {
                trends = data;
            }];
            [[trends should] haveCountOf:3];
            [[[trends firstObject] should] beKindOfClass:[SENTrend class]];
        });
    });

    context(@"the request fails", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"is.hello.test" code:500 userInfo:nil]);
                return nil;
            }];
        });

        it(@"invokes the completion block", ^{
            __block NSError* error = nil;
            [SENAPITrends allTrendsListWithCompletion:^(id data, NSError *blockError) {
                error = blockError;
            }];
            [[error shouldNot] beNil];
        });
    });
});

describe(@"+sleepScoreTrendForTimePeriod:completion:", ^{

    it(@"sends a GET request", ^{
        [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
        [SENAPITrends sleepScoreTrendForTimePeriod:@"" completion:^(SENTrend *trend, NSError *error){}];
    });

    context(@"the request succeeds", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(trendData, nil);
                return nil;
            }];
        });

        it(@"creates SENTrend objects", ^{
            __block NSArray* trends = nil;
            [SENAPITrends sleepScoreTrendForTimePeriod:@"2W" completion:^(id data, NSError *error) {
                trends = data;
            }];
            [[trends should] haveCountOf:3];
            [[[trends firstObject] should] beKindOfClass:[SENTrend class]];
        });
    });

    context(@"the request fails", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"is.hello.test" code:500 userInfo:nil]);
                return nil;
            }];
        });

        it(@"invokes the completion block", ^{
            __block NSError* error = nil;
            [SENAPITrends sleepScoreTrendForTimePeriod:@"1W" completion:^(id data, NSError *blockError) {
                error = blockError;
            }];
            [[error shouldNot] beNil];
        });
    });
});

describe(@"+sleepDurationTrendForTimePeriod:completion:", ^{

    it(@"sends a GET request", ^{
        [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
        [SENAPITrends sleepDurationTrendForTimePeriod:@"" completion:^(SENTrend *trend, NSError *error){}];
    });

    context(@"the request succeeds", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(trendData, nil);
                return nil;
            }];
        });

        it(@"creates SENTrend objects", ^{
            __block NSArray* trends = nil;
            [SENAPITrends sleepDurationTrendForTimePeriod:@"2W" completion:^(id data, NSError *error) {
                trends = data;
            }];
            [[trends should] haveCountOf:3];
            [[[trends firstObject] should] beKindOfClass:[SENTrend class]];
        });
    });

    context(@"the request fails", ^{

        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"is.hello.test" code:500 userInfo:nil]);
                return nil;
            }];
        });

        it(@"invokes the completion block", ^{
            __block NSError* error = nil;
            [SENAPITrends sleepDurationTrendForTimePeriod:@"1W" completion:^(id data, NSError *blockError) {
                error = blockError;
            }];
            [[error shouldNot] beNil];
        });
    });
});

SPEC_END
