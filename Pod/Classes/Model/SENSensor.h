
#import <Foundation/Foundation.h>
#import "SENSerializable.h"
#import "SENCondition.h"

/**
 *  Sensor value indicating invalid data
 */
extern NSInteger const SENSensorSentinelValue;

typedef NS_ENUM(NSUInteger, SENSensorUnit) {
    SENSensorUnitUnknown = 0,
    SENSensorUnitCelcius,
    SENSensorUnitFahrenheit,
    SENSensorUnitMGCM,
    SENSensorUnitPercent,
    SENSensorUnitLux,
    SENSensorUnitDecibel,
    SENSensorUnitVOC,
    SENSensorUnitPPM,
    SENSensorUnitRatio,
    SENSensorUnitKelvin,
    SENSensorUnitKPA
};

typedef NS_ENUM(NSUInteger, SENSensorType) {
    SENSensorTypeUnknown = 0,
    SENSensorTypeTemp,
    SENSensorTypeAir,
    SENSensorTypeHumidity,
    SENSensorTypeVOC,
    SENSensorTypeCO2,
    SENSensorTypeUV,
    SENSensorTypeLight,
    SENSensorTypeLightTemp,
    SENSensorTypeSound,
    SENSensorTypePressure
};

@interface SENSensorDataPoint : NSObject <SENSerializable>

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, strong, readonly) NSNumber* value;
@property (nonatomic, strong, readonly) NSNumber* dateOffset;

@end

@interface SENSensorScale : NSObject <SENSerializable>

@property (nonatomic, strong, readonly) NSNumber* min;
@property (nonatomic, strong, readonly) NSNumber* max;
@property (nonatomic, copy, readonly) NSString* localizedName;
@property (nonatomic, assign, readonly) SENCondition condition;

@end

@interface SENSensor : NSObject <SENSerializable>

@property (nonatomic, copy, readonly) NSString* localizedName;
@property (nonatomic, copy, readonly) NSString* localizedMessage;
@property (nonatomic, strong, readonly) NSNumber* value;
@property (nonatomic, assign, readonly) SENSensorUnit unit;
@property (nonatomic, assign, readonly) SENSensorType type;
@property (nonatomic, copy, readonly) NSArray<SENSensorScale*>* scales;

- (NSString*)typeStringValue;
- (NSString*)unitStringValue;

@end
