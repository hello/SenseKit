//
//  SENSense.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/10/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSense.h>

@interface SENSense()

- (void)processAdvertisementData:(NSDictionary*)data;
- (void)setDeviceId:(NSString*)deviceId;

@end

SPEC_BEGIN(SENSenseSpec)

describe(@"SENSense", ^{
    
    describe(@"-macAddress", ^{
        
        it(@"should return a mac address that matches device id", ^{
            SENSense* sense = [SENSense new];
            [sense setDeviceId:@"16E1D47CDC599568"];
            [[[[sense macAddress] uppercaseString] should] equal:@"5C:6B:4F:59:95:68"];
        });

    });
    
    describe(@"-processAdvertisementData: (private)", ^{
        
        it(@"should properly extract id mode when mode exists", ^{
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
        
        it(@"should be unknown mode when not set", ^{
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
