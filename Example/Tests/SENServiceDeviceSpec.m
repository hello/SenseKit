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

typedef void(^SENServiceDeviceCheckBlock)(SENServiceDeviceState state);

@interface SENServiceDevice()

- (void)setSystemState:(SENServiceDeviceState)state;
- (void)setSenseInfo:(SENDevice*)device;
- (void)setPillInfo:(SENDevice*)device;
- (void)checkDevicesState;
- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion;

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
    
    describe(@"-checkSystemState", ^{
        
        context(@"checking sense", ^{
            
            __block SENServiceDevice* service;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
                [service setSenseInfo:nil];
                [service setPillInfo:nil];
            });
            
            it(@"Sense Not Paired", ^{

                [service checkDevicesState];
                [[@([service deviceState]) should] equal:@(SENServiceDeviceStateSenseNotPaired)];
                
            });
            
            it(@"Sense No Data", ^{
                
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypeSense
                                                                  state:SENDeviceStateNoData
                                                                  color:SENDeviceColorBlack
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                [service setSenseInfo:device];
                [service checkDevicesState];
                [[@([service deviceState]) should] equal:@(SENServiceDeviceStateSenseNoData)];
                
            });
            
            it(@"WiFi check is skipped, when NO BLE", ^{
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypeSense
                                                                  state:SENDeviceStateNormal
                                                                  color:SENDeviceColorBlack
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                [service setSenseInfo:device];
                
                [[service shouldNotEventually] receive:@selector(getConfiguredWiFi:)];
                [service checkDevicesState];
            });
            
        });
        
        context(@"After Sense, (WiFi cannot be checked), Pill is checked", ^{
            
            __block SENServiceDevice* service = nil;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypeSense
                                                                  state:SENDeviceStateNormal
                                                                  color:SENDeviceColorBlack
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                [service setSenseInfo:device];
            });
            
            afterEach(^{
                [service clearStubs];
            });
           
            it(@"Pill Not Paired", ^{
                [service checkDevicesState];
                [[@([service deviceState]) should] equal:@(SENServiceDeviceStatePillNotPaired)];
            });
            
            it(@"Pill has low battery", ^{
                
                SENDevice* fakePill = [[SENDevice alloc] initWithDeviceId:@"2"
                                                                     type:SENDeviceTypePill
                                                                    state:SENDeviceStateLowBattery
                                                                    color:SENDeviceColorBlue
                                                          firmwareVersion:@"1"
                                                                 lastSeen:[NSDate date]];
                
                [service setPillInfo:fakePill];
                [service checkDevicesState];
                [[@([service deviceState]) should] equal:@(SENServiceDeviceStatePillLowBattery)];
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
    
});

SPEC_END
