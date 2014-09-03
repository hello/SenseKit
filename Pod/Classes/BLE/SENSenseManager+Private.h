//
//  SENSenseManager+Private.h
//  Pods
//
//  Created by Jimmy Lu on 9/2/14.
//
//

#import "SENSenseManager.h"

@class SENSenseMessage;

@interface SENSenseManager (Private)

- (NSArray*)blePackets:(SENSenseMessage*)message;

@end
