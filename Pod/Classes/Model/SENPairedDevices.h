//
//  SENDevices.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@class SENSenseMetadata;
@class SENPillMetadata;

NS_ASSUME_NONNULL_BEGIN

@interface SENPairedDevices : NSObject <SENSerializable>

@property (nonatomic, strong, readonly, nullable) NSArray<SENSenseMetadata*> *senses;
@property (nonatomic, strong, readonly, nullable) NSArray<SENPillMetadata*> *pills;

- (nullable SENSenseMetadata*)activeSenseMetadata;
- (nullable SENPillMetadata*)activePillMetadata;

- (BOOL)hasPairedSense;
- (BOOL)hasPairedPill;

- (void)removePill:(SENPillMetadata*)pillMetadata;
- (void)removeSense:(SENSenseMetadata*)senseMetadata;

@end

NS_ASSUME_NONNULL_END