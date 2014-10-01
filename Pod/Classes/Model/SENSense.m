//
//  SENSense.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//
#import <CoreBluetooth/CoreBluetooth.h>

#import "LGPeripheral.h"

#import "SENSense+Protected.h"

@interface SENSense()

@property (nonatomic, copy, readwrite) NSString* deviceId;
@property (nonatomic, strong) LGPeripheral* peripheral;

@end

@implementation SENSense

- (instancetype)initWithPeripheral:(LGPeripheral*)peripheral {
    self = [super init];
    if (self) {
        [self setPeripheral:peripheral];
        [self processDeviceId];
    }
    return self;
}

- (void)processDeviceId {
    NSDictionary* data = [[self peripheral] advertisingData];
    NSString* serviceData = data[CBAdvertisementDataServiceDataKey];
    NSMutableString* deviceIdInHex = [[NSMutableString alloc] init];
    if (serviceData) {
        const char* utf8 = [serviceData UTF8String];
        while ( *utf8 ) {
            [deviceIdInHex appendFormat:@"%02X" , *utf8++ & 0x00FF];
        }
    }
    [self setDeviceId:deviceIdInHex];
}

- (NSString*)name {
    return [[self peripheral] name];
}

- (NSString*)uuid {
    return [[self peripheral] UUIDString];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"Sense: %@, uuid: %@", [self name], [self uuid]];
}

@end
