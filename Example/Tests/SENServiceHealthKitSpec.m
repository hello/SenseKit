//
//  SENServiceHealthKitSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <HealthKit/HealthKit.h>
#import "SENTimeline.h"
#import "SENServiceHealthKit.h"

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

- (NSArray*)sleepDataPointsForSleepResult:(SENTimeline*)sleepResult;
- (void)writeSleepAnalysisIfDataAvailableFor:(NSDate*)date completion:(void(^)(NSError* error))completion;
- (NSDate*)lastNight;

@end

SPEC_BEGIN(SENServiceHealthKitSpec)

describe(@"SENServiceHealthKitSpec", ^{
    
    describe(@"+sharedService", ^{
        
        it(@"should be singleton", ^{
            
            SENServiceHealthKit* service1 = [SENServiceHealthKit sharedService];
            SENServiceHealthKit* service2 = [SENServiceHealthKit sharedService];
            [[service1 should] beIdenticalTo:service2];
            
            SENServiceHealthKit* service3 = [[SENServiceHealthKit alloc] init];
            [[service1 should] beIdenticalTo:service3];
            
        });
        
    });

    describe(@"-isSupported", ^{
        
        afterEach(^{
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            [service clearStubs];
        });
        
        it(@"should return NO if healthstore is unavailable", ^{
            
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            [service setHkStore:nil];
            BOOL supported = [service isSupported];
            [[@(supported) should] beNo];
            
        });
        
        it(@"should return YES if healthstore is available", ^{
            
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            [service setHkStore:[[HKHealthStore alloc] init]];
            BOOL supported = [service isSupported];
            [[@(supported) should] beYes];
            
        });
        
    });
    
    describe(@"-canWriteSleepAnalysis", ^{
        
        it(@"should return NO because user (this test) did not authorize healthkit use", ^{
            
            [HKHealthStore stub:@selector(isHealthDataAvailable) andReturn:@(YES)];
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            BOOL canWrite = [service canWriteSleepAnalysis];
            [[@(canWrite) should] beNo];
            
        });
        
        it(@"should return YES, if authorization is provided", ^{
            
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            HKHealthStore* store = [[HKHealthStore alloc] init];
            [store stub:@selector(authorizationStatusForType:) withBlock:^id(NSArray *params) {
                return theValue(HKAuthorizationStatusSharingAuthorized);
            }];
            [service setHkStore:store];
            
            BOOL canWrite = [service canWriteSleepAnalysis];
            [[@(canWrite) should] beYes];
            
        });
        
    });
    
    describe(@"-sleepDataPointsForSleepResult:", ^{
        
        __block SENServiceHealthKit* service = nil;
        
        beforeEach(^{
            service = [SENServiceHealthKit sharedService];
        });
        
        context(@"has no sleep or wake up events", ^{
            
            __block SENTimeline* sleepResult = nil;
            
            beforeEach(^{
                NSDictionary* json = @{@"score": @100,
                                       @"score_condition": @"IDEAL",
                                       @"message": @"You were asleep for 7.8 hours and sleeping soundly for 5.4 hours.",
                                       @"date": @"2015-03-11",
                                       @"events": @[
                                               @{  @"timestamp": @1432768812000,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @24,
                                                   @"sleep_state": @"AWAKE",
                                                   @"event_type": @"IN_BED",
                                                   @"valid_actions": @[
                                                           @"VERIFY",
                                                           @"REMOVE"]},
                                               @{  @"timestamp": @1432788812000,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @40,
                                                   @"sleep_state": @"LIGHT",
                                                   @"event_type": @"IN_BED",
                                                   @"valid_actions": @[]}]};
                
                sleepResult = [[SENTimeline alloc] initWithDictionary:json];
                
            });
            
            it(@"should return no data points", ^{
                
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints shouldNot] beNil];
                [[dataPoints should] haveCountOf:0];
                
            });
            
        });
        
        context(@"has sleep event, but no wake event", ^{
            
            __block SENTimeline* sleepResult = nil;
            
            beforeEach(^{
                
                NSDictionary* json = @{@"score": @100,
                                       @"score_condition": @"IDEAL",
                                       @"message": @"You were asleep for 7.8 hours and sleeping soundly for 5.4 hours.",
                                       @"date": @"2015-03-11",
                                       @"events": @[
                                               @{  @"timestamp": @1432768812000,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @24,
                                                   @"sleep_state": @"AWAKE",
                                                   @"event_type": @"FELL_ASLEEP",
                                                   @"valid_actions": @[
                                                           @"VERIFY",
                                                           @"REMOVE"]},
                                               @{  @"timestamp": @1432788812000,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @40,
                                                   @"sleep_state": @"LIGHT",
                                                   @"event_type": @"IN_BED",
                                                   @"valid_actions": @[]}]};
                
                sleepResult = [[SENTimeline alloc] initWithDictionary:json];
                
            });
            
            it(@"should return no data points", ^{
                
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints shouldNot] beNil];
                [[dataPoints should] haveCountOf:0];
                
            });
            
        });
        
        context(@"has sleep and wake events", ^{
            
            __block SENTimeline* sleepResult = nil;
            __block NSTimeInterval sleepTime = [[NSDate date] timeIntervalSince1970];
            __block NSTimeInterval wakeTime = [[NSDate date] timeIntervalSince1970];
            
            beforeEach(^{
                
                NSDictionary* json = @{@"score": @100,
                                       @"score_condition": @"IDEAL",
                                       @"message": @"You were asleep for 7.8 hours and sleeping soundly for 5.4 hours.",
                                       @"date": @"2015-03-11",
                                       @"events": @[
                                               @{  @"timestamp": @1432768812,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @24,
                                                   @"sleep_state": @"AWAKE",
                                                   @"event_type": @"FELL_ASLEEP",
                                                   @"valid_actions": @[
                                                           @"VERIFY",
                                                           @"REMOVE"]},
                                               @{  @"timestamp": @1432788812,
                                                   @"timezone_offset": @860000,
                                                   @"duration_millis": @27000,
                                                   @"message": @"You were moving around",
                                                   @"sleep_depth": @40,
                                                   @"sleep_state": @"LIGHT",
                                                   @"event_type": @"WOKE_UP",
                                                   @"valid_actions": @[]}]};
                
                sleepResult = [[SENTimeline alloc] initWithDictionary:json];
                
            });
            
            it(@"should return 1 data point", ^{
                NSNumber* acceptableDelta = @10;
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints should] haveCountOf:1];
                
                NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:sleepTime];
                NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:wakeTime];
                HKCategorySample* sample = dataPoints[0];
                NSNumber* startDelta = @([[sample startDate] timeIntervalSince1970] - [startDate timeIntervalSince1970]);
                NSNumber* endDelta = @([[sample endDate] timeIntervalSince1970] - [endDate timeIntervalSince1970]);
                [[startDelta should] beLessThan:acceptableDelta];
                [[endDelta should] beLessThan:acceptableDelta];
            });
            
        });
        
    });
        
    describe(@"-sync:", ^{
        
        __block SENServiceHealthKit* service = nil;
        
        beforeEach(^{
            service = [SENServiceHealthKit sharedService];
        });
        
        context(@"completes with error", ^{
            
            it(@"should return with not enabled error", ^{
                
                __block NSError* syncError = nil;
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
                
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotEnabled)];
                
            });
            
            it(@"should return with not supported error", ^{
                
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:NO]];
                
                __block NSError* syncError = nil;
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
                
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotSupported)];
                
            });
            
            it(@"should return with not authorized error", ^{
                
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                
                __block NSError* syncError = nil;
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
                
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotAuthorized)];
                
            });
            
        });
        
        context(@"healthkit is set up and can sync", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
            });
            
            it(@"should call writeSleepAnalysisIfDataAvailableFor with no error", ^{
                
                [service stub:@selector(writeSleepAnalysisIfDataAvailableFor:completion:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSError* error) = [params lastObject];
                    callback(nil);
                    return nil;
                }];
                [[service should] receive:@selector(writeSleepAnalysisIfDataAvailableFor:completion:)];
                
                __block NSError* syncError = nil;
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
                
                [[syncError should] beNil];
                
            });
            
        });
        
    });
    
    describe(@"-lastNight", ^{
        
        __block SENServiceHealthKit* service = nil;
        
        beforeEach(^{
            service = [SENServiceHealthKit sharedService];
        });
        
        it(@"should be 1 day difference", ^{
            
            NSDate* lastNight = [service lastNight];
            NSDate* today = [NSDate date];

            NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSCalendarUnit flags = NSDayCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit;
            NSDateComponents* lastNightComps = [calendar components:flags fromDate:lastNight];
            
            NSDateComponents* adjustedComponents = [[NSDateComponents alloc] init];
            [adjustedComponents setDay:-1];
            
            NSDate* calculatedLastNightDate = [calendar dateByAddingComponents:adjustedComponents
                                                                        toDate:today
                                                                       options:0];
            NSDateComponents* calculatedLastNightComps = [calendar components:flags
                                                                     fromDate:calculatedLastNightDate];
            
            [[@([lastNightComps day]) should] equal:@([calculatedLastNightComps day])];
            [[@([lastNightComps month]) should] equal:@([calculatedLastNightComps month])];
            [[@([lastNightComps year]) should] equal:@([calculatedLastNightComps year])];
            
        });
        
        it(@"should not contain any time components", ^{
            
            NSDate* lastNight = [service lastNight];
            
            NSCalendar* calendar = [NSCalendar autoupdatingCurrentCalendar];
            NSCalendarUnit unitsWeWant = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
            NSDateComponents *components = [calendar components:unitsWeWant fromDate:lastNight];
            
            [[@([components hour]) should] equal:@(0)];
            [[@([components minute]) should] equal:@(0)];
            [[@([components second]) should] equal:@(0)];
            
        });
        
    });
    
});

SPEC_END
