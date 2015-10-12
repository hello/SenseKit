
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
        NSCalendarUnit units = (NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear);
        NSDateComponents* components = [[NSCalendar currentCalendar] components:units
                                                                       fromDate:timeline.date];
        [[@(components.day) should] equal:@11];
        [[@(components.month) should] equal:@3];
        [[@(components.year) should] equal:@2015];
    });

    it(@"sets the score", ^{
        [[[timeline score] should] equal:@78];
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

    context(@"score condition is alert", ^{

        it(@"sets the score condition as alert", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"ALERT"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionAlert)];
        });
    });

    context(@"score condition is warning", ^{

        it(@"sets the score condition as warning", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"WARNING"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionWarning)];
        });
    });

    context(@"score condition is ideal", ^{

        it(@"sets the score condition as ideal", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"IDEAL"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionIdeal)];
        });
    });

    context(@"score condition is unavailable", ^{

        it(@"sets the score condition as unknown", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"UNAVAILABLE"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionUnknown)];
        });
    });

    context(@"score condition is not recognized", ^{

        it(@"sets the score condition as unknown", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"$4 PIZZA"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionUnknown)];
        });
    });

    context(@"score condition is incomplete", ^{

        it(@"sets the score condition as incomplete", ^{
            timeline = [[SENTimeline alloc] initWithDictionary:@{@"score_condition": @"INCOMPLETE"}];
            [[@(timeline.scoreCondition) should] equal:@(SENConditionIncomplete)];
        });
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

describe(@"isEqual:", ^{
    __block SENTimeline* timeline1 = nil, *timeline2 = nil;

    beforeEach(^{
        timeline1 = [[SENTimeline alloc] initWithDictionary:json];
        timeline2 = [[SENTimeline alloc] initWithDictionary:json];
    });

    afterEach(^{
        timeline1 = nil;
        timeline2 = nil;
    });

    it(@"is YES", ^{
        [[timeline1 should] equal:timeline2];
    });

    it(@"is not the same after condition change", ^{
        [timeline1 updateWithDictionary:@{@"score_condition":@"IDEAL"}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is not the same after score change", ^{
        [timeline1 updateWithDictionary:@{@"score":@44}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is not the same after message change", ^{
        [timeline1 updateWithDictionary:@{@"message":@"Hallo"}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is not the same after date change", ^{
        [timeline1 updateWithDictionary:@{@"date":@"2014-11-08"}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is not the same after metrics change", ^{
        [timeline1 updateWithDictionary:@{@"metrics":@[]}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is not the same after segments change", ^{
        [timeline1 updateWithDictionary:@{@"events":@[]}];
        [[timeline1 shouldNot] equal:timeline2];
    });

    it(@"is the same after nothing changes", ^{
        [timeline1 updateWithDictionary:json];
        [[timeline1 should] equal:timeline2];
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
