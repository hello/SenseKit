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
#import "SENAPITimeline.h"
#import "SENServiceHealthKit.h"

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

- (NSArray*)sleepDataPointsForSleepResult:(SENTimeline*)sleepResult;
- (BOOL)isHealthKitEnabled;
- (void)syncRecentMissingDays:(void(^)(NSError* error))completion;
- (NSDate*)lastSyncDate;
- (void)syncTimelineDataAfter:(NSDate*)startDate
                        until:(NSDate*)endDate
                 withCalendar:(NSCalendar*)calendar
                   completion:(void(^)(NSArray* timelines, NSError* error))completion;
- (void)timelineForDate:(NSDate*)date
             completion:(void(^)(SENTimeline* timeline, NSError* error))completion;
- (void)syncTimelinesToHealthKit:(NSArray*)timelines completion:(void(^)(NSError* error))completion;

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
        
    describe(@"-sync:", ^{
        
        __block SENServiceHealthKit* service = nil;
        __block NSError* syncError = nil;
        __block BOOL syncCompleted = NO;
        
        beforeEach(^{
            service = [SENServiceHealthKit sharedService];
        });
        
        context(@"healthkit is not not enabled as a preference", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return with not enabled error", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotEnabled)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"device / iOS does not support HealthKit", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return error saying not supported", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotSupported)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"user did not give permissions for Sense to access health data", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should return error stating not authorized", ^{
                [[syncError shouldNot] beNil];
                [[@([syncError code]) should] equal:@(SENServiceHealthKitErrorNotAuthorized)];
            });
            
            it(@"should not have completed a sync to get the error", ^{
                [[@(syncCompleted) shouldNot] beYes];
            });
            
        });
        
        context(@"HealthKit is supported, enabled, and authorized", ^{
            
            beforeEach(^{
                [service stub:@selector(isHealthKitEnabled) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(isSupported) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(canWriteSleepAnalysis) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(syncRecentMissingDays:) withBlock:^id(NSArray *params) {
                    void(^cb)(NSError* error) = [params lastObject];
                    syncCompleted = YES;
                    cb (nil);
                    return nil;
                }];
                [service sync:^(NSError *error) {
                    syncError = error;
                }];
            });
            
            afterEach(^{
                syncCompleted = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should not return an error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should have completed a sync, since it's stubbed", ^{
                [[@(syncCompleted) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-syncRecentMissingDays:", ^{
        
        __block SENServiceHealthKit* service = nil;
        __block NSDate* startSyncDate = nil;
        __block NSDate* endSyncDate = nil;
        __block NSDate* lastNight = nil;
        __block BOOL calledBack = NO;
        __block NSError* syncError = nil;
        __block NSCalendar* calendar = nil;
        
        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
            NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
            NSDate* today = [calendar dateFromComponents:todayComponents];
            
            NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
            [lastNightComponents setDay:-1];
            lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
            
            service = [SENServiceHealthKit sharedService];
        });
        
        context(@"never sync'ed successfully before", ^{
            
            beforeEach(^{
                [service stub:@selector(lastSyncDate) andReturn:nil];
                [service stub:@selector(syncTimelineDataAfter:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timelines, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should try and sync with last night as the start date", ^{
                [[startSyncDate should] equal:lastNight];
            });
            
            it(@"should have end syc date equal to last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
        context(@"sync'ed before, 2 days before last night", ^{
            
            __block NSDate* lastWrittenDate = nil;
            
            beforeEach(^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-2];
                lastWrittenDate = [calendar dateByAddingComponents:backFillComps toDate:lastNight options:0];
                
                [service stub:@selector(lastSyncDate) andReturn:lastWrittenDate];
                [service stub:@selector(syncTimelineDataAfter:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timeine, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new], [SENTimeline new], [SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should try and sync from lastWrittenDate", ^{
                [[startSyncDate should] equal:lastWrittenDate];
            });
            
            it(@"should sync until last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
        context(@"sync'ed before, 4 days before last night", ^{
            
            __block NSDate* lastWrittenDate = nil;
            
            beforeEach(^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-4];
                lastWrittenDate = [calendar dateByAddingComponents:backFillComps toDate:lastNight options:0];
                
                [service stub:@selector(lastSyncDate) andReturn:lastWrittenDate];
                [service stub:@selector(syncTimelineDataAfter:until:withCalendar:completion:)
                    withBlock:^id(NSArray *params) {
                        startSyncDate = [params firstObject];
                        endSyncDate = params[1];
                        void(^cb)(NSArray* timelines, NSError* error) = [params lastObject];
                        cb (@[[SENTimeline new], [SENTimeline new], [SENTimeline new], [SENTimeline new], [SENTimeline new]], nil);
                        return nil;
                    }];
                
                [service syncRecentMissingDays:^(NSError *error) {
                    calledBack = YES;
                    syncError = error;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
                calledBack = NO;
                startSyncDate = nil;
                endSyncDate = nil;
                syncError = nil;
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have encountered error", ^{
                [[syncError should] beNil];
            });
            
            it(@"should try and sync from the limit of 3 days past last night", ^{
                NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
                [backFillComps setDay:-3];
                NSDate* startDate = [calendar dateByAddingComponents:backFillComps
                                                              toDate:lastNight
                                                             options:0];
                [[startSyncDate should] equal:startDate];
            });
            
            it(@"should sync until last night", ^{
                [[endSyncDate should] equal:lastNight];
            });
            
        });
        
    });
    
    describe(@"-timelineForDate:completion:", ^{
        
        __block SENServiceHealthKit* service = nil;
        __block BOOL apiCalled = NO;
        __block BOOL calledBack = NO;
        __block NSError* timelineError = nil;
        
        beforeEach(^{
            service = [SENServiceHealthKit sharedService];
        });
        
        afterEach(^{
            [SENAPITimeline clearStubs];
        });
        
        context(@"device has local timeline data", ^{
            
            beforeEach(^{
                SENTimeline* timeline = [[SENTimeline alloc] init];
                [timeline setScoreCondition:SENConditionIdeal];
                [timeline setMetrics:@[[SENTimelineMetric new]]];
                [SENTimeline stub:@selector(timelineForDate:) andReturn:timeline];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(SENTimeline* timeline, NSError* error) = [params lastObject];
                    cb([SENTimeline new], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return error", ^{
                [[timelineError should] beNil];
            });
            
            it(@"should not call api", ^{
                [[@(apiCalled) should] beNo];
            });
            
        });
        
        context(@"device does not have local timeline data, api returns timeline", ^{
            
            beforeEach(^{
                [SENTimeline stub:@selector(timelineForDate:) andReturn:nil];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(SENTimeline* timeline, NSError* error) = [params lastObject];
                    cb([SENTimeline new], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return error", ^{
                [[timelineError should] beNil];
            });
            
            it(@"should call api", ^{
                [[@(apiCalled) should] beYes];
            });
            
        });
        
        context(@"device does not have local timeline data, api returns junk", ^{
            
            beforeEach(^{
                [SENTimeline stub:@selector(timelineForDate:) andReturn:nil];
                [SENAPITimeline stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(id data, NSError* error) = [params lastObject];
                    cb([NSArray array], nil);
                    apiCalled = YES;
                    return nil;
                }];
                [service timelineForDate:[NSDate date] completion:^(SENTimeline *timeline, NSError *error) {
                    calledBack = YES;
                    timelineError = error;
                }];
            });
            
            afterEach(^{
                [SENTimeline clearStubs];
                [SENAPITimeline clearStubs];
                apiCalled = NO;
                calledBack = NO;
                timelineError = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should return unexpected api response error", ^{
                [[timelineError shouldNot] beNil];
                [[@([timelineError code]) should] equal:@(SENServiceHealthKitErrorUnexpectedAPIResponse)];
            });
            
            it(@"should call api", ^{
                [[@(apiCalled) should] beYes];
            });
            
        });
        
    });
    
    describe(@"-syncTimelineDataAfter:until:withCalendar:completion", ^{
        
        __block SENServiceHealthKit* service = nil;
        __block NSCalendar* calendar = nil;
        __block NSDate* lastNight = nil;
        __block NSDate* today = nil;
        
        beforeEach(^{
            calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
            NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
            today = [calendar dateFromComponents:todayComponents];
            
            NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
            [lastNightComponents setDay:-1];
            lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
            
            service = [SENServiceHealthKit sharedService];
            [service stub:@selector(timelineForDate:completion:) withBlock:^id(NSArray *params) {
                void(^cb)(SENTimeline *timeline, NSError *error) = [params lastObject];
                cb ([[SENTimeline alloc] init], nil);
                return nil;
            }];
            
            [service stub:@selector(syncTimelinesToHealthKit:completion:) withBlock:^id(NSArray *params) {
                void(^cb)(NSError* error) = [params lastObject];
                cb (nil);
                return nil;
            }];
        });
        
        afterEach(^{
            [service clearStubs];
        });
        
        context(@"starts from the night before last night", ^{
            
            __block BOOL syncCallback = NO;
            __block NSError* syncError = nil;
            __block NSUInteger numberOfTimelinesToSync = 0;
            
            beforeAll(^{
                NSDateComponents* twoNightsComponents = [[NSDateComponents alloc] init];
                [twoNightsComponents setDay:-2];
                NSDate* twoNights = [calendar dateByAddingComponents:twoNightsComponents toDate:today options:0];

                [service syncTimelineDataAfter:twoNights until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
                    numberOfTimelinesToSync = [timelines count];
                    syncCallback = YES;
                    syncError = error;
                }];
            });
            
            afterAll(^{
                numberOfTimelinesToSync = 0;
                syncCallback = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should attempt to sync 2 timelines", ^{
                [[expectFutureValue(@(numberOfTimelinesToSync)) shouldSoon] equal:@2];
            });
            
            it(@"should call back", ^{
                [[expectFutureValue(@(syncCallback)) shouldSoon] beYes];
            });
            
            it(@"should not return an error", ^{
                [[expectFutureValue(syncError) shouldSoon] beNil];
            });
            
        });
        
        context(@"starts from last night", ^{
            
            __block BOOL syncCallback = NO;
            __block NSError* syncError = nil;
            __block NSUInteger numberOfTimelinesToSync = 0;
            
            beforeAll(^{
                [service syncTimelineDataAfter:lastNight until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
                    numberOfTimelinesToSync = [timelines count];
                    syncCallback = YES;
                    syncError = error;
                }];
            });
            
            afterAll(^{
                numberOfTimelinesToSync = 0;
                syncCallback = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should attempt to sync 1 timeline1", ^{
                [[expectFutureValue(@(numberOfTimelinesToSync)) shouldSoon] equal:@1];
            });
            
            it(@"should call back", ^{
                [[expectFutureValue(@(syncCallback)) shouldSoon] beYes];
            });
            
            it(@"should not return an error", ^{
                [[expectFutureValue(syncError) shouldSoon] beNil];
            });
            
        });
        
        context(@"starts from today (day after last night)", ^{
            
            __block BOOL syncCallback = NO;
            __block NSError* syncError = nil;
            __block NSUInteger numberOfTimelinesToSync = 0;
            
            beforeAll(^{
                [service syncTimelineDataAfter:[NSDate date] until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
                    numberOfTimelinesToSync = [timelines count];
                    syncCallback = YES;
                    syncError = error;
                }];
            });
            
            afterAll(^{
                numberOfTimelinesToSync = 0;
                syncCallback = NO;
                syncError = nil;
                [service clearStubs];
            });
            
            it(@"should not return any timelines to sync", ^{
                [[expectFutureValue(@(numberOfTimelinesToSync)) shouldSoon] equal:@0];
            });
            
            it(@"should call back", ^{
                [[expectFutureValue(@(syncCallback)) shouldSoon] beYes];
            });
            
            it(@"should return an error with no data to write", ^{
                [[expectFutureValue(@([syncError code])) shouldSoon] equal:@(SENServiceHealthKitErrorNoDataToWrite)];
            });
            
        });
        
    });
    
});

SPEC_END
