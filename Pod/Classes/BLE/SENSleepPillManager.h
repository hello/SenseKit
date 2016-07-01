//
//  SENSleepPillManager.h
//  Pods
//
//  Created by Jimmy Lu on 6/29/16.
//
//

#import <Foundation/Foundation.h>
#import "SENPeripheralManager.h"

@class SENSleepPill;

typedef NS_ENUM(NSInteger, SENSleepPillErrorCode) {
    SENSleepPillErrorCodeNotSupported = -1,
    SENSleepPillErrorCodeCentralNotReady = -2
};

extern NSString* const HEMSleepPillManagerErrorDomain;

typedef void(^SENSleepPillManagerScanBlock)(NSArray<SENSleepPill*>* pills, NSError* error);
typedef void(^SENSleepPillManagerDFUBlock)(NSError* error);

@interface SENSleepPillManager : SENPeripheralManager

+ (void)scanForSleepPills:(SENSleepPillManagerScanBlock)completion;
- (instancetype)initWithSleepPill:(SENSleepPill*)sleepPill;
- (void)performDFUWithURL:(NSString*)url completion:(SENSleepPillManagerDFUBlock)completion;

@end
