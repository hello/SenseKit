//
//  SENServiceDeviceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <Kiwi/Kiwi.h>
#import "SENServiceDevice.h"
#import "SENDevice.h"
#import "SENSense.h"
#import "SENSenseManager.h"
#import "SENAuthorizationService.h"

typedef void(^SENServiceDeviceCheckBlock)(SENServiceDeviceState state);

@interface SENServiceDevice()

- (void)setSystemState:(SENServiceDeviceState)state;
- (void)setSenseInfo:(SENDevice*)device;
- (void)setPillInfo:(SENDevice*)device;
- (void)checkDevicesState:(void (^)(SENServiceDeviceState))completion;
- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion;
- (void)checkSenseAndPillState:(void (^)(SENServiceDeviceState))completion;

@end

SPEC_BEGIN(SENServiceDeviceSpec)

describe(@"SENServiceDeviceSpec", ^{
    
    describe(@"+sharedService", ^{
        
        it(@"should be singleton", ^{
            
            SENService* service1 = [SENServiceDevice sharedService];
            SENService* service2 = [SENServiceDevice sharedService];
            [[service1 should] beIdenticalTo:service2];
            
            SENService* service3 = [[SENServiceDevice alloc] init];
            [[service1 should] beIdenticalTo:service3];
            
        });
        
    });
    
    describe(@"-checkDevicesState:", ^{
        
        beforeEach(^{
            [SENAuthorizationService stub:@selector(isAuthorized) andReturn:[KWValue valueWithBool:YES]];
        });
        
        afterEach(^{
            [SENAuthorizationService clearStubs];
        });
        
        context(@"sense is checked", ^{
            
            __block SENServiceDevice* service;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
            });
            
            afterEach(^{
                [service clearStubs];
            });
            
            it(@"returns sense not paired state", ^{
                
                [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSError* error) = [params firstObject];
                    if (callback) callback (nil);
                    return nil;
                }];

                __block SENServiceDeviceState deviceState = SENServiceDeviceStateUnknown;
                [service checkDevicesState:^(SENServiceDeviceState state) {
                    deviceState = state;
                }];
                
                [[@(deviceState) should] equal:@(SENServiceDeviceStateSenseNotPaired)];
                
            });
            
            it(@"returns sense not paired state", ^{
                
                [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    [service setSenseInfo:[[SENDevice alloc] initWithDeviceId:@"1"
                                                                         type:SENDeviceTypeSense
                                                                        state:SENDeviceStateNoData
                                                                        color:SENDeviceColorBlack
                                                              firmwareVersion:@"1"
                                                                     lastSeen:[NSDate date]]];
                    
                    void(^callback)(NSError* error) = [params firstObject];
                    if (callback) callback (nil);
                    return nil;
                }];
                
                __block SENServiceDeviceState deviceState = SENServiceDeviceStateUnknown;
                [service checkDevicesState:^(SENServiceDeviceState state) {
                    deviceState = state;
                }];
                
                [[@(deviceState) should] equal:@(SENServiceDeviceStateSenseNoData)];
                
            });
            
        });
        
        context(@"pill is checked", ^{
            
            __block SENServiceDevice* service = nil;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
                [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    [service setSenseInfo:[[SENDevice alloc] initWithDeviceId:@"1"
                                                                         type:SENDeviceTypeSense
                                                                        state:SENDeviceStateNormal
                                                                        color:SENDeviceColorBlack
                                                              firmwareVersion:@"1"
                                                                     lastSeen:[NSDate date]]];

                    void(^callback)(NSError* error) = [params firstObject];
                    if (callback) callback (nil);
                    return nil;
                }];
            });
            
            afterEach(^{
                [service clearStubs];
            });
           
            it(@"returns pill not paired state", ^{
                
                __block SENServiceDeviceState deviceState = SENServiceDeviceStateUnknown;
                [service checkDevicesState:^(SENServiceDeviceState state) {
                    deviceState = state;
                }];
                
                [[@(deviceState) should] equal:@(SENServiceDeviceStatePillNotPaired)];
                
            });
            
            it(@"returns pill has low battery state", ^{
                
                SENDevice* fakePill = [[SENDevice alloc] initWithDeviceId:@"2"
                                                                     type:SENDeviceTypePill
                                                                    state:SENDeviceStateLowBattery
                                                                    color:SENDeviceColorBlue
                                                          firmwareVersion:@"1"
                                                                 lastSeen:[NSDate date]];
                
                [service setPillInfo:fakePill];
                __block SENServiceDeviceState deviceState = SENServiceDeviceStateUnknown;
                [service checkDevicesState:^(SENServiceDeviceState state) {
                    deviceState = state;
                }];
                
                [[@(deviceState) should] equal:@(SENServiceDeviceStatePillLowBattery)];
            });
            
        });
        
    });
    
    describe(@"-whenPairedSenseIsReadyDo:", ^{
        
        it(@"Will fail with no sense paired", ^{
            
            __block NSError* senseError = nil;
            SENServiceDevice* service = [SENServiceDevice sharedService];
            [service setSenseInfo:nil];
            [service whenPairedSenseIsReadyDo:^(NSError *error) {
                senseError = error;
            }];
            
            [[expectFutureValue(@([senseError code])) shouldSoon] equal:@(SENServiceDeviceErrorSenseNotPaired)];
        });
        
        it(@"Will fail with sense not available", ^{
            
            __block NSError* senseError = nil;
            SENServiceDevice* service = [SENServiceDevice sharedService];
            [service setSenseInfo:[[SENDevice alloc] initWithDeviceId:@"1"
                                                                 type:SENDeviceTypeSense
                                                                state:SENDeviceStateNormal
                                                                color:SENDeviceColorBlack
                                                      firmwareVersion:@"1"
                                                             lastSeen:[NSDate date]]];
            [service whenPairedSenseIsReadyDo:^(NSError *error) {
                senseError = error;
            }];
            
            [[expectFutureValue(@([senseError code])) shouldSoon] equal:@(SENServiceDeviceErrorSenseUnavailable)];
            
        });
        
    });
    
    describe(@"-replaceWithNewlyPairedSenseManager:completion", ^{
        
        __block NSString* deviceId = nil;
        __block SENServiceDevice* service = nil;
        __block SENSense* sense = nil;
        
        beforeEach(^{
            deviceId = @"1";
            service = [SENServiceDevice sharedService];
            sense = [[SENSense alloc] init];
            [sense stub:@selector(deviceId) andReturn:deviceId];
            [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                [service setSenseInfo:[[SENDevice alloc] initWithDeviceId:deviceId
                                                                     type:SENDeviceTypeSense
                                                                    state:SENDeviceStateNormal
                                                                    color:SENDeviceColorBlack
                                                          firmwareVersion:@"1"
                                                                 lastSeen:[NSDate date]]];
                
                void(^callback)(NSError* error) = [params firstObject];
                if (callback) callback (nil);
                return nil;
            }];
        });
        
        afterEach(^{
            [service clearStubs];
            [sense clearStubs];
        });
        
        it(@"should fail because sense manager not initialized with sense", ^{
            
            __block NSError* deviceError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] init];
            [service replaceWithNewlyPairedSenseManager:manager completion:^(NSError *error) {
                deviceError = error;
            }];
            
            [[expectFutureValue(@([deviceError code])) shouldSoon] equal:@(SENServiceDeviceErrorSenseUnavailable)];
            [[expectFutureValue([service senseManager]) shouldSoon] beNil];
            
        });
        
        it(@"should fail if sense in manager not matching device info", ^{
            
            [sense stub:@selector(deviceId) andReturn:@"notit"];
            __block NSError* deviceError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:sense];
            [service replaceWithNewlyPairedSenseManager:manager completion:^(NSError *error) {
                deviceError = error;
            }];
            
            [[expectFutureValue(@([deviceError code])) shouldSoon] equal:@(SENServiceDeviceErrorSenseNotMatching)];
            
        });
        
        it(@"should succeed with an intiialized sense that matches device info", ^{
            
            [sense stub:@selector(deviceId) andReturn:deviceId];
            __block NSError* deviceError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:sense];
            [service replaceWithNewlyPairedSenseManager:manager completion:^(NSError *error) {
                deviceError = error;
            }];
            
            [[expectFutureValue(deviceError) shouldSoon] beNil];
            [[expectFutureValue([service senseManager]) shouldSoon] beNonNil];
            
        });
        
    });
    
    describe(@"-shouldWarnAboutLastSeenForDevice:", ^{
        __block SENServiceDevice* service = nil;
        
        beforeEach(^{
            service = [SENServiceDevice sharedService];
        });
        
        context(@"Sense last seen", ^{
            
            it(@"should return NO", ^{
                SENDevice* sense = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                  type:SENDeviceTypeSense
                                                                 state:SENDeviceStateNormal
                                                                 color:SENDeviceColorBlack
                                                       firmwareVersion:@"1"
                                                              lastSeen:[NSDate date]];
                BOOL warn = [service shouldWarnAboutLastSeenForDevice:sense];
                [[@(warn) should] beNo];
            });
            
            it(@"should return YES", ^{
                SENDevice* sense = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                  type:SENDeviceTypeSense
                                                                 state:SENDeviceStateNormal
                                                                 color:SENDeviceColorBlack
                                                       firmwareVersion:@"1"
                                                              lastSeen:[NSDate dateWithTimeIntervalSince1970:0]];
                BOOL warn = [service shouldWarnAboutLastSeenForDevice:sense];
                [[@(warn) should] beYes];
            });

        });
        
        context(@"Pill last seen", ^{
            
            it(@"should return NO", ^{
                SENDevice* pill = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                 type:SENDeviceTypePill
                                                                state:SENDeviceStateNormal
                                                                color:SENDeviceColorBlack
                                                      firmwareVersion:@"1"
                                                             lastSeen:[NSDate date]];
                BOOL warn = [service shouldWarnAboutLastSeenForDevice:pill];
                [[@(warn) should] beNo];
            });
            
            it(@"should return YES", ^{
                SENDevice* pill = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                 type:SENDeviceTypePill
                                                                state:SENDeviceStateNormal
                                                                color:SENDeviceColorBlack
                                                      firmwareVersion:@"1"
                                                             lastSeen:[NSDate dateWithTimeIntervalSince1970:0]];
                BOOL warn = [service shouldWarnAboutLastSeenForDevice:pill];
                [[@(warn) should] beYes];
            });
            
            it(@"should return NO, if no last seen date yet", ^{
                
                SENDevice* pill = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                 type:SENDeviceTypePill
                                                                state:SENDeviceStateNormal
                                                                color:SENDeviceColorBlack
                                                      firmwareVersion:@"1"
                                                             lastSeen:nil];
                BOOL warn = [service shouldWarnAboutLastSeenForDevice:pill];
                [[@(warn) should] beNo];
                
            });
            
        });
        
    });
    
});

SPEC_END
