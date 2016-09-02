//
//  SENAPISensor.h
//  Pods
//
//  Created by Jimmy Lu on 9/1/16.
//
//

#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

@class SENSensor;

NS_ASSUME_NONNULL_BEGIN

extern NSString* const SENAPISensorErrorDomain;

typedef NS_ENUM(NSInteger, SENAPISensorErrorCode) {
    SENAPISensorErrorCodeInvalidResponse = -1
};

typedef NS_ENUM(NSUInteger, SENAPISensorTempUnit) {
    SENAPISensorTempUnitCelcius = 0, // default
    SENAPISensorTempUnitFahrenheit
};

typedef NS_ENUM(NSUInteger, SENAPISensorDataScope) {
    SENAPISensorDataScopeDay = 0,
    SENAPISensorDataScopeWeek
};

@interface SENAPISensor : NSObject

+ (void)dataForAllSensorsWithScope:(SENAPISensorDataScope)scope
                        completion:(SENAPIDataBlock)completion;

+ (void)dataForSensor:(SENSensor*)sensor
            withScope:(SENAPISensorDataScope)scope
           completion:(SENAPIDataBlock)completion;

+ (void)currentConditionsWithTempUnit:(SENAPISensorTempUnit)unit
                           completion:(SENAPIDataBlock)completion;

@end

NS_ASSUME_NONNULL_END