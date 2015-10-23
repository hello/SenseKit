//
//  SENServiceDeviceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/30/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/Services.h>
#import <SenseKit/API.h>

@interface SENServiceDevice()

- (void)whenPairedSenseIsReadyDo:(void(^)(NSError* error))completion;
- (void)setSenseManager:(SENSenseManager*)manager;
- (void)setDevices:(SENPairedDevices*)devices;

@end

SPEC_BEGIN(SENServiceDeviceSpec)

describe(@"SENServiceDevice", ^{
    
    __block SENServiceDevice* service = nil;
    
    beforeAll(^{
        service = [SENServiceDevice sharedService];
    });

    describe(@"- restoreFactorySettings:", ^{
        
        __block SENPairedDevices* devices = nil;
        __block SENSenseManager* manager = nil;
        __block BOOL calledSetLED = NO;
        __block BOOL calledRemoveAssociations = NO;
        __block BOOL calledResetToFactoryOnSense = NO;
        __block BOOL disconnectedFromSense = NO;
        __block BOOL calledBack = NO;
        __block NSError* serviceError = nil;
        
        beforeEach(^{
            devices = [SENPairedDevices new];
            manager = [SENSenseManager new];
        });
        
        afterEach(^{
            [service clearStubs];
            [SENAPIDevice clearStubs];
            calledSetLED = NO;
            calledRemoveAssociations = NO;
            calledResetToFactoryOnSense = NO;
            disconnectedFromSense = NO;
            calledBack = NO;
            manager = nil;
            serviceError = nil;
            devices = nil;
        });
        
        context(@"account has a paired sense, is nearby, and all is happy", ^{
            
            beforeEach(^{
                [devices stub:@selector(hasPairedSense) andReturn:[KWValue valueWithBool:YES]];
                [service stub:@selector(devices) andReturn:devices];
                
                [manager stub:@selector(resetToFactoryState:failure:) withBlock:^id(NSArray *params) {
                    calledResetToFactoryOnSense = YES;
                    void(^success)(id response) = [params firstObject];
                    success(nil);
                    return nil;
                }];
                
                [manager stub:@selector(disconnectFromSense) withBlock:^id(NSArray *params) {
                    disconnectedFromSense = YES;
                    return nil;
                }];
                
                [service stub:@selector(senseManager) andReturn:manager];
                
                [service stub:@selector(whenPairedSenseIsReadyDo:) withBlock:^id(NSArray *params) {
                    void(^block)(NSError* error) = [params lastObject];
                    block(nil);
                    return nil;
                }];
                
                [service stub:@selector(setLEDState:completion:) withBlock:^id(NSArray *params) {
                    calledSetLED = YES;
                    void(^block)(NSError* error) = [params lastObject];
                    block (nil);
                    return nil;
                }];
                
                [SENAPIDevice stub:@selector(removeAssociationsToSense:completion:) withBlock:^id(NSArray *params) {
                    calledRemoveAssociations = YES;
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                [service restoreFactorySettings:^(NSError *error) {
                    calledBack = YES;
                    serviceError = error;
                }];
                
            });
            
            afterEach(^{
                [service clearStubs];
                [SENAPIDevice clearStubs];
                calledSetLED = NO;
                calledRemoveAssociations = NO;
                calledResetToFactoryOnSense = NO;
                disconnectedFromSense = NO;
                calledBack = NO;
                manager = nil;
                serviceError = nil;
                devices = nil;
            });
            
            it(@"should not return an error", ^{
                [[serviceError should] beNil];
            });
            
            it(@"should have set LED", ^{
                [[@(calledSetLED) should] beYes];
            });
            
            it(@"should have removed associations", ^{
                [[@(calledRemoveAssociations) should] beYes];
            });
            
            it(@"should have factory reset sense", ^{
                [[@(calledResetToFactoryOnSense) should] beYes];
            });
            
            it(@"should have disconnected sense", ^{
                [[@(disconnectedFromSense) should] beYes];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
        context(@"account does not have a paired sense", ^{
            
            beforeEach(^{
                [devices stub:@selector(hasPairedSense) andReturn:[KWValue valueWithBool:NO]];
                [service stub:@selector(devices) andReturn:devices];
                
                [manager stub:@selector(resetToFactoryState:failure:) withBlock:^id(NSArray *params) {
                    calledResetToFactoryOnSense = YES;
                    void(^success)(id response) = [params firstObject];
                    success(nil);
                    return nil;
                }];
                
                [manager stub:@selector(disconnectFromSense) withBlock:^id(NSArray *params) {
                    disconnectedFromSense = YES;
                    return nil;
                }];
                
                [service stub:@selector(senseManager) andReturn:manager];
                
                [service stub:@selector(whenPairedSenseIsReadyDo:) withBlock:^id(NSArray *params) {
                    void(^block)(NSError* error) = [params lastObject];
                    block(nil);
                    return nil;
                }];
                
                [service stub:@selector(setLEDState:completion:) withBlock:^id(NSArray *params) {
                    calledSetLED = YES;
                    void(^block)(NSError* error) = [params lastObject];
                    block (nil);
                    return nil;
                }];
                
                [SENAPIDevice stub:@selector(removeAssociationsToSense:completion:) withBlock:^id(NSArray *params) {
                    calledRemoveAssociations = YES;
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                [service restoreFactorySettings:^(NSError *error) {
                    calledBack = YES;
                    serviceError = error;
                }];
                
            });
            
            afterEach(^{
                [service clearStubs];
                [SENAPIDevice clearStubs];
                calledSetLED = NO;
                calledRemoveAssociations = NO;
                calledResetToFactoryOnSense = NO;
                disconnectedFromSense = NO;
                calledBack = NO;
                manager = nil;
                serviceError = nil;
                devices = nil;
            });
            
            it(@"should return an error with sense unavailable code", ^{
                [[serviceError should] beNonNil];
                [[@([serviceError code]) should] equal:@(SENServiceDeviceErrorSenseUnavailable)];
            });
            
            it(@"should not have set LED", ^{
                [[@(calledSetLED) should] beNo];
            });
            
            it(@"should not have removed associations", ^{
                [[@(calledRemoveAssociations) should] beNo];
            });
            
            it(@"should not have factory reset sense", ^{
                [[@(calledResetToFactoryOnSense) should] beNo];
            });
            
            it(@"should not have disconnected sense", ^{
                [[@(disconnectedFromSense) should] beNo];
            });
            
            it(@"should still have called back though", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
    });
    
});

SPEC_END
