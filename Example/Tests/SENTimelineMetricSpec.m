//
//  SENSleepResultStatisticSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 2/3/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENTimeline.h>

SPEC_BEGIN(SENTimelineMetricSpec)

describe(@"initWithDictionary:", ^{

    __block SENTimelineMetric* metric;

    afterEach(^{
        metric = nil;
    });

    it(@"sets the name", ^{
        metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"PIZZA_CONSUMED"}];
        [[metric.name should] equal:@"PIZZA_CONSUMED"];
    });

    it(@"sets the value", ^{
        metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"value": @23}];
        [[metric.value should] equal:@23];
    });

    context(@"the condition is recognized", ^{
        it(@"sets the alert condition", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"condition": @"ALERT"}];
            [[@(metric.condition) should] equal:@(SENConditionAlert)];
        });

        it(@"sets the warning condition", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"condition": @"WARNING"}];
            [[@(metric.condition) should] equal:@(SENConditionWarning)];
        });

        it(@"sets the ideal condition", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"condition": @"IDEAL"}];
            [[@(metric.condition) should] equal:@(SENConditionIdeal)];
        });

        it(@"sets the unknown condition", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"condition": @"UNAVAILABLE"}];
            [[@(metric.condition) should] equal:@(SENConditionUnknown)];
        });
    });

    context(@"the condition is not recognized", ^{
        it(@"sets the condition as unknown", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"condition": @"TOO_MANY"}];
            [[@(metric.condition) should] equal:@(SENConditionUnknown)];
        });
    });

    context(@"the unit is recognized", ^{
        it(@"sets the minutes unit", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"unit": @"MINUTES"}];
            [[@(metric.unit) should] equal:@(SENTimelineMetricUnitMinute)];
        });

        it(@"sets the quantity unit", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"unit": @"QUANTITY"}];
            [[@(metric.unit) should] equal:@(SENTimelineMetricUnitQuantity)];
        });

        it(@"sets the timestamp unit", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"unit": @"TIMESTAMP"}];
            [[@(metric.unit) should] equal:@(SENTimelineMetricUnitTimestamp)];
        });

        it(@"sets the condition unit", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"unit": @"CONDITION"}];
            [[@(metric.unit) should] equal:@(SENTimelineMetricUnitCondition)];
        });
    });

    context(@"the unit is not recognized", ^{
        it(@"sets the unit as unknown", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"unit": @"PIZZA_BOXES"}];
            [[@(metric.unit) should] equal:@(SENTimelineMetricUnitUnknown)];
        });
    });

    context(@"the type is recognized", ^{
        it(@"sets the total sleep type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"total_sleep"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeTotalDuration)];
        });

        it(@"sets the sound sleep type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"sound_sleep"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeSoundDuration)];
        });

        it(@"sets the time to sleep type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"time_to_sleep"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeTimeToSleep)];
        });

        it(@"sets the times awake type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"times_awake"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeTimesAwake)];
        });

        it(@"sets the fell asleep type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"fell_asleep"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeFellAsleep)];
        });

        it(@"sets the woke up type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"woke_up"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeWokeUp)];
        });

        it(@"sets the temperature type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"temperature"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeTemperature)];
        });

        it(@"sets the humidity type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"humidity"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeHumidity)];
        });

        it(@"sets the particulates type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"particulates"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeParticulates)];
        });

        it(@"sets the light type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"light"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeLight)];
        });

        it(@"sets the sound type", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"sound"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeSound)];
        });
    });

    context(@"the type is not recognized", ^{
        it(@"set the type as unknown", ^{
            metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"pizzas"}];
            [[@(metric.type) should] equal:@(SENTimelineMetricTypeUnknown)];
        });
    });
});

describe(@"updateWithDictionary:", ^{

    __block SENTimelineMetric* metric;

    beforeEach(^{
        metric = [[SENTimelineMetric alloc] initWithDictionary:@{@"name": @"sound", @"condition":@"WARNING"}];
    });

    afterEach(^{
        metric = nil;
    });

    it(@"is changed when properties differ", ^{
        [[@([metric updateWithDictionary:@{@"name":@"sound", @"condition":@"IDEAL"}]) should] beYes];
    });

    it(@"is unchanged when properties are identical", ^{
        [[@([metric updateWithDictionary:@{@"name":@"sound", @"condition":@"WARNING"}]) should] beNo];
    });

    it(@"updates value", ^{
        [metric updateWithDictionary:@{@"value": @200}];
        [[metric.value should] equal:@200];
    });

    it(@"updates unit", ^{
        [metric updateWithDictionary:@{@"unit": @"QUANTITY"}];
        [[@(metric.unit) should] equal:@(SENTimelineMetricUnitQuantity)];
    });

    it(@"updates name", ^{
        [metric updateWithDictionary:@{@"name": @"times_awake"}];
        [[metric.name should] equal:@"times_awake"];
    });

    it(@"updates type", ^{
        [metric updateWithDictionary:@{@"name": @"times_awake"}];
        [[@(metric.type) should] equal:@(SENTimelineMetricTypeTimesAwake)];
    });

    it(@"updates condition", ^{
        [metric updateWithDictionary:@{@"condition":@"IDEAL"}];
        [[@(metric.condition) should] equal:@(SENConditionIdeal)];
    });
});

it(@"is serializible", ^{
    [[[SENTimelineMetric new] should] conformToProtocol:@protocol(NSCoding)];
});

SPEC_END
