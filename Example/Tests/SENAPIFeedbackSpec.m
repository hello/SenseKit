//
//  SENAPIFeedbackSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 12/5/14.
//  Copyright 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPIFeedback.h>
#import <Nocilla/Nocilla.h>

static NSDate* dateForTime(NSUInteger hour, NSUInteger minute) {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear)
                                               fromDate:[NSDate date]];
    components.hour = hour;
    components.minute = minute;
    return [calendar dateFromComponents:components];
}

SPEC_BEGIN(SENAPIFeedbackSpec)

describe(@"SENAPIFeedback", ^{

    __block NSDictionary* requestParams = nil;

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    beforeEach(^{
        [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
            requestParams = params[1];
            SENAPIErrorBlock block = [params lastObject];
            block(nil);
            return nil;
        }];
    });

    afterEach(^{
        requestParams = nil;
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"sendAccurateWakeupTime:detectedWakeupTime:forNightOfSleep:completion:", ^{

        it(@"invokes the completion block", ^{
            __block BOOL callbackInvoked = NO;
            [SENAPIFeedback sendAccurateWakeupTime:nil detectedWakeupTime:nil forNightOfSleep:nil completion:^(NSError *error) {
                callbackInvoked = YES;
            }];
            [[@(callbackInvoked) should] beYes];
        });

        context(@"no updated wakeup time is sent", ^{

            beforeEach(^{
                [SENAPIFeedback sendAccurateWakeupTime:nil
                                    detectedWakeupTime:dateForTime(6, 40)
                                       forNightOfSleep:[NSDate date]
                                            completion:NULL];
            });

            it(@"does not send the wakeup time", ^{
                [[requestParams[@"hour"] should] beNil];
            });

            it(@"sends good == true", ^{
                [[requestParams[@"good"] should] beYes];
            });
        });

        context(@"the updated wakeup time is the same as the detected time", ^{

            beforeEach(^{
                [SENAPIFeedback sendAccurateWakeupTime:dateForTime(6, 40)
                                    detectedWakeupTime:dateForTime(6, 40)
                                       forNightOfSleep:[NSDate date]
                                            completion:NULL];
            });

            it(@"does not send the wakeup time", ^{
                [[requestParams[@"hour"] should] beNil];
            });

            it(@"sends good == true", ^{
                [[requestParams[@"good"] should] beYes];
            });
        });

        context(@"the updated wakeup time differs from the detected time", ^{

            beforeEach(^{
                [SENAPIFeedback sendAccurateWakeupTime:dateForTime(7, 15)
                                    detectedWakeupTime:dateForTime(6, 40)
                                       forNightOfSleep:[NSDate date]
                                            completion:NULL];
            });

            it(@"sends good == false", ^{
                [[requestParams[@"good"] should] beNo];
            });

            it(@"sends the accurate wakeup time", ^{
                [[requestParams[@"hour"] should] equal:@"07:15"];
            });
        });
    });
});

SPEC_END
