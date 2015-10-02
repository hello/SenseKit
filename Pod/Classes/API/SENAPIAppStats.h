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

+ (void)stats:(SENAPIDataBlock _Nonnull)completion;
+ (void)updateStats:(SENAppStats* _Nonnull)stats completion:(SENAPIDataBlock _Nullable)completion;
+ (void)unread:(SENAPIDataBlock _Nonnull)completion;

@end
