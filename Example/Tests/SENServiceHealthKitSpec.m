//
//  SENServiceHealthKitSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <HealthKit/HealthKit.h>
#import "SENServiceHealthKit.h"

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

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
    
});

SPEC_END
