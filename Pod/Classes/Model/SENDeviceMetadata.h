//
//  SENDeviceMetadata.h
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

NS_ASSUME_NONNULL_BEGIN

@interface SENDeviceMetadata : NSObject <SENSerializable>

@property (nonatomic, copy, readonly, nullable) NSString* uniqueId;
@property (nonatomic, copy, readonly, nullable) NSString* firmwareVersion;
@property (nonatomic, strong, readonly, nullable) NSDate* lastSeenDate;
@property (nonatomic, assign, readonly, getter=isActive) BOOL active;

- (NSDictionary*)dictionaryValue;

@end

NS_ASSUME_NONNULL_END