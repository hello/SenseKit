
#import "AFHTTPSessionManager.h"
#import "SENAPITimeline.h"
#import "Model.h"

@implementation SENAPITimeline

static NSString* const SENAPITimelineEndpointFormat = @"v2/timeline/%ld-%02ld-%02ldT%02ld:%02ld";
static NSString* const SENAPITimelineEndpoint = @"v2/timeline";
static NSString* const SENAPITimelineErrorDomain = @"is.hello.api.timeline";
static NSString* const SENAPITimelineFeedbackPath = @"events";
static NSString* const SENAPITimelineFeedbackParamNewTime = @"new_event_time";
static NSString* const SENAPITimelineFeedbackParamSleepPeriod = @"sleep_period";

+ (void)timelineForDate:(NSDate *)date completion:(SENAPIDataBlock)block
{
    NSString* const SENAPITimelineUnparsedErrorFormat = @"Raw timeline could not be parsed: %@";
    if (!block)
        return;
    NSString* path = [self timelinePathForDate:date];
    [SENAPIClient  GET:path parameters:nil completion:^(id data, NSError *error) {
        if (error) {
            block(nil, error);
        } else if ([data isKindOfClass:[NSDictionary class]]) {
            SENTimeline* timeline = [[SENTimeline alloc] initWithDictionary:data];
            block(timeline, nil);
        } else {
            NSString* description = [NSString stringWithFormat:SENAPITimelineUnparsedErrorFormat, data];
            block(nil, [NSError errorWithDomain:@"is.hello"
                                           code:500
                                       userInfo:@{NSLocalizedDescriptionKey:description}]);
        }
    }];
}

+ (void)verifySleepEvent:(SENTimelineSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }

    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    [SENAPIClient PUT:path parameters:nil completion:block];
}

+ (void)removeSleepEvent:(SENTimelineSegment*)sleepEvent
          forDateOfSleep:(NSDate*)date
              completion:(SENAPIDataBlock)block
{
    if (!sleepEvent) {
        if (block) {
            block (nil, [NSError errorWithDomain:SENAPITimelineErrorDomain
                                            code:-1
                                        userInfo:nil]);
        }
        return;
    }

    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    [SENAPIClient DELETE:path parameters:nil completion:block];
}

+ (void)amendSleepEvent:(SENTimelineSegment*)sleepEvent
         forDateOfSleep:(NSDate*)date
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

    NSString* path = [self feedbackPathForDateOfSleep:date withEvent:sleepEvent];
    NSString* formattedTime = [self formattedValueWithHour:hour minutes:minutes];
    NSString* sleepPeriod = SENTimelineSegmentPeriodFromType([sleepEvent sleepPeriod]);
    NSDictionary* parameters = @{SENAPITimelineFeedbackParamNewTime : formattedTime,
                                 SENAPITimelineFeedbackParamSleepPeriod : sleepPeriod ?: @""};
    [SENAPIClient PATCH:path parameters:parameters completion:^(id data, NSError *error) {
        SENTimeline* timeline = nil;
        if (!error && [data isKindOfClass:[NSDictionary class]]) {
            timeline = [[SENTimeline alloc] initWithDictionary:data];
        }
        if (block)
            block(timeline, error);
    }];
}

#pragma mark - Helpers

+ (NSString*)formattedValueWithHour:(NSNumber*)hour minutes:(NSNumber*)minutes {
    NSString* timeChange = nil;
    if (hour && minutes) {
        static NSString* const HEMClockParamFormat = @"%02ld:%02ld";
        timeChange = [NSString stringWithFormat:HEMClockParamFormat,
                      (long)[hour longValue],
                      (long)[minutes longValue]];
    }
    return timeChange;
}

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


+ (NSString*)feedbackPathForDateOfSleep:(NSDate*)dateOfSleep withEvent:(SENTimelineSegment*)event {
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@",
            SENAPITimelineEndpoint,
            [[self dateFormatter] stringFromDate:dateOfSleep],
            SENAPITimelineFeedbackPath,
            SENTimelineSegmentTypeNameFromType([event type]),
            SENDateMillisecondsSince1970(event.date)];
}

+ (NSString*)timelinePathForDate:(NSDate*)date
{
    NSString* calendarId = NSCalendarIdentifierGregorian;
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:calendarId];
    NSCalendarUnit flags = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
    NSDateComponents* components = [calendar components:flags fromDate:date];
    
    NSCalendarUnit timeFlags = (NSCalendarUnitHour | NSCalendarUnitMinute);
    NSDateComponents* currentComponents = [calendar components:timeFlags fromDate:[NSDate date]];
    return [NSString stringWithFormat:SENAPITimelineEndpointFormat,
            (long)components.year, (long)components.month, (long)components.day,
            (long)currentComponents.hour, (long)currentComponents.minute];
}

@end
