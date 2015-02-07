//
//  SENTrendDataPointSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 1/14/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENTrendDataPointSpec)

describe(@"-initWithDictionary:", ^{

    __block SENTrendDataPoint* point;

    it(@"sets empty x value offset", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"x_value":@""}];
        [[@(point.xValue) should] equal:@0];
    });

    it(@"sets x value offset", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"x_value":@23}];
        [[@(point.xValue) should] equal:@23];
    });

    it(@"sets empty y value offset", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"y_value":@""}];
        [[@(point.yValue) should] equal:@0];
    });

    it(@"sets y value offset", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"y_value":@23}];
        [[@(point.yValue) should] equal:@23];
    });

    it(@"sets milliseconds offset", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"offset_millis":@(-28800000)}];
        [[@(point.millisecondsOffset) should] equal:@(-28800000)];
    });

    it(@"sets good quality", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"data_label":@"GOOD"}];
        [[@(point.quality) should] equal:@(SENTrendDataPointQualityGood)];
    });

    it(@"sets ok quality", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"data_label":@"OK"}];
        [[@(point.quality) should] equal:@(SENTrendDataPointQualityOk)];
    });

    it(@"sets bad quality", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"data_label":@"BAD"}];
        [[@(point.quality) should] equal:@(SENTrendDataPointQualityBad)];
    });

    it(@"sets unknown quality", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:nil];
        [[@(point.quality) should] equal:@(SENTrendDataPointQualityUnknown)];
    });

    it(@"is equal to a point with the same properties", ^{
        NSDictionary* properties = @{@"data_label":@"GOOD",@"y_value":@233,@"x_value":@4};
        point = [[SENTrendDataPoint alloc] initWithDictionary:properties];
        SENTrendDataPoint* other = [[SENTrendDataPoint alloc] initWithDictionary:properties];
        [[point should] equal:other];
        [[@(point.hash) should] equal:@(other.hash)];
    });

    it(@"is not equal to a point with different properties", ^{
        point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"data_label":@"GOOD",@"y_value":@233,@"x_value":@4}];
        SENTrendDataPoint* other = [[SENTrendDataPoint alloc] initWithDictionary:@{@"data_label":@"BAD",@"y_value":@233,@"x_value":@4}];
        [[point shouldNot] equal:other];
    });

    context(@"datetime is 0", ^{

        it(@"sets the date as nil", ^{
            point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"datetime":@0}];
            [[point.date should] beNil];
        });
    });

    context(@"datetime is not 0", ^{

        NSDateFormatter* formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm zzz";
        NSDate* date = [formatter dateFromString:@"2014-12-16 08:00 GMT"];

        it(@"sets the date", ^{
            point = [[SENTrendDataPoint alloc] initWithDictionary:@{@"datetime":@(1418716800000)}];
            [[point.date should] equal:date];
        });
    });
});

SPEC_END
