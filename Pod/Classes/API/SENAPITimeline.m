
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"
#import "SENSleepResult.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"v%ld/timeline/%ld-%ld-%ld";
static NSString* const SENAPITimelineErrorDomain = @"is.hello.api.timeline";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    [SENAPIClient  GET:[self timelinePathForDate:date apiVersion:1] parameters:nil completion:block];
}

+ (void)verifySleepEvent:(SENSleepResultSegment*)sleepEvent completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            NSError* error = [NSError errorWithDomain:SENAPITimelineErrorDomain
                                                 code:-1
                                             userInfo:nil];
            block (nil, error);
        }
        return;
    }
    
    NSString* path = [self timelinePathForDate:[sleepEvent date] apiVersion:2];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:nil minutes:nil];
    [SENAPIClient PUT:path parameters:parameters completion:block];
}

+ (void)removeSleepEvent:(SENSleepResultSegment*)sleepEvent completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            NSError* error = [NSError errorWithDomain:SENAPITimelineErrorDomain
                                                 code:-1
                                             userInfo:nil];
            block (nil, error);
        }
        return;
    }
    
    NSString* path = [self timelinePathForDate:[sleepEvent date] apiVersion:2];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:nil minutes:nil];
    [SENAPIClient DELETE:path parameters:parameters completion:block];
}

+ (void)amendSleepEvent:(SENSleepResultSegment*)sleepEvent
               withHour:(NSNumber*)hour
             andMinutes:(NSNumber*)minutes
             completion:(SENAPIDataBlock)block
{
    
    if (!sleepEvent || !hour || !minutes) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self timelinePathForDate:[sleepEvent date] apiVersion:2];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:hour minutes:minutes];
    [SENAPIClient PATCH:path parameters:parameters completion:block];
    
}

#pragma mark - Helpers

+ (NSString*)parameterStringForHour:(NSUInteger)hour minute:(NSUInteger)minute
{
    static NSString* const HEMClockParamFormat = @"%@:%@";
    NSString* hourText = [self stringForNumber:hour];
    NSString* minuteText = [self stringForNumber:minute];
    return [NSString stringWithFormat:HEMClockParamFormat, hourText, minuteText];
}

+ (NSString*)stringForNumber:(NSUInteger)number
{
    static NSString* const HEMNumberParamFormat = @"%ld";
    static NSString* const HEMSmallNumberParamFormat = @"0%ld";
    NSString* format = number <= 9 ? HEMSmallNumberParamFormat : HEMNumberParamFormat;
    return [NSString stringWithFormat:format, (long)number];
}

+ (NSString*)timelinePathForDate:(NSDate*)date apiVersion:(NSInteger)version
{
    NSString* calendarId = NSCalendarIdentifierGregorian;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarId];
    NSCalendarUnit flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat,
            (long)version, (long)components.year, (long)components.month, (long)components.day];
}

@end
