//
//  SENAPIRoomSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 1/2/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPIRoom.h>
#import <SenseKit/SENAPIClient.h>
#import <SenseKit/SENSensor.h>
#import <SenseKit/SENSettings.h>

SPEC_BEGIN(SENAPIRoomSpec)

describe(@"SENAPIRoom", ^{

    __block SENSensor* sensor;

    beforeEach(^{
        sensor = [[SENSensor alloc] initWithDictionary:@{@"name":@"temperature",@"unit":@"c"}];
    });

    describe(@"currentWithCompletion:", ^{

        it(@"sends a GET request", ^{
            [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
            [SENAPIRoom currentWithCompletion:^(id data, NSError *error) {}];
        });

        context(@"the user prefers fahrenheit", ^{

            __block NSString* unitParam;

            beforeEach(^{
                [SENSettings setTemperatureFormat:SENTemperatureFormatFahrenheit];
                unitParam = nil;
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *methodParams) {
                    NSDictionary* params = methodParams[1];
                    unitParam = params[@"temperature_unit"];
                    return nil;
                }];
                [SENAPIRoom currentWithCompletion:^(id data, NSError *error) {}];
            });

            it(@"sends fahrenheit as the unit", ^{
                [[unitParam should] equal:@"f"];
            });
        });

        context(@"the user prefers centigrade", ^{

            __block NSString* unitParam;

            beforeEach(^{
                [SENSettings setTemperatureFormat:SENTemperatureFormatCentigrade];
                unitParam = nil;
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *methodParams) {
                    NSDictionary* params = methodParams[1];
                    unitParam = params[@"temperature_unit"];
                    return nil;
                }];
                [SENAPIRoom currentWithCompletion:^(id data, NSError *error) {}];
            });

            it(@"sends centigrade as the unit", ^{
                [[unitParam should] equal:@"c"];
            });
        });
    });

    describe(@"hourlyHistoricalDataForSensor:completion:", ^{

        it(@"sends a GET request", ^{
            [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
            [SENAPIRoom hourlyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {}];
        });

        it(@"sends the date as a parameter", ^{
            __block NSString* param = nil;
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *methodParams) {
                NSDictionary* params = methodParams[1];
                param = params[@"from"];
                return nil;
            }];

            [SENAPIRoom hourlyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {}];
            [[param shouldNot] beNil];
        });

        context(@"the HTTP request fails", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIRoom hourlyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });
        });

        context(@"the HTTP request succeeds", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[@{@"value":@22,@"datetime":@([[NSDate date] timeIntervalSince1970] * 1000)}], nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIRoom hourlyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });
        });
    });

    describe(@"dailyHistoricalDataForSensor:completion:", ^{

        it(@"sends a GET request", ^{
            [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
            [SENAPIRoom dailyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {}];
        });

        it(@"sends the date as a parameter", ^{
            __block NSString* param = nil;
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *methodParams) {
                NSDictionary* params = methodParams[1];
                param = params[@"from"];
                return nil;
            }];

            [SENAPIRoom dailyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {}];
            [[param shouldNot] beNil];
        });

        context(@"the HTTP request fails", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIRoom dailyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });
        });

        context(@"the HTTP request succeeds", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[@{@"value":@22,@"datetime":@([[NSDate date] timeIntervalSince1970] * 1000)}], nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIRoom dailyHistoricalDataForSensor:sensor completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });
        });
    });
});

SPEC_END
