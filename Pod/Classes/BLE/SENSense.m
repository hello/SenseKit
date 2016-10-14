//
//  SENSense.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>
#import "LGPeripheral.h"
#import "SENSense.h"

@interface SENSense()

@property (nonatomic, copy, readwrite) NSString* deviceId;
@property (nonatomic, copy, readwrite) NSString* macAddress;
@property (nonatomic, assign, readwrite) SENSenseMode mode;
@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        [self processAdvertisementData:[peripheral advertisingData]];
    }
    return self;
}

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral andDeviceId:(NSString*)deviceId {
    self = [super init];
    if (self) {
        _peripheral = peripheral;
        _deviceId = [deviceId copy];
    }
    return self;
}

- (void)processAdvertisementData:(NSDictionary*)data {
    SENSenseMode mode = SENSenseModeUnknown;
    NSDictionary* serviceData = data[CBAdvertisementDataServiceDataKey];
    NSMutableString* deviceIdInHex = nil;
    NSMutableString* macAddress = nil;
    
    if ([serviceData count] == 1) {
        NSData* deviceIdData = [serviceData allValues][0];
        const unsigned char* dataBuffer = (const unsigned char*)[deviceIdData bytes];
        if (dataBuffer) {
            NSInteger len = [deviceIdData length];
            NSInteger deviceIdLength = len;
            
            // per Pang, if device id data is odd in length, the last byte indicates
            // the mode Sense is in.  If even, then that byte is not being set by the
            // firmware.  If we don't handle it and the firmware code is pushed, then
            // people will never be able to configure Sense b/c device id on server
            // and one processed here will never match!
            if (len % 2 != 0) {
                deviceIdLength = len - 1;
                mode = dataBuffer[deviceIdLength] == '1'?SENSenseModePairing:SENSenseModeNormal;
            }
            
            deviceIdInHex = [[NSMutableString alloc] initWithCapacity:deviceIdLength];
            for (int i = 0; i < deviceIdLength; i++) {
                [deviceIdInHex appendString:[NSString stringWithFormat:@"%02lX", (unsigned long)dataBuffer[i]]];
            }
            
            // determine mac address from device id (based on code from fw)
            int macSize = 6;
            char* mac[6] = {0x5c,0x6b,0x4f,0,0,0};
            mac[3] = dataBuffer[len - 3];
            mac[4] = dataBuffer[len - 2];
            mac[5] = dataBuffer[len - 1];
            
            macAddress = [NSMutableString new];
            for (int i = 0; i < macSize; i++) {
                [macAddress appendString:[NSString stringWithFormat:@"%@%02lX",
                                          [macAddress length] > 0 ? @":" : @"",
                                          (unsigned long)mac[i]]];
            }
        }
    }
    
    [self setDeviceId:deviceIdInHex];
    [self setMacAddress:macAddress];
    [self setMode:mode];
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@, mac: %@, in mode: %ld, id: %@",
            [self name], [self macAddress], (long)[self mode], [self deviceId]];
}

- (BOOL)isEqual:(id)object {
    if (!object || ![object isKindOfClass:[self class]]) return NO;
    
    SENSense* other = object;
    return [other deviceId] != nil && [[self deviceId] isEqualToString:[other deviceId]];
}

- (NSUInteger)hash {
    return [[self deviceId] hash];
}

@end
