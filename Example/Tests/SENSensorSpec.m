
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

    describe(@"-unit", ^{

        __block SENSensor* sensor;

        afterEach(^{
            sensor = nil;
        });

        context(@"sensor represents temperature", ^{

            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:@{@"unit":@"c"}];
            });

            it(@"is centigrade", ^{
                [[@(sensor.unit) should] equal:@(SENSensorUnitDegreeCentigrade)];
            });
        });

        context(@"sensor represents light", ^{

            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:@{@"unit":@"lux"}];
            });

            it(@"is lux", ^{
                [[@(sensor.unit) should] equal:@(SENSensorUnitLux)];
            });
        });

        context(@"sensor represents sound", ^{

            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:@{@"unit":@"db"}];
            });

            it(@"is decibel", ^{
                [[@(sensor.unit) should] equal:@(SENSensorUnitDecibel)];
            });
        });

        context(@"sensor represents humidity", ^{

            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:@{@"unit":@"%"}];
            });

            it(@"is centigrade", ^{
                [[@(sensor.unit) should] equal:@(SENSensorUnitPercent)];
            });
        });

        context(@"sensor represents particulates", ^{

            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:@{@"unit":@"AQI"}];
            });

            it(@"is AQI", ^{
                [[@(sensor.unit) should] equal:@(SENSensorUnitAQI)];
            });
        });
    });
});

SPEC_END
