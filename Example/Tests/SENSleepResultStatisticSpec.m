//
//  SENSleepResultStatisticSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 2/3/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSleepResult.h>

SPEC_BEGIN(SENSleepResultStatisticSpec)

describe(@"initWithName:value:", ^{

    __block SENSleepResultStatistic* stat;

    afterEach(^{
        stat = nil;
    });

    it(@"sets the name", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"PIZZA" value:@4];
        [[stat.name should] equal:@"PIZZA"];
    });

    it(@"sets the value", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"PIZZA" value:@4];
        [[stat.value should] equal:@4];
    });

    it(@"ignores invalid values", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"PIZZA" value:(NSNumber*)@"cake"];
        [[stat.value should] beNil];
    });

    it(@"ignores invalid names", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:(NSString*)@{} value:(NSNumber*)@"cake"];
        [[stat.name should] beNil];
    });

    it(@"sets the total duration type", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"total_sleep" value:@300];
        [[@(stat.type) should] equal:@(SENSleepResultStatisticTypeTotalDuration)];
    });

    it(@"sets the unknown type", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"cake" value:@300];
        [[@(stat.type) should] equal:@(SENSleepResultStatisticTypeUnknown)];
    });

    it(@"sets the sound sleep duration type", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"sound_sleep" value:@300];
        [[@(stat.type) should] equal:@(SENSleepResultStatisticTypeSoundDuration)];
    });

    it(@"sets the times awake type", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"times_awake" value:@300];
        [[@(stat.type) should] equal:@(SENSleepResultStatisticTypeTimesAwake)];
    });

    it(@"sets the time to sleep type", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"time_to_sleep" value:@300];
        [[@(stat.type) should] equal:@(SENSleepResultStatisticTypeTimeToSleep)];
    });

    it(@"discards sentinel value", ^{
        stat = [[SENSleepResultStatistic alloc] initWithName:@"time_to_sleep" value:@(SENSleepResultSentinelValue)];
        [[stat.value should] beNil];
    });
});

it(@"is serializible", ^{
    [[[SENSleepResultStatistic new] should] conformToProtocol:@protocol(NSCoding)];
});

SPEC_END
