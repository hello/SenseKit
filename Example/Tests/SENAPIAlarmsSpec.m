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
#import <SenseKit/SENSound.h>

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

    describe(@"+availableSoundsWithCompletion:", ^{

        it(@"makes a GET request", ^{
            [[SENAPIClient should] receive:@selector(GET:parameters:completion:)];
            [SENAPIAlarms availableSoundsWithCompletion:^(id data, NSError *error) {}];
        });

        context(@"the API request succeeds", ^{

            NSArray* soundData = @[
                @{@"name":@"Lilt",@"id":@"FILE002",@"url":@"http://example.com/sounds/lilt.mp3"},
                @{@"name":@"Bounce",@"id":@"FILE003",@"url":@"http://example.com/sounds/bounce.mp3"}];
            __block BOOL callbackInvoked = NO;
            __block NSArray* parsedData = nil;

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(soundData, nil);
                    return nil;
                }];
                [SENAPIAlarms availableSoundsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                    parsedData = data;
                }];
            });

            it(@"invokes the completion block", ^{
                [[@(callbackInvoked) should] beYes];
            });

            it(@"formats the sounds an an array", ^{
                [[parsedData should] haveCountOf:2];
            });

            it(@"sets the properties of the sound objects", ^{
                SENSound* sound1 = [parsedData firstObject];
                SENSound* sound2 = [parsedData lastObject];
                [[sound2.displayName should] equal:@"Bounce"];
                [[sound2.identifier should] equal:@"FILE003"];
                [[sound2.URLPath should] equal:@"http://example.com/sounds/bounce.mp3"];
                [[sound1.displayName should] equal:@"Lilt"];
                [[sound1.identifier should] equal:@"FILE002"];
                [[sound1.URLPath should] equal:@"http://example.com/sounds/lilt.mp3"];
            });
        });

        context(@"the API request fails", ^{
            __block BOOL callbackInvoked = NO;
            __block NSError* parsedError = nil;

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello.test" code:500 userInfo:nil]);
                    return nil;
                }];
                [SENAPIAlarms availableSoundsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                    parsedError = error;
                }];
            });

            it(@"invokes the completion block", ^{
                [[@(callbackInvoked) should] beYes];
            });

            it(@"passes the error to the completion block", ^{
                [[[parsedError domain] should] equal:@"is.hello.test"];
            });
        });
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

            it(@"formats alarm data as an array", ^{
                __block NSArray* alarms = nil;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    alarms = data;
                }];
                [[alarms should] haveCountOf:2];
            });

            it(@"preserves the ordering of alarms", ^{
                __block SENAlarm* firstAlarm = nil, * lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    firstAlarm = [data firstObject];
                    lastAlarm = [data lastObject];
                }];
                [[@(firstAlarm.hour) should] equal:@6];
                [[@(lastAlarm.hour) should] equal:@16];
            });

            it(@"sets repeat days", ^{
                __block SENAlarm* lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    lastAlarm = [data lastObject];
                }];
                NSNumber* repeatFlags = @(SENAlarmRepeatMonday | SENAlarmRepeatWednesday | SENAlarmRepeatFriday);
                [[@(lastAlarm.repeatFlags) should] equal:repeatFlags];
            });

            it(@"sets editable", ^{
                __block SENAlarm* firstAlarm = nil, * lastAlarm = nil;
                [SENAPIAlarms alarmsWithCompletion:^(NSArray* data, NSError *error) {
                    firstAlarm = [data firstObject];
                    lastAlarm = [data lastObject];
                }];
                [[@([firstAlarm isEditable]) should] beYes];
                [[@([lastAlarm isEditable]) should] beNo];
            });
        });

        context(@"the API call fails", ^{

            __block NSInteger errorCode = 0;
            __block BOOL callbackInvoked = NO;

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                    errorCode = error.code;
                }];
            });

            it(@"invokes the completion block", ^{
                [[@(callbackInvoked) should] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                [[@(errorCode) should] equal:@500];
            });
        });
    });

    describe(@"+setAlarms:withCompletion:", ^{

        it(@"makes a POST request", ^{
            [[SENAPIClient should] receive:@selector(POST:parameters:completion:)];
            [SENAPIAlarms updateAlarms:nil completion:NULL];
        });

        context(@"the API call succeeds", ^{

            __block BOOL callbackInvoked = NO;

            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
            });

            it(@"invokes the completion block", ^{
                [[@(callbackInvoked) should] beYes];
            });
        });

        context(@"the API call fails", ^{

            __block NSInteger errorCode = 0;
            __block BOOL callbackInvoked = NO;

            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, [NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
                    return nil;
                }];
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                    errorCode = error.code;
                }];
            });

            it(@"invokes the completion block", ^{
                [[@(callbackInvoked) should] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                [[@(errorCode) should] equal:@500];
            });
        });
    });
});

SPEC_END
