
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"
#import "SENSleepResult.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"v1/timeline/%ld-%ld-%ld"; // deprecated
static NSString* const SENAPITimelineEndpoint = @"v2/timeline";
static NSString* const SENAPITimelineErrorDomain = @"is.hello.api.timeline";
static NSString* const SENAPITimelineFeedbackPath = @"event";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    [SENAPIClient  GET:[self timelinePathForDate:date] parameters:nil completion:block];
}

+ (void)verifySleepEvent:(SENSleepResultSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIErrorBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block ([NSError errorWithDomain:SENAPITimelineErrorDomain
                                       code:-1
                                   userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:nil minutes:nil];
    [SENAPIClient PUT:path parameters:parameters completion:^(id data, NSError *error) {
        if (block) {
            block (error);
        }
    }];
}

+ (void)removeSleepEvent:(SENSleepResultSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIErrorBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block ([NSError errorWithDomain:SENAPITimelineErrorDomain
                                       code:-1
                                   userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:nil minutes:nil];
    [SENAPIClient DELETE:path parameters:parameters completion:^(id data, NSError *error) {
        if (block) {
            block (error);
        }
    }];
}

+ (void)amendSleepEvent:(SENSleepResultSegment*)sleepEvent
         forDateOfSleep:(NSDate*)date
               withHour:(NSNumber*)hour
             andMinutes:(NSNumber*)minutes
             completion:(SENAPIErrorBlock)block
{
    
    if (!sleepEvent || !hour || !minutes) {
        if (block) {
            block ([NSError errorWithDomain:SENAPITimelineErrorDomain
                                       code:-1
                                   userInfo:nil]);
        }
        return;
    }
    
    NSString* path = [self feedbackPathForDateOfSleep:date];
    id parameters = [sleepEvent dictionaryValueForUpdateWithHour:hour minutes:minutes];
    [SENAPIClient PATCH:path parameters:parameters completion:^(id data, NSError *error) {
        if (block) {
            block (error);
        }
    }];
    
}

#pragma mark - Helpers

+ (NSDateFormatter*)dateFormatter {
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        [formatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        formatter.dateFormat = @"yyyy-MM-dd";
    });
    return formatter;
}


+ (NSString*)feedbackPathForDateOfSleep:(NSDate*)dateOfSleep {
    return [NSString stringWithFormat:@"%@/%@/%@",
            SENAPITimelineEndpoint,
            [[self dateFormatter] stringFromDate:dateOfSleep],
            SENAPITimelineFeedbackPath];
}

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

+ (NSString*)timelinePathForDate:(NSDate*)date
{
    NSString* calendarId = NSCalendarIdentifierGregorian;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarId];
    NSCalendarUnit flags = (NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat,
            (long)components.year, (long)components.month, (long)components.day];
}

@end
