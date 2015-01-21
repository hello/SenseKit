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

SPEC_BEGIN(SENAPITrendsSpec)

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
