//
//  SENAPIAppStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <UIKit/UIKit.h>
#import "SENAPIClient.h"

@class SENAppStats;

@interface SENAPIAppStats : NSObject

+ (void)stats:(nonnull SENAPIDataBlock)completion;
+ (void)updateStats:(nonnull SENAppStats*)stats completion:(nonnull SENAPIDataBlock)completion;
+ (void)unread:(nonnull SENAPIDataBlock)completion;

@end
