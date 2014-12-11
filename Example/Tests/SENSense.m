//
//  SENSense.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/10/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <Kiwi/Kiwi.h>
#import "SENSense.h"

@interface SENSense()

- (void)processAdvertisementData:(NSDictionary*)data;

@end

SPEC_BEGIN(SENSenseSpec)

describe(@"SENSense", ^{
    
    describe(@"-processAdvertisementData: (private)", ^{
        
        it(@"should properly extract name and mode when mode exists", ^{
            NSString* rawId = @"EEF54712354EEF99";
            NSString* deviceIdWithMode = [rawId stringByAppendingString:@"1"];
            NSDictionary* advertisementData = @{
                CBAdvertisementDataServiceDataKey : @{@"data" : [deviceIdWithMode dataUsingEncoding:NSUTF8StringEncoding]}
            };
            SENSense* sense = [[SENSense alloc] init];
            [sense processAdvertisementData:advertisementData];
            
            [[[sense deviceId] should] beNonNil];
            [[@([sense mode]) should] equal:@(SENSenseModePairing)];
            
            deviceIdWithMode = [rawId stringByAppendingString:@"0"];
            advertisementData = @{
                CBAdvertisementDataServiceDataKey : @{@"data" : [deviceIdWithMode dataUsingEncoding:NSUTF8StringEncoding]}
            };
            
            [sense processAdvertisementData:advertisementData];
            
            [[[sense deviceId] should] beNonNil];
            [[@([sense mode]) should] equal:@(SENSenseModeNormal)];
        });
        
        it(@"mode should be unknown when not set", ^{
            NSString* rawId = @"EEF54712354EEF99";
            NSDictionary* advertisementData = @{
                CBAdvertisementDataServiceDataKey : @{@"data" : [rawId dataUsingEncoding:NSUTF8StringEncoding]}
            };
            SENSense* sense = [[SENSense alloc] init];
            [sense processAdvertisementData:advertisementData];
            
            [[[sense deviceId] should] beNonNil];
            [[@([sense mode]) should] equal:@(SENSenseModeUnknown)];
        });

        
    });
    
});

SPEC_END
