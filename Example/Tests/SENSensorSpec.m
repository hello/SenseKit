
#import <Kiwi/Kiwi.h>
#import "SENSensor.h"

SPEC_BEGIN(SENSensorSpec)

describe(@"SENSensor", ^{

    describe(@"-initWithDictionary:", ^{
        
        __block SENSensor* sensor;
        NSTimeInterval sensorTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
        NSDictionary* sensorValues = @{
                                       @"name":@"temperature",
                                       @"value": @(22.8),
                                       @"unit": @"c",
                                       @"message": @"It's pretty cold in here.",
                                       @"ideal_conditions": @"You sleep best when **it isn't freezing in here.**",
                                       @"condition": @"warning",
                                       @"last_updated_utc": @(sensorTimestamp)};

        beforeEach(^{
            sensor = [[SENSensor alloc] initWithDictionary:sensorValues];
        });
        
        it(@"sets the name", ^{
            [[sensor.name should] equal:@"temperature"];
        });
        
        it(@"sets the value", ^{
            [[sensor.value should] equal:@(22.8)];
        });
        
        it(@"sets the unit", ^{
            [[@(sensor.unit) should] equal:@(SENSensorUnitDegreeCentigrade)];
        });
        
        it(@"sets the message", ^{
            [[sensor.message should] equal:@"It's pretty cold in here."];
        });

        it(@"sets the ideal conditions message", ^{
            [[sensor.idealConditionsMessage should] equal:@"You sleep best when **it isn't freezing in here.**"];
        });
        
        it(@"sets the condition", ^{
            [[@(sensor.condition) should] equal:@(SENSensorConditionWarning)];
        });
        
        it(@"sets the updated date", ^{
            NSNumber* timestamp = @(sensorTimestamp);
            [[@(sensor.lastUpdated.timeIntervalSince1970) should] equal:@([timestamp floatValue] /1000)];
        });

        context(@"the sensor is deserialized", ^{

            __block SENSensor* decodedSensor;

            beforeEach(^{
                NSData* data = [NSKeyedArchiver archivedDataWithRootObject:sensor];
                decodedSensor = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            });

            it(@"sets the name", ^{
                [[decodedSensor.name should] equal:@"temperature"];
            });

            it(@"sets the value", ^{
                [[decodedSensor.value should] equal:@(22.8)];
            });

            it(@"sets the unit", ^{
                [[@(decodedSensor.unit) should] equal:@(SENSensorUnitDegreeCentigrade)];
            });

            it(@"sets the message", ^{
                [[decodedSensor.message should] equal:@"It's pretty cold in here."];
            });

            it(@"sets the ideal conditions message", ^{
                [[decodedSensor.idealConditionsMessage should] equal:@"You sleep best when **it isn't freezing in here.**"];
            });

            it(@"sets the condition", ^{
                [[@(decodedSensor.condition) should] equal:@(SENSensorConditionWarning)];
            });

            it(@"sets the updated date", ^{
                NSNumber* timestamp = @(sensorTimestamp);
                [[@(decodedSensor.lastUpdated.timeIntervalSince1970) should] equal:@([timestamp floatValue] /1000)];
            });
        });
    });
});

SPEC_END
