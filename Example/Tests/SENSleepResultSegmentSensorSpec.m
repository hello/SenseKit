
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSleepResult.h>

SPEC_BEGIN(SENSleepResultSegmentSensorSpec)

describe(@"SENSleepResultSegmentSensor", ^{
    __block SENSleepResultSegmentSensor* sensor = nil;

    NSDictionary* json = @{@"value": @98, @"name": @"humidity", @"unit": @"%"};

    beforeEach(^{
        sensor = [[SENSleepResultSegmentSensor alloc] initWithDictionary:json];
    });

    describe(@"initialization", ^{

        it(@"sets the value", ^{
            [[sensor.value should] equal:json[@"value"]];
        });

        it(@"sets the name", ^{
            [[sensor.name should] equal:json[@"name"]];
        });

        it(@"sets the unit", ^{
            [[sensor.unit should] equal:json[@"unit"]];
        });
    });

    describe(@"serialization", ^{
        __block SENSleepResultSegmentSensor* serializedSensor = nil;

        beforeEach(^{
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:sensor];
            serializedSensor = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        });

        it(@"is serializable", ^{
            [[sensor should] conformToProtocol:@protocol(NSCoding)];
        });

        it(@"serializes the name", ^{
            [[serializedSensor.name should] equal:sensor.name];
        });

        it(@"serializes the value", ^{
            [[serializedSensor.value should] equal:sensor.value];
        });

        it(@"serializes the unit", ^{
            [[serializedSensor.unit should] equal:sensor.unit];
        });
    });

    describe(@"updating", ^{
        NSDictionary* updatedJSON = @{@"value": @93};

        beforeEach(^{
            [sensor updateWithDictionary:updatedJSON];
        });

        it(@"updates fields from new data", ^{
            [[sensor.value should] equal:updatedJSON[@"value"]];
        });

        it(@"does not override unupdated fields", ^{
            [[sensor.name should] equal:json[@"name"]];
            [[sensor.unit should] equal:json[@"unit"]];
        });
    });
});

SPEC_END
