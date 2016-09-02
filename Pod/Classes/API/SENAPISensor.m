//
//  SENAPISensor.m
//  Pods
//
//  Created by Jimmy Lu on 9/1/16.
//
//

#import "SENAPISensor.h"
#import "AFHTTPSessionManager.h"
#import "SENPreference.h"
#import "SENSensor.h"

static NSString* const kSENAPISensorUnitCelcius = @"c";
static NSString* const kSENAPISensorUnitFahrenheit = @"f";
static NSString* const kSENAPISensorSensorScopeDay = @"day";
static NSString* const kSENAPISensorSensorScopeWeek = @"week";
static NSString* const kSENAPISensorAllSensorsScopeDay = @"24hours";
static NSString* const kSENAPISensorAllSensorsScopeWeek = @"week";
static NSString* const kSENAPISensorSensorPathFormat = @"v1/room/%@/%@";
static NSString* const kSENAPISensorAllSensorsPath = @"all_sensors";
static NSString* const kSENAPISensorCurrentPath = @"v1/room/current";
static NSString* const kSENAPISensorSensorParamTimestamp = @"from";
static NSString* const kSENAPISensorAllSensorsParamTimestamp = @"from_utc";
static NSString* const kSENAPISensorParamUnit = @"temp_unit";
static NSString* const kSENAPISensorRespName = @"name";

NSString* const kSENAPISensorErrorDomain = @"is.hello.sensekit.sensor";

@implementation SENAPISensor

#pragma mark - Helpers

+ (NSString*)tempParamForTempUnit:(SENAPISensorTempUnit)unit {
    return unit == SENAPISensorTempUnitCelcius
        ? kSENAPISensorUnitCelcius
        : kSENAPISensorUnitFahrenheit;
}

+ (NSError*)errorWithCode:(SENAPISensorErrorCode)code reason:(NSString*)reason {
    NSDictionary* info = nil;
    if (reason) {
        info = @{NSLocalizedDescriptionKey : reason};
    }
    return [NSError errorWithDomain:kSENAPISensorErrorDomain code:code userInfo:info];
}

#pragma mark - APIs

+ (void)currentConditionsWithTempUnit:(SENAPISensorTempUnit)unit completion:(SENAPIDataBlock)completion {
    NSDictionary* params = @{kSENAPISensorParamUnit : [self tempParamForTempUnit:unit]};
    [SENAPIClient GET:kSENAPISensorCurrentPath parameters:params completion:^(id data, NSError *error) {
        
        __block NSError* apiError = error;
        
        if (!apiError && ![data isKindOfClass:[NSDictionary class]]) {
            NSString* actualClass = NSStringFromClass([data class]);
            NSString* reason = [NSString stringWithFormat:@"api returned invalid response type %@", actualClass];
            apiError = [self errorWithCode:SENAPISensorErrorCodeInvalidResponse reason:reason];
        }
        
        if (!apiError) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSMutableArray<SENSensor*>* sensors = [NSMutableArray arrayWithCapacity:[data count]];
                [data enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        NSMutableDictionary* values = [obj mutableCopy];
                        values[kSENAPISensorRespName] = key;
                        SENSensor* sensor = [[SENSensor alloc] initWithDictionary:values];
                        if (sensor) {
                            [sensors addObject:sensor];
                        }
                    } else {
                        NSString* actualClass = NSStringFromClass([obj class]);
                        NSString* reason = [NSString stringWithFormat:@"invalid sensor response type %@", actualClass];
                        apiError = [self errorWithCode:SENAPISensorErrorCodeInvalidResponse reason:reason];
                        stop = YES;
                    }
                }];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion (sensors, error);
                });
            });
        } else {
            completion (nil, error);
        }
        
    }];
}

#pragma mark - Data points

+ (NSArray*)dataPointsFromArray:(NSArray*)data {
    NSMutableArray* points = [[NSMutableArray alloc] initWithCapacity:data.count];
    for (NSDictionary* pointData in data) {
        SENSensorDataPoint* point =
            [[SENSensorDataPoint alloc] initWithDictionary:pointData];
        if (point) {
            [points addObject:point];
        }
    }
    return points;
}

+ (void)dataForAllSensorsWithScope:(SENAPISensorDataScope)scope
                        completion:(SENAPIDataBlock)completion {
    [self dataForSensor:nil withScope:scope completion:completion];
}

+ (void)dataForSensor:(SENSensor*)sensor
            withScope:(SENAPISensorDataScope)scope
           completion:(SENAPIDataBlock)completion {
    
    NSString* scopeValue = kSENAPISensorSensorScopeDay;
    if (scope == SENAPISensorDataScopeWeek) {
        scopeValue = kSENAPISensorSensorScopeWeek;
    }
    NSTimeInterval seconds = [[NSDate date] timeIntervalSince1970];
    NSString* timestamp = [NSString stringWithFormat:@"%.0f", seconds * 1000];
    NSDictionary* params = @{kSENAPISensorSensorParamTimestamp : timestamp};
    NSString* sensorPath = [sensor name] ?: kSENAPISensorAllSensorsPath;
    NSString* path = [NSString stringWithFormat:kSENAPISensorSensorPathFormat,
                      sensorPath, scopeValue];
    
    [SENAPIClient GET:path parameters:params completion:^(id data, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            __block NSMutableDictionary* dataBySensorName
                = [NSMutableDictionary dictionaryWithCapacity:[data count]];
            
            if (!error && data) {
                if ([data isKindOfClass:[NSArray class]]) {
                    dataBySensorName[sensorPath] = [self dataPointsFromArray:data];
                } else if ([data isKindOfClass:[NSDictionary class]]) {
                    [data enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSArray* data, BOOL *stop) {
                        NSArray* points = [self dataPointsFromArray:data];
                        if (points) {
                            dataBySensorName[key] = points;
                        }
                    }];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(dataBySensorName, error);
            });
        });
    }];
}

@end
