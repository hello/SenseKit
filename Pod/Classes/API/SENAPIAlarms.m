
#import "SENAPIAlarms.h"
#import "SENAlarm.h"

@implementation SENAPIAlarms

static NSString* const SENAPIAlarmsEndpoint = @"alarms";
static NSString* const SENAPIAlarmsUpdateEndpointFormat = @"alarms/%f";
static NSUInteger SENAPIAlarmsMonday = 1;
static NSUInteger SENAPIAlarmsTuesday = 2;
static NSUInteger SENAPIAlarmsWednesday = 3;
static NSUInteger SENAPIAlarmsThursday = 4;
static NSUInteger SENAPIAlarmsFriday = 5;
static NSUInteger SENAPIAlarmsSaturday = 6;
static NSUInteger SENAPIAlarmsSunday = 7;

static SENAPIDataBlock (^alarmProcessingBlock)(SENAPIDataBlock) = ^SENAPIDataBlock(SENAPIDataBlock completion) {
    return ^(NSArray* data, NSError* error) {
        if (error) {
            completion(nil, error);
            return;
        }
        NSMutableArray* alarms = [[NSMutableArray alloc] initWithCapacity:data.count];
        for (NSDictionary* alarmData in data) {
            SENAlarm* alarm = [[SENAlarm alloc] initWithDictionary:alarmData];
            if (alarm)
                [alarms addObject:alarm];
        }
        completion(alarms, nil);
    };
};

+ (void)alarmsWithCompletion:(SENAPIDataBlock)completion
{
    if (!completion)
        return;
    [SENAPIClient GET:SENAPIAlarmsEndpoint
           parameters:nil
           completion:alarmProcessingBlock(completion)];
}

+ (void)updateAlarms:(NSArray*)alarms completion:(SENAPIDataBlock)completion
{
    CGFloat clientTimeUTC = [[NSDate date] timeIntervalSince1970] * 1000;
    NSArray* alarmData = [self parameterArrayForAlarms:alarms];
    [SENAPIClient POST:[NSString stringWithFormat:SENAPIAlarmsUpdateEndpointFormat, clientTimeUTC]
            parameters:@{ @"alarms" : alarmData }
            completion:alarmProcessingBlock(completion)];
}

+ (NSArray*)parameterArrayForAlarms:(NSArray*)alarms
{
    NSMutableArray* data = [[NSMutableArray alloc] initWithCapacity:alarms.count];
    for (SENAlarm* alarm in data) {
        if ([alarm isKindOfClass:[SENAlarm class]]) {
            NSDictionary* alarmRepresentation = [self dictionaryForAlarm:alarm];
            if (alarmRepresentation) {
                [data addObject:alarmRepresentation];
            }
        }
    }
    return data;
}

+ (NSDictionary*)dictionaryForAlarm:(SENAlarm*)alarm
{
    BOOL repeated = alarm.repeatFlags != 0;
    NSMutableDictionary* alarmRepresentation = [NSMutableDictionary new];
    alarmRepresentation[@"editable"] = @([alarm isEditable]);
    alarmRepresentation[@"enabled"] = @([alarm isOn]);
    alarmRepresentation[@"sound"] = alarm.soundName;
    alarmRepresentation[@"hour"] = @(alarm.hour);
    alarmRepresentation[@"minute"] = @(alarm.minute);
    alarmRepresentation[@"repeated"] = @(repeated);
    if (repeated) {
        NSMutableSet* repeatDays = [[NSMutableSet alloc] initWithCapacity:7];
        if ((alarm.repeatFlags & SENAlarmRepeatMonday) == SENAlarmRepeatMonday)
            [repeatDays addObject:@(SENAPIAlarmsMonday)];
        if ((alarm.repeatFlags & SENAlarmRepeatTuesday) == SENAlarmRepeatTuesday)
            [repeatDays addObject:@(SENAPIAlarmsTuesday)];
        if ((alarm.repeatFlags & SENAlarmRepeatWednesday) == SENAlarmRepeatWednesday)
            [repeatDays addObject:@(SENAPIAlarmsWednesday)];
        if ((alarm.repeatFlags & SENAlarmRepeatThursday) == SENAlarmRepeatThursday)
            [repeatDays addObject:@(SENAPIAlarmsThursday)];
        if ((alarm.repeatFlags & SENAlarmRepeatFriday) == SENAlarmRepeatFriday)
            [repeatDays addObject:@(SENAPIAlarmsFriday)];
        if ((alarm.repeatFlags & SENAlarmRepeatSaturday) == SENAlarmRepeatSaturday)
            [repeatDays addObject:@(SENAPIAlarmsSaturday)];
        if ((alarm.repeatFlags & SENAlarmRepeatSunday) == SENAlarmRepeatSunday)
            [repeatDays addObject:@(SENAPIAlarmsSunday)];
        alarmRepresentation[@"day_of_week"] = repeatDays;
    }
    return alarmRepresentation;
}

@end
