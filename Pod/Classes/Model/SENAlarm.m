
#import "SENAlarm.h"
#import "SENAPIAlarms.h"
#import "SENKeyedArchiver.h"
#import "SENPreference.h"

@implementation SENAlarm

static NSString* const SENAlarmSoundKey = @"sound";
static NSString* const SENAlarmSoundNameKey = @"name";
static NSString* const SENAlarmSoundIDKey = @"id";
static NSString* const SENAlarmSoundIDEncodingKey = @"sound_id";
static NSString* const SENAlarmOnKey = @"enabled";
static NSString* const SENAlarmSmartKey = @"smart";
static NSString* const SENAlarmEditableKey = @"editable";
static NSString* const SENAlarmHourKey = @"hour";
static NSString* const SENAlarmMinuteKey = @"minute";
static NSString* const SENAlarmRepeatKey = @"day_of_week";
static NSString* const SENAlarmIdentifierKey = @"id";

static NSString* const SENAlarmDefaultSoundName = @"None";
static NSUInteger const SENAlarmDefaultHour = 7;
static NSUInteger const SENAlarmDefaultMinute = 30;
static BOOL const SENAlarmDefaultOnState = YES;
static BOOL const SENAlarmDefaultEditableState = YES;
static BOOL const SENAlarmDefaultSmartAlarmState = YES;

+ (SENAlarm*)createDefaultAlarm {
    return [[SENAlarm alloc] initWithDictionary:@{
        SENAlarmSoundNameKey : SENAlarmDefaultSoundName,
        SENAlarmHourKey : @(SENAlarmDefaultHour),
        SENAlarmMinuteKey : @(SENAlarmDefaultMinute),
        SENAlarmOnKey : @(SENAlarmDefaultOnState),
        SENAlarmEditableKey : @(SENAlarmDefaultEditableState),
        SENAlarmSmartKey : @(SENAlarmDefaultSmartAlarmState),
        SENAlarmRepeatKey : @[]
    }];
}

+ (NSString*)localizedValueForTime:(struct SENAlarmTime)time {
    long adjustedHour = time.hour;
    NSString* formatString;
    NSString* minuteText = time.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)time.minute] : [NSString stringWithFormat:@"%ld", (long)time.minute];
    if ([SENPreference timeFormat] == SENTimeFormat12Hour) {
        formatString = time.hour > 11 ? @"%ld:%@pm" : @"%ld:%@am";
        if (time.hour > 12) {
            adjustedHour = (long)(time.hour - 12);
        } else if (time.hour == 0) {
            adjustedHour = 12;
        }
    } else {
        formatString = @"%ld:%@";
    }
    return [NSString stringWithFormat:formatString, adjustedHour, minuteText];
}

- (instancetype)init {
    self = [self initWithDictionary:nil];
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    if (self = [super init]) {
        _editable = [dict[SENAlarmEditableKey] boolValue];
        _hour = [dict[SENAlarmHourKey] unsignedIntegerValue];
        NSString* identifier = dict[SENAlarmIdentifierKey];
        _identifier = identifier.length > 0 ? identifier : [[[NSUUID alloc] init] UUIDString];
        _minute = [dict[SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [dict[SENAlarmOnKey] boolValue];
        _repeatFlags = [self repeatFlagsFromDays:dict[SENAlarmRepeatKey]];
        _smartAlarm = [dict[SENAlarmSmartKey] boolValue];
        _soundName = dict[SENAlarmSoundKey][SENAlarmSoundNameKey];
        _soundID = dict[SENAlarmSoundKey][SENAlarmSoundIDKey];
    }
    return self;
}

- (NSString*)localizedValue {
    struct SENAlarmTime time;
    time.hour = self.hour;
    time.minute = self.minute;
    return [SENAlarm localizedValueForTime:time];
}

- (NSUInteger)repeatFlagsFromDays:(NSArray*)days {
    NSUInteger repeatFlags = 0;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayMonday)])
        repeatFlags |= SENAlarmRepeatMonday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayTuesday)])
        repeatFlags |= SENAlarmRepeatTuesday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayWednesday)])
        repeatFlags |= SENAlarmRepeatWednesday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayThursday)])
        repeatFlags |= SENAlarmRepeatThursday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDayFriday)])
        repeatFlags |= SENAlarmRepeatFriday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDaySaturday)])
        repeatFlags |= SENAlarmRepeatSaturday;
    if ([days containsObject:@(SENAPIAlarmsRepeatDaySunday)])
        repeatFlags |= SENAlarmRepeatSunday;

    return repeatFlags;
}

