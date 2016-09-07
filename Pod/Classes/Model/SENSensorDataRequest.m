//
//  SENSensorDataRequest.m
//  Pods
//
//  Created by Jimmy Lu on 9/7/16.
//
//

#import "SENSensorDataRequest.h"

static NSString* const kSENSensorDataRequestAttrSensors = @"sensors";
static NSString* const kSENSensorDataRequestAttrType = @"type";
static NSString* const kSENSensorDataRequestAttrScope = @"scope";
static NSString* const kSENSensorDataRequestValueDay5Min = @"DAY_5_MIN";
static NSString* const kSENSensorDataRequestAttrUnit = @"unit";
static NSString* const kSENSensorDataRequestAttrAggMethod = @"aggregate_method";
static NSString* const kSENSensorDataRequestValueMin = @"MIN";
static NSString* const kSENSensorDataRequestValueMax = @"MAX";
static NSString* const kSENSensorDataRequestValueAvg = @"AVG";

@interface SENSensorDataRequest()

@property (nonatomic, strong) NSMutableOrderedSet* sensors;

@end

@implementation SENSensorDataRequest

- (instancetype)init {
    if (self = [super init]) {
        _sensors = [NSMutableOrderedSet new];
    }
    return self;
}

- (void)addRequestForSensor:(SENSensor*)sensor
                usingMethod:(SENSensorDataMethod)method
                  withScope:(SENSensorDataScope)scope {
    if (sensor) {
        [[self sensors] addObject:@{kSENSensorDataRequestAttrType : [sensor typeStringValue],
                                    kSENSensorDataRequestAttrUnit : [sensor unitStringValue],
                                    kSENSensorDataRequestAttrAggMethod : [self aggregateMethodForEnum:method],
                                    kSENSensorDataRequestAttrScope : [self scopeValueForEnum:scope]}];
    }
}

- (NSDictionary*)dictionaryValue {
    return @{kSENSensorDataRequestAttrSensors : [[self sensors] array]};
}

- (NSString*)aggregateMethodForEnum:(SENSensorDataMethod)method {
    switch (method) {
        case SENSensorDataMethodMin:
            return kSENSensorDataRequestValueMin;
        case SENSensorDataMethodMax:
            return kSENSensorDataRequestValueMax;
        default:
            return kSENSensorDataRequestValueAvg;
    }
}

- (NSString*)scopeValueForEnum:(SENSensorDataScope)scope {
    switch (scope) {
        case SENSensorDataScopeDay5Min:
        default:
            return kSENSensorDataRequestValueDay5Min;
    }
}

@end
