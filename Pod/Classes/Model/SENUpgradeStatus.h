//
//  SENUpgradeStatus.h
//  Pods
//
//  Created by Jimmy Lu on 8/25/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

typedef NS_ENUM(NSUInteger, SENUpgradeResponse) {
    SENUpgradeResponseOk = 0,
    SENUpgradeResponseTooManyDevices, // should never happen to normal users
    SENUpgradeResponsePairedToAnother // if new Sense is currently paired to a different account
};

@interface SENUpgradeStatus : NSObject <SENSerializable>

@property (nonatomic, assign, readonly) SENUpgradeResponse response;

@end