- (BOOL)isRepeated {
    return self.repeatFlags != 0;
}

- (BOOL)isRepeatedOn:(SENAlarmRepeatDays)days {
    return (self.repeatFlags & days) != 0;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder {
    if (self = [super init]) {
        NSString* identifier = [aDecoder decodeObjectForKey:SENAlarmIdentifierKey];
        _editable = [[aDecoder decodeObjectForKey:SENAlarmEditableKey] boolValue];
        _hour = [[aDecoder decodeObjectForKey:SENAlarmHourKey] unsignedIntegerValue];
        _identifier = identifier.length > 0 ? identifier : [[[NSUUID alloc] init] UUIDString];
        _minute = [[aDecoder decodeObjectForKey:SENAlarmMinuteKey] unsignedIntegerValue];
        _on = [[aDecoder decodeObjectForKey:SENAlarmOnKey] boolValue];
        _repeatFlags = [[aDecoder decodeObjectForKey:SENAlarmRepeatKey] unsignedIntegerValue];
        _smartAlarm = [[aDecoder decodeObjectForKey:SENAlarmSmartKey] boolValue];
        _soundName = [aDecoder decodeObjectForKey:SENAlarmSoundNameKey];
        _soundID = [aDecoder decodeObjectForKey:SENAlarmSoundIDEncodingKey];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder {
    [aCoder encodeObject:@([self isOn]) forKey:SENAlarmOnKey];
    [aCoder encodeObject:@([self hour]) forKey:SENAlarmHourKey];
    [aCoder encodeObject:@([self minute]) forKey:SENAlarmMinuteKey];
    [aCoder encodeObject:[self soundName] forKey:SENAlarmSoundNameKey];
    [aCoder encodeObject:[self soundID] forKey:SENAlarmSoundIDEncodingKey];
    [aCoder encodeObject:[self identifier] forKey:SENAlarmIdentifierKey];
    [aCoder encodeObject:@([self isEditable]) forKey:SENAlarmEditableKey];
    [aCoder encodeObject:@([self repeatFlags]) forKey:SENAlarmRepeatKey];
    [aCoder encodeObject:@([self isSmartAlarm]) forKey:SENAlarmSmartKey];
}

- (NSUInteger)hash {
    return [self.identifier hash];
}

- (BOOL)isEqual:(SENAlarm*)alarm {
    if (![alarm isKindOfClass:[SENAlarm class]])
        return NO;

    return [self.identifier isEqualToString:alarm.identifier] && [self isIdenticalToAlarm:alarm];
}

- (BOOL)isIdenticalToAlarm:(SENAlarm *)alarm {
    return self.hour == alarm.hour
        && self.minute == alarm.minute
        && self.repeatFlags == alarm.repeatFlags
        && ((self.soundID && [self.soundID isEqual:alarm.soundID]) || (!self.soundID && !alarm.soundID))
        && ((self.soundName && [self.soundName isEqual:alarm.soundName]) || (!self.soundName && !alarm.soundName))
        && [self isSmartAlarm] == [alarm isSmartAlarm]
        && [self isEditable] == [alarm isEditable]
        && [self isOn] == [alarm isOn];
}

- (NSDate*)nextRingDate {
    NSDate* date = [NSDate date];
    NSCalendarUnit flags = (NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitDay);
    NSDateComponents* currentDateComponents = [[NSCalendar autoupdatingCurrentCalendar] components:flags fromDate:date];
    NSInteger minuteOfDay = (currentDateComponents.hour * 60) + currentDateComponents.minute;
    NSInteger alarmMinuteOfDay = (self.hour * 60) + self.minute;
    NSDateComponents* diff = [NSDateComponents new];
    diff.minute = alarmMinuteOfDay - minuteOfDay;
    if (alarmMinuteOfDay < minuteOfDay)
        diff.day = 1;

    return [[NSCalendar autoupdatingCurrentCalendar] dateByAddingComponents:diff toDate:date options:0];
}

@end
