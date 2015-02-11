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

        __block BOOL callbackInvoked = NO;
        NSString* sleepDateText = @"2011-06-13";
        NSDateFormatter* formatter = [NSDateFormatter new];
        formatter.dateFormat = @"yyyy-MM-dd";

        beforeEach(^{
            NSDate* date = [formatter dateFromString:sleepDateText];
            [SENAPIFeedback updateEvent:@"IN_BED" withHour:7 minute:22 forNightOfSleep:date completion:^(NSError *error) {
                callbackInvoked = YES;
            }];
        });

        it(@"invokes the completion block", ^{
            [[@(callbackInvoked) should] beYes];
        });

        it(@"sends good == false", ^{
            [[requestParams[@"good"] should] beNo];
        });

        it(@"sends the accurate wakeup time", ^{
            [[requestParams[@"hour"] should] equal:@"07:22"];
        });

        it(@"sends the date", ^{
            [[requestParams[@"day"] should] equal:sleepDateText];
        });
    });
});

SPEC_END
