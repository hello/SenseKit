//
//  SENPeripheralManager.m
//  Pods
//
//  Created by Jimmy Lu on 6/30/16.
//
//
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "SENPeripheralManager.h"

static NSUInteger const SENPeripheralManagerBLECheckRetries = 10;
static CGFloat const SENPeripheralManagerBLECheckRetryDelay = 0.2f;

@interface SENPeripheralManager()

@end

@implementation SENPeripheralManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#pragma mark - Central availability

+ (void)whenReady:(SENPeripheralReadyCallback)completion {
    [self whenReadyWithAttempt:1 completion:completion];
}

+ (void)whenReadyWithAttempt:(NSInteger)attempt completion:(SENPeripheralReadyCallback)completion {
    BOOL ready = [self isReady];
    if (attempt > SENPeripheralManagerBLECheckRetries || ready) {
        return completion (ready);
    } else {
        [self whenReadyWithAttempt:++attempt completion:completion];
    }
}

+ (BOOL)isReady {
    return [[LGCentralManager sharedInstance] isCentralReady];
}

#pragma mark - BLE Scan

+ (BOOL)canScan {
    CBCentralManagerState state = [[[LGCentralManager sharedInstance] manager] state];
    return state != CBCentralManagerStateUnauthorized
        && state != CBCentralManagerStateUnsupported;
}

+ (BOOL)isScanning {
    return [[LGCentralManager sharedInstance] isScanning];
}

+ (void)stopScan {
    if ([[LGCentralManager sharedInstance] isScanning]) {
        [[LGCentralManager sharedInstance] stopScanForPeripherals];
        DDLogVerbose(@"scan stopped");
    }
}

@end
