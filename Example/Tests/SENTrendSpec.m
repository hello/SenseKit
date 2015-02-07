//
//  SENTrendSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENTrendSpec)

describe(@"-initWithDictionary:", ^{

    __block SENTrend* trend;

    it(@"sets title", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"title":@"Good stuff"}];
        [[trend.title should] equal:@"Good stuff"];
    });

    it(@"sets dataType", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"data_type":@"SCORE"}];
        [[trend.dataType should] equal:@"SCORE"];
    });

    it(@"sets timePeriod", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"time_period":@"2Y"}];
        [[trend.timePeriod should] equal:@"2Y"];
    });

    it(@"sets empty options from empty array", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"options":@[]}];
        [[trend.options should] haveCountOf:0];
    });

    it(@"sets options from strings", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"options":@[@"DOW", @"2W"]}];
        [[trend.options should] equal:@[@"DOW", @"2W"]];
    });

    it(@"sets an empty options from nil", ^{
        trend = [[SENTrend alloc] initWithDictionary:nil];
        [[trend.options should] haveCountOf:0];
    });

    it(@"sets histogram graph type", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"graph_type":@"TIME_SERIES_LINE"}];
        [[@(trend.graphType) should] equal:@(SENTrendGraphTypeTimeSeriesLine)];
    });

    it(@"sets time series graph type", ^{
        trend = [[SENTrend alloc] initWithDictionary:@{@"graph_type":@"HISTOGRAM"}];
        [[@(trend.graphType) should] equal:@(SENTrendGraphTypeHistogram)];
    });

    it(@"sets unknown graph type", ^{
        trend = [[SENTrend alloc] initWithDictionary:nil];
        [[@(trend.graphType) should] equal:@(SENTrendGraphTypeUnknown)];
    });

    it(@"is equal to a trend with the same properties", ^{
        NSDictionary* properties = @{@"graph_type":@"HISTOGRAM",
                                     @"data_points":@[@{@"data_label":@"GOOD",@"y_value":@233,@"x_value":@4}],
                                     @"title":@"Number of cakes per week"};
        trend = [[SENTrend alloc] initWithDictionary:properties];
        SENTrend* other = [[SENTrend alloc] initWithDictionary:properties];
        [[trend should] equal:other];
        [[@(trend.hash) should] equal:@(other.hash)];
    });

    it(@"is not equal to a trend with different properties", ^{
        NSDictionary* properties = @{@"graph_type":@"HISTOGRAM",
                                     @"data_points":@[@{@"data_label":@"GOOD",@"y_value":@233,@"x_value":@4}],
                                     @"title":@"Number of cakes per week"};
        trend = [[SENTrend alloc] initWithDictionary:properties];
        SENTrend* other = [[SENTrend alloc] initWithDictionary:@{@"title":@"Number of cakes per week"}];
        [[trend shouldNot] equal:other];
    });

    context(@"data_points is nil", ^{

        it(@"sets an empty array of points", ^{
            trend = [[SENTrend alloc] initWithDictionary:nil];
            [[trend.dataPoints should] haveCountOf:0];
        });
    });

    context(@"data_points has points", ^{

        NSDictionary* data = @{@"data_points" : @[
            @{
                @"datetime": @1418716800000,
                @"y_value": @100.0,
                @"x_value": @"",
                @"offset_millis": @(-28800000),
                @"data_label": @"GOOD"
            },
            @{
                @"datetime": @1418630400000,
                @"y_value": @80.0,
                @"x_value": @"",
                @"offset_millis": @(-28800000),
                @"data_label": @"GOOD"
            }
        ]};

        it(@"sets an array of points", ^{
            trend = [[SENTrend alloc] initWithDictionary:data];
            [[trend.dataPoints should] haveCountOf:2];
            [[[trend.dataPoints firstObject] should] beKindOfClass:[SENTrendDataPoint class]];
            [[[trend.dataPoints lastObject] should] beKindOfClass:[SENTrendDataPoint class]];
        });
    });
});

SPEC_END
