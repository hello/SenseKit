
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSleepResult.h>

SPEC_BEGIN(SENSleepResultSpec)

describe(@"SENSleepResult", ^{

    describe(@"initialization", ^{
        __block SENSleepResult* result = nil;

        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSNumber* score = @85;
        NSDictionary* json = @{@"score": score,
                               @"date":@(timeInterval * 1000),
                               @"segments" : @[
                                       @{@"id": @33421},
                                       @{@"id": @32995},
                                ]};

        beforeEach(^{
            result = [[SENSleepResult alloc] initWithDictionary:json];
        });

        it(@"populates a new instance from a dictionary", ^{
            [[result shouldNot] beNil];
        });

        it(@"sets the date", ^{
            [[@([[result date] timeIntervalSince1970]) should] equal:@(timeInterval)];
        });

        it(@"sets the score", ^{
            [[[result score] should] equal:score];
        });

        it(@"sets the segments", ^{
            [[[result segments] should] haveCountOf:2];
        });
    });

    describe(@"serialization", ^{
        __block SENSleepResult* result = nil;
        __block SENSleepResult* serializedResult = nil;

        NSDictionary* json = @{@"score": @23, @"message": @"should've gone to bed earlier"};

        beforeEach(^{
            result = [[SENSleepResult alloc] initWithDictionary:json];
            NSData* data = [NSKeyedArchiver archivedDataWithRootObject:result];
            serializedResult = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        });

        it(@"is serializable", ^{
            [[result should] conformToProtocol:@protocol(NSCoding)];
        });

        it(@"is the same after serialization", ^{
            [[result.score should] equal:serializedResult.score];
            [[result.message should] equal:serializedResult.message];
            [[result.date should] equal:serializedResult.date];
        });
    });

    describe(@"updating", ^{
        __block SENSleepResult* result = nil;

        NSDictionary* json = @{@"message": @"Not bad", @"score": @78};
        NSDictionary* updatedData = @{@"score": @64};

        beforeEach(^{
            result = [[SENSleepResult alloc] initWithDictionary:json];
            [result updateWithDictionary:updatedData];
        });

        it(@"updates an existing instance with a dictionary", ^{
            [[[result score] should] equal:updatedData[@"score"]];
        });

        it(@"does not override fields missing from a dictionary", ^{
            [[[result message] should] equal:json[@"message"]];
        });
    });
});

SPEC_END
