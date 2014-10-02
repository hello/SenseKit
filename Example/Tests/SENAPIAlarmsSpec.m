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

            beforeEach(^{
                stubRequest(@"GET", @".*".regex);
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });

            it(@"formats alarm data as an array of alarms", ^{

            });
        });

        context(@"the API call fails", ^{

            beforeEach(^{
                stubRequest(@"GET", @".*".regex)
                    .andFailWithError([NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                __block NSInteger errorCode = 0;
                [SENAPIAlarms alarmsWithCompletion:^(id data, NSError *error) {
                    errorCode = error.code;
                }];
                [[@(errorCode) shouldSoon] equal:@500];
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
                stubRequest(@"POST", @".*".regex);
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });
        });

        context(@"the API call fails", ^{

            beforeEach(^{
                 stubRequest(@"POST", @".*".regex)
                    .andFailWithError([NSError errorWithDomain:@"is.hello" code:500 userInfo:nil]);
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) shouldSoon] beYes];
            });

            it(@"sets the completion block error parameter", ^{
                __block NSInteger errorCode = 0;
                [SENAPIAlarms updateAlarms:@[] completion:^(id data, NSError *error) {
                    errorCode = error.code;
                }];
                [[@(errorCode) shouldSoon] equal:@500];
            });
        });
    });
});

SPEC_END
