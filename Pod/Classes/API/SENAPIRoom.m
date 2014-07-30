
#import "AFHTTPSessionManager.h"

#import "SENAPIRoom.h"
#import "SENAPIClient.h"

@implementation SENAPIRoom

+ (void)currentWithCompletion:(SENAPIDataBlock)completion
{
    [[SENAPIClient HTTPSessionManager] GET:@"/room/current" parameters:nil success:^(NSURLSessionDataTask* task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completion(nil, error);
    }];
}

+ (void)hourlyHistoricalDataForSensorWithName:(NSString*)sensorName
                                   completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensorWithName:sensorName timeScope:@"day" completion:completion];
}

+ (void)dailyHistoricalDataForSensorWithName:(NSString*)sensorName completion:(SENAPIDataBlock)completion
{
    [self historicalDataForSensorWithName:sensorName timeScope:@"week" completion:completion];
}

+ (void)historicalDataForSensorWithName:(NSString*)sensorName
                              timeScope:(NSString*)scope
                             completion:(SENAPIDataBlock)completion
{
    NSString* timestamp = [[self UTCMillisecondTimestampDateFormatter] stringFromDate:[NSDate date]];
    NSString* path = [NSString stringWithFormat:@"/room/%@/%@", sensorName, scope];
    [[SENAPIClient HTTPSessionManager] GET:path parameters:@{ @"from" : timestamp } success:^(NSURLSessionDataTask* task, id responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completion(nil, error);
    }];
}

+ (NSDateFormatter*)UTCMillisecondTimestampDateFormatter
{
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *tz = [NSTimeZone timeZoneForSecondsFromGMT:0];
        [dateFormatter setDateFormat:@"A"];
        [dateFormatter setTimeZone:tz];
    });
    return dateFormatter;
}

@end
