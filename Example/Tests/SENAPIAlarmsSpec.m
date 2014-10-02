//
//  SENAPIAlarmSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 10/1/14.
//  Copyright 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPIAlarms.h>
#import <SenseKit/SENAlarm.h>

SPEC_BEGIN(SENAPIAlarmsSpec)

describe(@"SENAPIAlarms", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"+alarmsWithCompletion:", ^{

        it(@"makes a GET request", ^{
            [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
            [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {}];
        });

        context(@"the API call succeeds", ^{
            NSArray* alarmData = @[
                @{@"hour":@6, @"minute":@25, @"editable": @(YES)},
                @{@"hour":@16, @"minute":@0, @"repeated": @(YES), @"day_of_week":@[@1,@3,@5]}
            ];

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(alarmData, nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"formats alarm data as an array", ^{
                __block NSArray* alarms = nil;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    alarms = data;
                }];
                [[expectFutureValue(alarms) shouldSoon] haveCountOf:2];
            });

            it(@"preserves the ordering of alarms", ^{
                __block SENAlarm* firstAlarm = nil, * lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    firstAlarm = [data firstObject];
                    lastAlarm = [data lastObject];
                }];
                [[expectFutureValue(@(firstAlarm.hour)) shouldSoon] equal:@6];
                [[expectFutureValue(@(lastAlarm.hour)) shouldSoon] equal:@16];
            });

            it(@"sets repeat days", ^{
                __block SENAlarm* lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    lastAlarm = [data lastObject];
                }];
                NSNumber* repeatFlags = @(SENAlarmRepeatMonday | SENAlarmRepeatWednesday | SENAlarmRepeatFriday);
                [[expectFutureValue(@(lastAlarm.repeatFlags)) shouldSoon] equal:repeatFlags];
            });

            it(@"sets editable", ^{
                __block SENAlarm* firstAlarm = nil, * lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    firstAlarm = [data firstObject];
                    lastAlarm = [data lastObject];
                }];
                [[expectFutureValue(@([firstAlarm isEditable])) shouldSoon] beYes];
                [[expectFutureValue(@([lastAlarm isEditable])) shouldSoon] beNo];
            });
        });

        context(@"the API call fails", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                __block NSInteger errorCode = 0;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    errorCode = error.code;
                }];
                [[expectFutureValue(@(errorCode)) shouldSoon] equal:@500];
            });
        });
    });

    describe(@"+setAlarms:withCompletion:", ^{

        it(@"makes a POST request", ^{
            [[SENAPIClient should] receive:@selector(POST:parameters:completion:)];
            [SENAPIAlarms updateAlarms:nil completion:NULL];
        });

        context(@"the API call succeeds", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        context(@"the API call fails", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                __block NSInteger errorCode = 0;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    errorCode = error.code;
                }];
                [[expectFutureValue(@(errorCode)) shouldSoon] equal:@500];
            });
        });
    });
});

SPEC_END
