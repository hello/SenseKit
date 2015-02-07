//
//  SENSleepResultSensorInsightSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 10/14/14.
//  Copyright 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSleepResult.h>

SPEC_BEGIN(SENSleepResultSensorInsightSpec)

describe(@"SENSleepResultSensorInsight", ^{

    __block SENSleepResultSensorInsight* sensor;
    NSDictionary* insightData = @{@"sensor":@"temperature",
                                  @"condition": @"WARNING",
                                  @"message":@"I see popsicles in here."};

    beforeEach(^{
        sensor = [[SENSleepResultSensorInsight alloc] initWithDictionary:insightData];
    });

    describe(@"initialization", ^{

        it(@"sets the message", ^{
            [[sensor.message should] equal:@"I see popsicles in here."];
        });

        it(@"sets the name", ^{
            [[sensor.name should] equal:@"temperature"];
        });

        it(@"sets the condition", ^{
            [[@(sensor.condition) should] equal:@(SENSensorConditionWarning)];
        });
    });

    describe(@"serialization", ^{

        __block SENSleepResultSensorInsight* serializedSensor;

        beforeEach(^{
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:sensor];
            serializedSensor = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        });

        it(@"is serializable", ^{
            [[sensor should] conformToProtocol:@protocol(NSCoding)];
        });

        it(@"has the same name after serialization", ^{
            [[serializedSensor.name should] equal:sensor.name];
        });

        it(@"has the same message after serialization", ^{
            [[serializedSensor.message should] equal:sensor.message];
        });

        it(@"has the same condition after serialization", ^{
            [[@(serializedSensor.condition) should] equal:@(sensor.condition)];
        });
    });

    describe(@"updateWithDictionary:", ^{

        __block BOOL changed = NO;

        NSDictionary* updatedJSON = @{@"message": @"This reminds me Dairy Queen."};

        beforeEach(^{
            changed = [sensor updateWithDictionary:updatedJSON];
        });

        it(@"updates an existing instance with a dictionary", ^{
            [[sensor.message should] equal:updatedJSON[@"message"]];
        });

        it(@"does not override fields missing from a dictionary", ^{
            [[sensor.name should] equal:insightData[@"sensor"]];
        });

        it(@"returns YES", ^{
            [[@(changed) should] beYes];
        });

        it(@"does not update more than once", ^{
            [[@([sensor updateWithDictionary:updatedJSON]) should] beNo];
        });
    });
});

SPEC_END
