//
//  SENServiceHealthKitSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <HealthKit/HealthKit.h>
#import "SENSleepResult.h"
#import "SENServiceHealthKit.h"

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

- (NSArray*)sleepDataPointsForSleepResult:(SENSleepResult*)sleepResult;
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
            
            __block SENSleepResult* sleepResult = nil;
            
            beforeEach(^{
                
                NSDictionary* json = @{@"score": @100,
                                       @"date":@([[NSDate date] timeIntervalSince1970] * 1000),
                                       @"segments" : @[
                                               @{@"id": @33421},
                                               @{@"id": @32995},
                                               ],
                                       @"statistics" : @{
                                               @"total_sleep" : @330,
                                               @"sound_sleep" : @123,
                                               @"times_awake" : @1,
                                               }
                                       };
                
                sleepResult = [[SENSleepResult alloc] initWithDictionary:json];
                
            });
            
            it(@"should return no data points", ^{
                
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints shouldNot] beNil];
                [[dataPoints should] haveCountOf:0];
                
            });
            
        });
        
        context(@"has sleep event, but no wake event", ^{
            
            __block SENSleepResult* sleepResult = nil;
            
            beforeEach(^{
                
                NSDictionary* json = @{@"score": @100,
                                       @"date":@([[NSDate date] timeIntervalSince1970] * 1000),
                                       @"segments" : @[
                                               @{@"id": @33421},
                                               @{@"id": @32995,
                                                 @"event_type" : @"SLEEP",
                                                 @"timestamp" : @([[NSDate date] timeIntervalSince1970] * 1000)
                                                 }
                                               ],
                                       @"statistics" : @{
                                               @"total_sleep" : @330,
                                               @"sound_sleep" : @123,
                                               @"times_awake" : @1,
                                               }
                                       };
                
                sleepResult = [[SENSleepResult alloc] initWithDictionary:json];
                
            });
            
            it(@"should return no data points", ^{
                
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints shouldNot] beNil];
                [[dataPoints should] haveCountOf:0];
                
            });
            
        });
        
        context(@"has sleep and wake events", ^{
            
            __block SENSleepResult* sleepResult = nil;
            __block NSTimeInterval sleepTime = [[NSDate date] timeIntervalSince1970];
            __block NSTimeInterval wakeTime = [[NSDate date] timeIntervalSince1970];
            
            beforeEach(^{
                
                NSDictionary* json = @{@"score": @100,
                                       @"date":@([[NSDate date] timeIntervalSince1970] * 1000),
                                       @"segments" : @[
                                               @{@"id": @32995,
                                                 @"event_type" : @"SLEEP",
                                                 @"timestamp" : @(sleepTime * 1000)
                                                 },
                                               @{@"id" : @32996,
                                                 @"event_type" : @"WAKE_UP",
                                                 @"timestamp" : @([[NSDate date] timeIntervalSince1970] * 1000)
                                                 },
                                               @{@"id" : @32997,
                                                 @"event_type" : @"WAKE_UP",
                                                 @"timestamp" : @(wakeTime * 1000)
                                                 }
                                               ],
                                       @"statistics" : @{
                                               @"total_sleep" : @330,
                                               @"sound_sleep" : @123,
                                               @"times_awake" : @1,
                                               }
                                       };
                
                sleepResult = [[SENSleepResult alloc] initWithDictionary:json];
                
            });
            
            it(@"should return 1 data point", ^{
                
                NSArray* dataPoints = [service sleepDataPointsForSleepResult:sleepResult];
                [[dataPoints should] haveCountOf:1];
                
                NSDate* startDate = [NSDate dateWithTimeIntervalSince1970:sleepTime];
                NSDate* endDate = [NSDate dateWithTimeIntervalSince1970:wakeTime];
                HKCategorySample* sample = dataPoints[0];
                [[[sample startDate] should] equal:startDate];
                [[[sample endDate] should] equal:endDate];
                
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
            NSDateComponents* todayComponents = [calendar components:flags fromDate:today];
            
            [[@([lastNightComps day]) should] equal:@([todayComponents day] - 1)];
            [[@([lastNightComps month]) should] equal:@([todayComponents month])];
            [[@([lastNightComps year]) should] equal:@([todayComponents year])];
            
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
