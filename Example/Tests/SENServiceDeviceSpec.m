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

typedef void(^SENServiceDeviceCheckBlock)(SENServiceDeviceState state);

@interface SENServiceDevice()

- (void)setSystemState:(SENServiceDeviceState)state;
- (void)setSenseInfo:(SENDevice*)device;
- (void)setPillInfo:(SENDevice*)device;
- (void)checkSenseWiFiState:(void(^)(SENServiceDeviceState state))completion;
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
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                [service setSenseInfo:device];
                [service checkDevicesState];
                [[@([service deviceState]) should] equal:@(SENServiceDeviceStateSenseNoData)];
                
            });
            
        });
        
        context(@"After Sense, (WiFi cannot be checked), Pill is checked", ^{
            
            __block SENServiceDevice* service = nil;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypeSense
                                                                  state:SENDeviceStateNormal
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                [service stub:@selector(checkSenseWiFiState:) withBlock:^id(NSArray *params) {
                    SENServiceDeviceCheckBlock block = [params lastObject];
                    block (SENServiceDeviceStateNormal);
                    return nil;
                }];
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
            
            [[expectFutureValue(@([senseError code])) shouldEventually] equal:@(SENServiceDeviceErrorSenseNotPaired)];
        });
        
        it(@"Will fail with sense not available", ^{
            
            __block NSError* senseError = nil;
            SENServiceDevice* service = [SENServiceDevice sharedService];
            [service setSenseInfo:[[SENDevice alloc] initWithDeviceId:@"1"
                                                                 type:SENDeviceTypeSense
                                                                state:SENDeviceStateNormal
                                                      firmwareVersion:@"1"
                                                             lastSeen:[NSDate date]]];
            [service whenPairedSenseIsReadyDo:^(NSError *error) {
                senseError = error;
            }];
            
            [[expectFutureValue(@([senseError code])) shouldEventually] equal:@(SENServiceDeviceErrorSenseUnavailable)];
            
        });
        
    });
    
});

SPEC_END
