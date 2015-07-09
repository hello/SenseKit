
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENTimeline.h>

SPEC_BEGIN(SENTimelineSpec)

NSDictionary* json = @{@"score": @78,
                       @"score_condition": @"ALERT",
                       @"message": @"You were asleep for 7.8 hours and sleeping soundly for 5.4 hours.",
                       @"date": @"2015-03-11",
                       @"events": @[
                               @{  @"timestamp": @1432768812,
                                   @"timezone_offset": @860000,
                                   @"duration_millis": @27000,
                                   @"message": @"You were moving around",
                                   @"sleep_depth": @24,
                                   @"sleep_state": @"AWAKE",
                                   @"event_type": @"IN_BED",
                                   @"valid_actions": @[
                                           @"VERIFY",
                                           @"REMOVE"]},
                               @{  @"timestamp": @1432788812,
                                   @"timezone_offset": @860000,
                                   @"duration_millis": @27000,
                                   @"message": @"You were moving around",
                                   @"sleep_depth": @40,
                                   @"sleep_state": @"LIGHT",
                                   @"event_type": @"IN_BED",
                                   @"valid_actions": @[]}],
                       @"metrics": @[
                               @{  @"name": @"total_sleep",
                                   @"value": @446,
                                   @"unit": @"MINUTES",
                                   @"condition": @"WARNING"},
                               @{  @"name": @"time_to_sleep",
                                   @"value": @3,
                                   @"unit": @"MINUTES",
                                   @"condition": @"IDEAL"},
                               @{  @"name": @"humidity",
                                   @"condition": @"ALERT"}]};

describe(@"initWithDictionary:", ^{
    __block SENTimeline* timeline = nil;

    beforeEach(^{
        timeline = [[SENTimeline alloc] initWithDictionary:json];
    });

    it(@"populates a new instance from a dictionary", ^{
        [[timeline shouldNot] beNil];
    });

    it(@"sets the date", ^{
        [[timeline.date shouldNot] beNil];
        NSCalendarUnit units = (NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit);
        NSDateComponents* components = [[NSCalendar currentCalendar] components:units
                                                                       fromDate:timeline.date];
        [[@(components.day) should] equal:@11];
        [[@(components.month) should] equal:@3];
        [[@(components.year) should] equal:@2015];
    });

    it(@"sets the score", ^{
        [[[timeline score] should] equal:@78];
    });

    it(@"sets the score condition", ^{
        [[@(timeline.scoreCondition) should] equal:@(SENConditionAlert)];
    });

    it(@"sets the message", ^{
        [[timeline.message should] equal:@"You were asleep for 7.8 hours and sleeping soundly for 5.4 hours."];
    });

    it(@"sets the segments", ^{
        [[[timeline segments] should] haveCountOf:2];
    });

    it(@"sets the metrics", ^{
        [[[timeline metrics] should] haveCountOf:3];
    });
});

describe(@"serialization", ^{
    __block SENTimeline* result = nil;
    __block SENTimeline* serializedResult = nil;

    beforeEach(^{
        result = [[SENTimeline alloc] initWithDictionary:json];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:result];
        serializedResult = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    });

    it(@"is serializable", ^{
        [[result should] conformToProtocol:@protocol(NSCoding)];
    });

    it(@"has the same score after serialization", ^{
        [[result.score should] equal:serializedResult.score];
    });

    it(@"has the same score condition after serialization", ^{
        [[@(result.scoreCondition) should] equal:@(serializedResult.scoreCondition)];
    });

    it(@"has the same message after serialization", ^{
        [[result.message should] equal:serializedResult.message];
    });

    it(@"has the same date after serialization", ^{
        [[result.date should] equal:serializedResult.date];
    });

    it(@"has the same metrics after serialization", ^{
        [[result.metrics should] equal:serializedResult.metrics];
    });

    it(@"has the same segments after serialization", ^{
        [[result.segments should] equal:serializedResult.segments];
    });

    it(@"is the same after serialization", ^{
        [[result should] equal:serializedResult];
    });
});

describe(@"updateWithDictionary:", ^{
    __block SENTimeline* result = nil;
    __block BOOL updated = NO;

    NSDictionary* updatedData = @{@"score": @54,
                                  @"score_condition": @"WARNING",
                                  @"date": @"2015-03-11",
                                  @"metrics": @[
                                          @{  @"name": @"total_sleep",
                                              @"value": @446,
                                              @"unit": @"MINUTES",
                                              @"condition": @"WARNING"},
                                          @{  @"name": @"humidity",
                                              @"condition": @"ALERT"}]};;

    beforeEach(^{
        result = [[SENTimeline alloc] initWithDictionary:json];
        updated = [result updateWithDictionary:updatedData];
    });

    it(@"updates an existing instance with a dictionary", ^{
        [[[result score] should] equal:updatedData[@"score"]];
    });

    it(@"does not override fields missing from a dictionary", ^{
        [[[result message] should] equal:json[@"message"]];
    });

    it(@"returns YES", ^{
        [[@(updated) should] beYes];
    });

    it(@"updates all statistics", ^{
        [[[result metrics] should] haveCountOf:2];
    });

    it(@"does not update more than once", ^{
        [[@([result updateWithDictionary:updatedData]) should] beNo];
    });
});

SPEC_END
