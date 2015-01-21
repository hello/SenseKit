
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSleepResult.h>

SPEC_BEGIN(SENSleepResultSegmentSpec)

describe(@"SENSleepResultSegment", ^{

    __block SENSleepResultSegment* segment = nil;

    afterEach(^{
        segment = nil;
    });

    describe(@"initialization", ^{
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSDictionary* json = @{@"id": @94841103,
                               @"duration":@18181000,
                               @"timestamp":@(timeInterval * 1000),
                               @"message": @"there's a disturbance in the force",
                               @"event_type": @"sound",
                               @"sleep_depth": @2,
                               @"sound": @{
                                       @"url":@"http://example.com/sound.caf",
                                       @"duration_millis":@53484}};

        beforeEach(^{
            segment = [[SENSleepResultSegment alloc] initWithDictionary:json];
        });

        it(@"sets the server ID", ^{
            [[[segment serverID] should] equal:json[@"id"]];
        });

        it(@"sets the date and time", ^{
            NSTimeInterval diff = ABS([[segment date] timeIntervalSince1970] - timeInterval);
            [[@(diff) should] beLessThan:@(0.0001)];
        });

        it(@"sets the duration", ^{
            [[[segment duration] should] equal:json[@"duration"]];
        });

        it(@"sets the message", ^{
            [[[segment message] should] equal:json[@"message"]];
        });

        it(@"sets the event type", ^{
            [[[segment eventType] should] equal:json[@"event_type"]];
        });

        it(@"sets the sleep depth", ^{
            [[@([segment sleepDepth]) should] equal:json[@"sleep_depth"]];
        });

        it(@"sets the sound url", ^{
            [[[segment.sound URLPath] should] equal:json[@"sound"][@"url"]];
        });

        it(@"sets the sound duration", ^{
            [[@([segment.sound durationMillis]) should] equal:json[@"sound"][@"duration_millis"]];
        });
    });

    describe(@"serialization", ^{
        __block SENSleepResultSegment* serializedSegment = nil;
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] - 10000;
        NSDictionary* json = @{@"id": @448917,
                               @"message": @"there may have been an earthquake",
                               @"event_type": @"noise",
                               @"date": @(timeInterval * 1000),
                               @"sound": @{
                                       @"url":@"http://example.com/sound.mkv",
                                       @"duration_millis":@53112}};

        beforeEach(^{
            segment = [[SENSleepResultSegment alloc] initWithDictionary:json];
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:segment];
            serializedSegment = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        });

        it(@"is serializable", ^{
            [[segment should] conformToProtocol:@protocol(NSCoding)];
        });

        it(@"has the same server ID after serialization", ^{
            [[serializedSegment.serverID should] equal:segment.serverID];
        });

        it(@"has the same date after serialization", ^{
            [[serializedSegment.date should] equal:segment.date];
        });

        it(@"has the same message after serialization", ^{
            [[serializedSegment.message should] equal:segment.message];
        });

        it(@"has the same event type after serialization", ^{
            [[serializedSegment.eventType should] equal:segment.eventType];
        });

        it(@"has the same sleep depth after serialization", ^{
            [[@(serializedSegment.sleepDepth) should] equal:@(segment.sleepDepth)];
        });

        it(@"has the same sound URL after serialization", ^{
            [[serializedSegment.sound.URLPath should] equal:segment.sound.URLPath];
        });

        it(@"has the same sound URL after serialization", ^{
            [[@(serializedSegment.sound.durationMillis) should] equal:@(segment.sound.durationMillis)];
        });
    });

    describe(@"updating", ^{
        NSDictionary* json = @{@"id": @9422198, @"duration": @553000};
        NSDictionary* updatedJSON = @{@"duration": @125500};

        beforeEach(^{
            segment = [[SENSleepResultSegment alloc] initWithDictionary:json];
            [segment updateWithDictionary:updatedJSON];
        });

        it(@"updates an existing instance with a dictionary", ^{
            [[[segment duration] should] equal:updatedJSON[@"duration"]];
        });

        it(@"does not override fields missing from a dictionary", ^{
            [[[segment serverID] should] equal:json[@"id"]];
        });
    });
});

SPEC_END
