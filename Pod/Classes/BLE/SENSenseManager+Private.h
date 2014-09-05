//
//  SENSenseManager+Private.h
//  Pods
//
//  Created by Jimmy Lu on 9/2/14.
//
//

#import "SENSenseManager.h"
#import "SENSenseMessage.pb.h"

@class SENSenseMessage;

@interface SENSenseManager (Private)

- (NSArray*)blePackets:(SENSenseMessage*)message;
- (SENSenseMessage*)messageFromBlePackets:(NSArray*)packets error:(NSError**)error;
- (void)handleResponseUpdate:(NSData*)data
                       error:(NSError*)error
              forMessageType:(SENSenseMessageType)type
                  allPackets:(NSMutableArray**)allPackets
                totalPackets:(NSNumber**)totalPackets
                     success:(SENSenseSuccessBlock)success
                     failure:(SENSenseFailureBlock)failure;

@end
