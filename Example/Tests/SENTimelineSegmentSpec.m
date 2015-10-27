
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENTimeline.h>

SPEC_BEGIN(SENTimelineSegmentSpec)

NSDictionary* json = @{ @"timestamp": @1432768812000,
                        @"timezone_offset": @(-14400000),
                        @"duration_millis": @27000,
                        @"message": @"You were moving around",
                        @"sleep_depth": @24,
                        @"sleep_state": @"AWAKE",
                        @"event_type": @"IN_BED",
                        @"valid_actions": @[ @"VERIFY", @"REMOVE"]};

__block SENTimelineSegment* segment = nil;

afterEach(^{
    segment = nil;
});

describe(@"initWithDictionary:", ^{

    beforeEach(^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:json];
    });

    it(@"sets the date", ^{
        NSTimeInterval interval = [json[@"timestamp"] doubleValue] / 1000;
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
        NSComparisonResult result = [[NSCalendar currentCalendar] compareDate:segment.date
                                                                       toDate:date
                                                            toUnitGranularity:NSCalendarUnitSecond];
        [[@(result) should] equal:@(NSOrderedSame)];
    });

    it(@"sets the timezone", ^{
        NSInteger seconds = [json[@"timezone_offset"] integerValue] / 1000;
        [[@(segment.timezone.secondsFromGMT) should] equal:@(seconds)];
    });

    it(@"sets the duration", ^{
        [[@(segment.duration) should] equal:@([json[@"duration_millis"] doubleValue] / 1000)];
    });

    it(@"sets the message", ^{
        [[[segment message] should] equal:json[@"message"]];
    });

    it(@"sets the type", ^{
        [[@(segment.type) should] equal:@(SENTimelineSegmentTypeInBed)];
    });

    it(@"sets the sleep depth", ^{
        [[@([segment sleepDepth]) should] equal:json[@"sleep_depth"]];
    });

    it(@"sets the sleep state", ^{
        [[@(segment.sleepState) should] equal:@(SENTimelineSegmentSleepStateAwake)];
    });

    it(@"sets the possible actions", ^{
        [[@(segment.possibleActions) should] equal:@(SENTimelineSegmentActionApprove | SENTimelineSegmentActionRemove)];
    });
});

describe(@"isEqual:", ^{
    beforeEach(^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:json];
    });

    context(@"two segments created with same dictionary", ^{
        __block SENTimelineSegment* otherSegment;

        beforeEach(^{
            otherSegment = [[SENTimelineSegment alloc] initWithDictionary:[json copy]];
        });

        it(@"is YES", ^{
            [[segment should] equal:otherSegment];
        });
    });

    context(@"other object is not a segment", ^{

        it(@"is NO", ^{
            [[segment shouldNot] equal:@""];
        });
    });

    context(@"other object has different properties", ^{
        __block SENTimelineSegment* otherSegment;
        NSDictionary* json = @{ @"timestamp": @1432768412000,
                                @"duration_millis": @27000,
                                @"message": @"You were moving around",
                                @"sleep_depth": @24,
                                @"sleep_state": @"AWAKE",
                                @"event_type": @"IN_BED",
                                @"valid_actions": @[]};

        beforeEach(^{
            otherSegment = [[SENTimelineSegment alloc] initWithDictionary:json];
        });

        it(@"is NO", ^{
            [[segment shouldNot] equal:otherSegment];
        });
    });
});

describe(@"serialization", ^{
    __block SENTimelineSegment* serializedSegment = nil;

    beforeEach(^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:json];
        NSData* data = [NSKeyedArchiver archivedDataWithRootObject:segment];
        serializedSegment = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    });

    it(@"is serializable", ^{
        [[segment should] conformToProtocol:@protocol(NSCoding)];
    });

    it(@"has the same date after serialization", ^{
        [[serializedSegment.date should] equal:segment.date];
    });

    it(@"has the same duration after serialization", ^{
        [[@(serializedSegment.duration) should] equal:@(segment.duration)];
    });

    it(@"has the same timezone after serialization", ^{
        [[serializedSegment.timezone should] equal:segment.timezone];
    });

    it(@"has the same message after serialization", ^{
        [[serializedSegment.message should] equal:segment.message];
    });

    it(@"has the same event type after serialization", ^{
        [[@(serializedSegment.type) should] equal:@(segment.type)];
    });

    it(@"has the same sleep depth after serialization", ^{
        [[@(serializedSegment.sleepDepth) should] equal:@(segment.sleepDepth)];
    });

    it(@"has the same sleep state after serialization", ^{
        [[@(serializedSegment.sleepState) should] equal:@(segment.sleepState)];
    });

    it(@"has the same actions after serialization", ^{
        [[@(serializedSegment.possibleActions) should] equal:@(segment.possibleActions)];
    });
});

describe(@"updateWithDictionary:", ^{
    NSDictionary* updatedJSON = @{@"duration_millis": @125500};

    __block BOOL changed = NO;

    beforeEach(^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:json];
        changed = [segment updateWithDictionary:updatedJSON];
    });

    it(@"updates an existing instance with a dictionary", ^{
        [[@([segment duration]) should] equal:@([updatedJSON[@"duration_millis"] doubleValue] / 1000)];
    });

    it(@"does not override fields missing from a dictionary", ^{
        [[[segment message] should] equal:json[@"message"]];
    });

    it(@"returns YES", ^{
        [[@(changed) should] beYes];
    });

    it(@"does not update more than once", ^{
        [[@([segment updateWithDictionary:updatedJSON]) should] beNo];
    });
});

describe(@"canPerformAction:", ^{

    it(@"sets no actions from missing array", ^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:@{}];
        [[@([segment canPerformAction:SENTimelineSegmentActionRemove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionApprove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionAdjustTime]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionIncorrect]) should] beNo];
    });

    it(@"sets no actions from empty array", ^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:@{@"valid_actions":@[]}];
        [[@([segment canPerformAction:SENTimelineSegmentActionRemove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionApprove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionAdjustTime]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionIncorrect]) should] beNo];
    });

    it(@"checks actions from single item array", ^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:@{@"valid_actions":@[@"REMOVE"]}];
        [[@([segment canPerformAction:SENTimelineSegmentActionRemove]) should] beYes];
        [[@([segment canPerformAction:SENTimelineSegmentActionApprove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionAdjustTime]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionIncorrect]) should] beNo];
    });

    it(@"checks actions from multiple item array", ^{
        segment = [[SENTimelineSegment alloc] initWithDictionary:@{@"valid_actions":@[@"INCORRECT", @"VERIFY"]}];
        [[@([segment canPerformAction:SENTimelineSegmentActionRemove]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionApprove]) should] beYes];
        [[@([segment canPerformAction:SENTimelineSegmentActionAdjustTime]) should] beNo];
        [[@([segment canPerformAction:SENTimelineSegmentActionIncorrect]) should] beYes];
    });
});

SPEC_END
