
#import "SENAlarm.h"
#import "SENKeyedArchiver.h"

static NSString* const soundNameKey = @"sound";
static NSString* const onKey = @"on";
static NSString* const hourKey = @"hour";
static NSString* const minuteKey = @"minute";
static NSString* const identifierKey = @"identifier";
static NSString* const savedAlarmKey = @"SENSavedAlarmKey";

@interface SENAlarm ()
@property (nonatomic, strong) NSString* identifier;
@end

@implementation SENAlarm

+ (SENAlarm*)savedAlarm
{
    SENAlarm* alarm = [[[SENKeyedArchiver objectsForKey:savedAlarmKey] allObjects] firstObject];
    if (!alarm) {
        NSDictionary* properties = @{
            soundNameKey : @"None",
            hourKey : @7,
            minuteKey : @30,
            onKey : @YES
        };
        alarm = [[SENAlarm alloc] initWithDictionary:properties];
        [alarm save];
    }

    return alarm;
}

- (instancetype)initWithDictionary:(NSDictionary*)dict
{
    if (self = [super init]) {
        _on = [dict[onKey] boolValue];
        _hour = [dict[hourKey] integerValue];
        _minute = [dict[minuteKey] integerValue];
        _soundName = dict[soundNameKey];
        _identifier = dict[identifierKey] ?: [[[NSUUID alloc] init] UUIDString];
    }
    return self;
}

- (NSString*)localizedValue
{
    NSString* minuteText = self.minute < 10 ? [NSString stringWithFormat:@"0%ld", (long)self.minute] : [NSString stringWithFormat:@"%ld", (long)self.minute];
    return [NSString stringWithFormat:@"%ld:%@", (long)self.hour, minuteText];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _on = [[aDecoder decodeObjectForKey:onKey] boolValue];
        _hour = [[aDecoder decodeObjectForKey:hourKey] integerValue];
        _minute = [[aDecoder decodeObjectForKey:minuteKey] integerValue];
        _soundName = [aDecoder decodeObjectForKey:soundNameKey];
        _identifier = [aDecoder decodeObjectForKey:soundNameKey] ?: [[[NSUUID alloc] init] UUIDString];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:@([self isOn]) forKey:onKey];
    [aCoder encodeObject:@([self hour]) forKey:hourKey];
    [aCoder encodeObject:@([self minute]) forKey:minuteKey];
    [aCoder encodeObject:[self soundName] forKey:soundNameKey];
    [aCoder encodeObject:[self identifier] forKey:identifierKey];
}

- (NSUInteger)hash
{
    return [self.identifier hash];
}

- (BOOL)isEqual:(SENAlarm*)alarm
{
    if (![alarm isKindOfClass:[SENAlarm class]])
        return NO;

    return [self.identifier isEqualToString:alarm.identifier];
}

#pragma mark - updating time

- (struct SENAlarmTime)timeByAddingMinutes:(NSInteger)minutes
{
    struct SENAlarmTime alarmTime;
    if (minutes == 0) {
        alarmTime.hour = self.hour;
        alarmTime.minute = self.minute;
        return alarmTime;
    }

    NSInteger addedHours = minutes / 60;
    NSInteger addedMinutes = minutes % 60;
    NSInteger hour = self.hour + addedHours;
    NSInteger minute = self.minute + addedMinutes;

    if (minutes > 0) {
        if (minute > 59) {
            minute -= 60;
            hour += 1;
        }
    } else {
        if (minute < 0) {
            minute += 60;
            hour -= 1;
        }
    }
    hour %= 24;

    if (hour < 0) {
        hour += 24;
    }
    alarmTime.hour = hour;
    alarmTime.minute = minute;
    return alarmTime;
}

- (void)incrementAlarmTimeByMinutes:(NSInteger)minutes
{
    struct SENAlarmTime alarmTime = [self timeByAddingMinutes:minutes];
    self.hour = alarmTime.hour;
    self.minute = alarmTime.minute;
    [self save];
}

#pragma mark - persistence

- (void)save
{
    [SENKeyedArchiver setObjects:[NSSet setWithObject:self] forKey:savedAlarmKey];
}

- (void)setSoundName:(NSString*)soundName
{
    if (![soundName isEqualToString:_soundName]) {
        _soundName = soundName;
        [self save];
    }
}

- (void)setOn:(BOOL)on
{
    if (on != _on) {
        _on = on;
        [self save];
    }
}

@end
