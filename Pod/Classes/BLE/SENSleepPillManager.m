//
//  SENSleepPillManager.m
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//

@import iOSDFULibrary;

#import <CocoaLumberjack/CocoaLumberjack.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "SENSleepPillManager.h"
#import "SENSleepPill.h"

static const char SENSleepPillServiceUUID[] = {
    0x23, 0xD1, 0xBC, 0xEA,
    0x5F, 0x78, 0x23, 0x15,
    0xDE, 0xEF, 0x12, 0x12,
    0x00, 0x00, 0x00, 0x00
};

static CGFloat const SENSleepPillDefaultScanTimeout = 15.0f;

NSString* const SENSleepPillManagerErrorDomain = @"is.hello.ble.pill";

@interface SENSleepPillManager() <DFUProgressDelegate, DFUServiceDelegate>

@property (nonatomic, strong) SENSleepPill* sleepPill;
@property (nonatomic, strong) DFUServiceController* dfuController;

@end

@implementation SENSleepPillManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

+ (NSError*)errorWithCode:(SENSleepPillErrorCode)code {
    return [NSError errorWithDomain:SENSleepPillManagerErrorDomain
                               code:code
                           userInfo:nil];
}

+ (void)scanForSleepPills:(SENSleepPillManagerScanBlock)completion {
    if (![self canScan]) {
        NSError* error = [self errorWithCode:SENSleepPillErrorCodeNotSupported];
        return completion (nil, error);
    }
    
    [self whenReady:^(BOOL ready) {
        if (!ready) {
            NSError* error = [self errorWithCode:SENSleepPillErrorCodeNotSupported];
            return completion (nil, error);
        }
        
        void(^scanDone)(NSArray* peripherals) = ^(NSArray* peripherals) {
            NSMutableArray* sleepPills = nil;
            NSInteger count = [peripherals count];
            if (count > 0) {
                sleepPills = [NSMutableArray arrayWithCapacity:count];
                for (LGPeripheral* peripheral in peripherals) {
                    [sleepPills addObject:[[SENSleepPill alloc] initWithPeripheral:peripheral]];
                }
            }
            completion (sleepPills, nil);
        };
        
        size_t length = strlen(SENSleepPillServiceUUID);
        NSData* serviceBytes = [NSData dataWithBytes:SENSleepPillServiceUUID length:length];
        CBUUID* serviceId = [CBUUID UUIDWithData:serviceBytes];
        LGCentralManager* central = [LGCentralManager sharedInstance];
        [central scanForPeripheralsByInterval:SENSleepPillDefaultScanTimeout
                                     services:@[serviceId]
                                      options:nil
                                   completion:scanDone];
    }];
}

- (instancetype)initWithSleepPill:(SENSleepPill*)sleepPill {
    self = [super init];
    if (self) {
        _sleepPill = sleepPill;
    }
    return self;
}

#pragma mark - DFU

- (void)performDFUWithURL:(NSString*)url completion:(SENSleepPillManagerDFUBlock)completion {
    NSURL* pathToFirmware = [NSURL URLWithString:url];
    DFUFirmware* firmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:pathToFirmware
                                                              urlToDatFile:nil
                                                                      type:DFUFirmwareTypeApplication];
    
    CBCentralManager* central = [[LGCentralManager sharedInstance] manager];
    CBPeripheral* peripheral = [[self sleepPill] peripheral];
    DFUServiceInitiator* initiator = [[DFUServiceInitiator alloc] initWithCentralManager:central
                                                                                  target:peripheral];
    
    [initiator withFirmwareFile:firmware];
    [initiator setProgressDelegate:self];
    [initiator setDelegate:self];
    
    [self setDfuController:[initiator start]];
}

#pragma mark Progress

- (void)onUploadProgress:(NSInteger)part
              totalParts:(NSInteger)totalParts
                progress:(NSInteger)progress
currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond
  avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
  
    DDLogVerbose(@"upload progress %ld", progress);
}

- (void)didStateChangedTo:(enum State)state {
    
}

- (void)didErrorOccur:(enum DFUError)error withMessage:(NSString * _Nonnull)message {
    
}

@end
