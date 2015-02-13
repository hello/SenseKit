//
//  SENAPIFeedbackSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 12/5/14.
//  Copyright 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPIFeedback.h>
#import <SenseKit/SENSleepResult.h>
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

    describe(@"update sleep segment reported time", ^{

        __block BOOL callbackInvoked = NO;
        NSString* sleepDateText = @"2011-06-13";
        NSDateFormatter* dateFormatter = [NSDateFormatter new];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        NSDateFormatter* timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"HH:mm";

        beforeEach(^{
            NSDate* date = [dateFormatter dateFromString:sleepDateText];
            NSDateFormatter* segmentFormatter = [NSDateFormatter new];
            segmentFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
            segmentFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-25200];
            SENSleepResultSegment* segment = [[SENSleepResultSegment alloc] initWithDictionary:@{
                @"timestamp":@([[segmentFormatter dateFromString:@"2011-06-13 22:03"] timeIntervalSince1970] * 1000),
                @"offset_millis": @(-25200000),
                @"event_type":@"IN_BED",
                @"duration": @1}];
            [SENAPIFeedback updateSegment:segment withHour:1 minute:22 forNightOfSleep:date completion:^(NSError *error) {
                callbackInvoked = YES;
            }];
        });

        it(@"invokes the completion block", ^{
            [[@(callbackInvoked) should] beYes];
        });

        it(@"sends the accurate time", ^{
            [[requestParams[@"new_time_of_event"] should] equal:@"01:22"];
        });

        it(@"sends the inaccurate time", ^{
            [[requestParams[@"old_time_of_event"] should] equal:@"22:03"];
        });

        it(@"sends the event type", ^{
            [[requestParams[@"event_type"] should] equal:@"IN_BED"];
        });

        it(@"sends the date", ^{
            [[requestParams[@"date_of_night"] should] equal:sleepDateText];
        });
    });
});

SPEC_END
