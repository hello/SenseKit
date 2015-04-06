//
//  SENServiceDeviceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SenseKit.h>

typedef void(^SENServiceDeviceCheckBlock)(SENServiceDeviceState state);

SENDevice* (^CreateDevice)(SENDeviceType, SENDeviceState, NSDate*) = ^SENDevice*(SENDeviceType type, SENDeviceState state, NSDate* lastSeen) {
    return [[SENDevice alloc] initWithDeviceId:@"1"
                                          type:type
                                         state:state
                                         color:SENDeviceColorBlack
                               firmwareVersion:@"1"
                                      lastSeen:lastSeen];
};

@interface SENServiceDevice()

- (void)setSystemState:(SENServiceDeviceState)state;
- (void)setSenseInfo:(SENDevice*)device;
- (void)setPillInfo:(SENDevice*)device;
- (void)setLoadingInfo:(BOOL)isLoading;
- (void)setInfoLoaded:(BOOL)isLoaded;
- (void)checkDevicesState:(void (^)(SENServiceDeviceState))completion;
- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion;
- (void)checkSenseAndPillState:(void (^)(SENServiceDeviceState))completion;

@end

SPEC_BEGIN(SENServiceDeviceSpec)

describe(@"SENServiceDevice", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    beforeEach(^{
        [[SENServiceDevice sharedService] setSenseInfo:nil];
        [[SENServiceDevice sharedService] setPillInfo:nil];
        [[SENServiceDevice sharedService] setLoadingInfo:NO];
        [[SENServiceDevice sharedService] setInfoLoaded:NO];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    describe(@"+sharedService", ^{

        it(@"should be singleton", ^{

            SENService* service1 = [SENServiceDevice sharedService];
            SENService* service2 = [SENServiceDevice sharedService];
            [[service1 should] beIdenticalTo:service2];

            SENService* service3 = [[SENServiceDevice alloc] init];
            [[service1 should] beIdenticalTo:service3];

        });

    });

    describe(@"-loadDeviceInfo:", ^{

        context(@"info is not being loaded already", ^{

            __block SENDevice *sense, *pill;

            beforeEach(^{
                sense = CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate date]);
                pill = CreateDevice(SENDeviceTypePill, SENDeviceStateNormal, [NSDate date]);
                [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[sense, pill], nil);
                    return nil;
                }];
            });

            it(@"fetches paired device info from the API", ^{
                [[SENAPIDevice should] receive:@selector(getPairedDevices:)];
                [[SENServiceDevice sharedService] loadDeviceInfo:NULL];
            });

            it(@"updates sense info with device metadata", ^{
                [[SENServiceDevice sharedService] loadDeviceInfo:NULL];
                [[[[SENServiceDevice sharedService] senseInfo] should] equal:sense];
            });

            it(@"update pill info with device metadata", ^{
                [[SENServiceDevice sharedService] loadDeviceInfo:NULL];
                [[[[SENServiceDevice sharedService] pillInfo] should] equal:pill];
            });
        });

        context(@"info is already being loaded", ^{

            beforeEach(^{
                [[SENServiceDevice sharedService] setLoadingInfo:YES];
            });

            it(@"invokes the completion block with an error", ^{
                __block NSError* loadingError = nil;
                [[SENServiceDevice sharedService] loadDeviceInfo:^(NSError *error) {
                    loadingError = error;
                }];
                [[@([loadingError code]) should] equal:@(SENServiceDeviceErrorInProgress)];
            });

            it(@"does not make a request for new device info", ^{
                [[SENAPIDevice shouldNot] receive:@selector(getPairedDevices:)];
                [[SENServiceDevice sharedService] loadDeviceInfo:NULL];
            });
        });
    });

    describe(@"-loadDeviceInfoIfNeeded:", ^{

        context(@"device info is not yet loaded", ^{

            beforeEach(^{
                [SENAPIDevice stub:@selector(getPairedDevices:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
            });

            it(@"loads device info", ^{
                [[SENAPIDevice should] receive:@selector(getPairedDevices:)];
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:NULL];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:^(NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) should] beYes];
            });
        });

        context(@"device info is being loaded", ^{

            beforeEach(^{
                [[SENServiceDevice sharedService] setLoadingInfo:YES];
            });

            it(@"invokes the completion block with an error", ^{
                __block NSError* loadingError = nil;
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:^(NSError *error) {
                    loadingError = error;
                }];
                [[@([loadingError code]) should] equal:@(SENServiceDeviceErrorInProgress)];
            });

            it(@"does not reload device info", ^{
                [[SENAPIDevice shouldNot] receive:@selector(getPairedDevices:)];
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:NULL];
            });
        });

        context(@"device info is already loaded", ^{

            beforeEach(^{
                [[SENServiceDevice sharedService] setSenseInfo:CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate date])];
                [[SENServiceDevice sharedService] setPillInfo:CreateDevice(SENDeviceTypePill, SENDeviceStateNormal, [NSDate date])];
                [[SENServiceDevice sharedService] setInfoLoaded:YES];
            });

            it(@"invokes the completion block", ^{
                __block BOOL callbackInvoked = NO;
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:^(NSError *error) {
                    callbackInvoked = YES;
                }];
                [[@(callbackInvoked) should] beYes];
            });

            it(@"does not reload device info", ^{
                [[SENAPIDevice shouldNot] receive:@selector(getPairedDevices:)];
                [[SENServiceDevice sharedService] loadDeviceInfoIfNeeded:NULL];
            });
        });
    });

    describe(@"-checkDevicesState:", ^{

        __block SENServiceDeviceState deviceState;

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
                deviceState = SENServiceDeviceStateUnknown;
            });

            afterEach(^{
                [service clearStubs];
            });

            context(@"sense is not paired", ^{

                beforeEach(^{
                    [service setSenseInfo:nil];
                    [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                        void(^callback)(NSError* error) = [params firstObject];
                        if (callback) callback (nil);
                        return nil;
                    }];

                    [service checkDevicesState:^(SENServiceDeviceState state) {
                        deviceState = state;
                    }];
                });

                it(@"returns sense not paired state", ^{
                    [[@(deviceState) should] equal:@(SENServiceDeviceStateSenseNotPaired)];
                });
            });

            context(@"sense has no data", ^{

                beforeEach(^{
                    [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                        [service setSenseInfo:CreateDevice(SENDeviceTypeSense, SENDeviceStateNoData, [NSDate date])];
                        void(^callback)(NSError* error) = [params firstObject];
                        if (callback) callback (nil);
                        return nil;
                    }];

                    [service checkDevicesState:^(SENServiceDeviceState state) {
                        deviceState = state;
                    }];
                });

                it(@"returns 'no data' state", ^{
                    [[@(deviceState) should] equal:@(SENServiceDeviceStateSenseNoData)];
                });
            });
        });

        context(@"pill is checked", ^{

            __block SENServiceDevice* service = nil;
            beforeEach(^{
                service = [SENServiceDevice sharedService];
                [service stub:@selector(loadDeviceInfo:) withBlock:^id(NSArray *params) {
                    [service setSenseInfo:CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate date])];
                    void(^callback)(NSError* error) = [params firstObject];
                    if (callback) callback (nil);
                    return nil;
                }];
            });

            afterEach(^{
                [service clearStubs];
            });

            context(@"pill is not paired", ^{

                beforeEach(^{
                    [service setPillInfo: nil];
                    [service checkDevicesState:^(SENServiceDeviceState state) {
                        deviceState = state;
                    }];
                });

                it(@"returns pill not paired state", ^{
                    [[@(deviceState) should] equal:@(SENServiceDeviceStatePillNotPaired)];
                });
            });

            context(@"pill has a low battery", ^{

                beforeEach(^{
                    [service setPillInfo:CreateDevice(SENDeviceTypePill, SENDeviceStateLowBattery, [NSDate date])];
                    [service checkDevicesState:^(SENServiceDeviceState state) {
                        deviceState = state;
                    }];
                });

                it(@"returns pill has low battery state", ^{
                    [[@(deviceState) should] equal:@(SENServiceDeviceStatePillLowBattery)];
                });
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

            [service setSenseInfo:CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate date])];
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
        __block SENDevice* device = nil;

        beforeEach(^{
            service = [SENServiceDevice sharedService];
        });

        afterEach(^{
            device = nil;
        });

        context(@"sense is checked", ^{

            context(@"sense has been seen recently", ^{

                beforeEach(^{
                    device = CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate date]);
                });

                it(@"should return NO", ^{
                    BOOL warn = [service shouldWarnAboutLastSeenForDevice:device];
                    [[@(warn) should] beNo];
                });
            });

            context(@"sense has not been seen recently", ^{

                beforeEach(^{
                    device = CreateDevice(SENDeviceTypeSense, SENDeviceStateNormal, [NSDate dateWithTimeIntervalSince1970:0]);
                });

                it(@"should return YES", ^{
                    BOOL warn = [service shouldWarnAboutLastSeenForDevice:device];
                    [[@(warn) should] beYes];
                });
            });
        });

        context(@"pill is checked", ^{

            context(@"pill has been seen recently", ^{

                beforeEach(^{
                    device = CreateDevice(SENDeviceTypePill, SENDeviceStateNormal, [NSDate date]);
                });

                it(@"should return NO", ^{
                    BOOL warn = [service shouldWarnAboutLastSeenForDevice:device];
                    [[@(warn) should] beNo];
                });
            });

            context(@"pill has not been seen recently", ^{

                beforeEach(^{
                    device = CreateDevice(SENDeviceTypePill, SENDeviceStateNormal, [NSDate dateWithTimeIntervalSince1970:0]);
                });

                it(@"should return YES", ^{
                    BOOL warn = [service shouldWarnAboutLastSeenForDevice:device];
                    [[@(warn) should] beYes];
                });
            });

            context(@"pill has never been seen", ^{

                beforeEach(^{
                    device = CreateDevice(SENDeviceTypePill, SENDeviceStateNormal, nil);
                });

                it(@"should return NO", ^{
                    BOOL warn = [service shouldWarnAboutLastSeenForDevice:device];
                    [[@(warn) should] beNo];
                });
            });

        });

    });

});

SPEC_END
