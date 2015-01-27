//
//  SENServiceHealthKitSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <HealthKit/HealthKit.h>
#import "SENServiceHealthKit.h"

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
        
        it(@"should return YES if healthstore is available", ^{
            
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            BOOL supported = [service isSupported];
            [[@(supported) should] equal:@([HKHealthStore isHealthDataAvailable])];
            
        });
        
    });
    
    describe(@"-canWriteSleepAnalysis", ^{
        
        it(@"should return NO", ^{
            
            SENServiceHealthKit* service = [SENServiceHealthKit sharedService];
            BOOL canWrite = [service canWriteSleepAnalysis];
            [[@(canWrite) should] beNo];
            
        });
        
    });
    
});

SPEC_END
