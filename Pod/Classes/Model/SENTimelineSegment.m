//
//  SENTimelineSegment.m
//  Pods
//
//  Created by Delisa Mason on 7/9/15.
//
//

#import "SENTimelineSegment.h"
#import "SENTimeline.h"

SENTimelineSegmentSleepState SENTimelineSegmentSleepStateFromString(NSString *segmentType) {
    if ([segmentType isKindOfClass:[NSString class]]) {
        if ([segmentType isEqualToString:@"AWAKE"])
            return SENTimelineSegmentSleepStateAwake;
        else if ([segmentType isEqualToString:@"SOUND"])
            return SENTimelineSegmentSleepStateSound;
        else if ([segmentType isEqualToString:@"MEDIUM"])
            return SENTimelineSegmentSleepStateMedium;
        else if ([segmentType isEqualToString:@"LIGHT"])
            return SENTimelineSegmentSleepStateLight;
    }
    return SENTimelineSegmentSleepStateUnknown;
}

NSDate* SENTimelineDateFromTimestamp(NSNumber* timestampMillis) {
    if (![timestampMillis isKindOfClass:[NSNumber class]])
        return nil;
    return [NSDate dateWithTimeIntervalSince1970:[timestampMillis doubleValue] / 1000];
}

NSTimeZone* SENTimelineTimezoneFromOffset(NSNumber* offsetMillis) {
    if (![offsetMillis isKindOfClass:[NSNumber class]])
        return nil;
    NSInteger seconds = [offsetMillis doubleValue] / 1000;
    return [NSTimeZone timeZoneForSecondsFromGMT:seconds];
}

NSDictionary* SENTimelineSegmentTypeMapping() {
    static NSDictionary* mapping = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mapping = @{
            @"IN_BED": @(SENTimelineSegmentTypeInBed),
            @"GENERIC_MOTION": @(SENTimelineSegmentTypeGenericMotion),
            @"PARTNER_MOTION": @(SENTimelineSegmentTypePartnerMotion),
            @"GENERIC_SOUND": @(SENTimelineSegmentTypeGenericSound),
            @"SNORED": @(SENTimelineSegmentTypeSnored),
            @"SLEEP_TALKED": @(SENTimelineSegmentTypeSleepTalked),
            @"LIGHT": @(SENTimelineSegmentTypeLight),
            @"LIGHTS_OUT": @(SENTimelineSegmentTypeLightsOut),
            @"SUNSET": @(SENTimelineSegmentTypeSunset),
            @"SUNRISE": @(SENTimelineSegmentTypeSunrise),
            @"GOT_IN_BED": @(SENTimelineSegmentTypeGotInBed),
            @"FELL_ASLEEP": @(SENTimelineSegmentTypeFellAsleep),
            @"GOT_OUT_OF_BED": @(SENTimelineSegmentTypeGotOutOfBed),
            @"WOKE_UP": @(SENTimelineSegmentTypeWokeUp),
            @"ALARM_RANG": @(SENTimelineSegmentTypeAlarmRang),
            @"UNKNOWN": @(SENTimelineSegmentTypeUnknown),
        };
    });
    return mapping;
}

SENTimelineSegmentType SENTimelineSegmentTypeFromString(NSString *segmentType) {
    NSNumber* value = SENTimelineSegmentTypeMapping()[segmentType];
    if (value)
        return [value integerValue];
    return SENTimelineSegmentTypeUnknown;
}

NSString* SENTimelineSegmentTypeNameFromType(SENTimelineSegmentType type) {
    NSDictionary* mapping = SENTimelineSegmentTypeMapping();
    NSNumber* valueType = @(type);
    __block NSString *match = @"NONE";
    [mapping enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *obj, BOOL *stop) {
        if ([obj isEqualToNumber:valueType]) {
            match = key;
            *stop = YES;
        }
    }];
    return match;
}

SENTimelineSegmentAction SENTimelineSegmentActionFromStrings(NSArray* actions) {
    SENTimelineSegmentAction action = SENTimelineSegmentActionNone;
    if ([actions isKindOfClass:[NSArray class]]) {
        if ([actions containsObject:@"ADJUST_TIME"])
            action |= SENTimelineSegmentActionAdjustTime;
        if ([actions containsObject:@"VERIFY"])
            action |= SENTimelineSegmentActionApprove;
        if ([actions containsObject:@"REMOVE"])
            action |= SENTimelineSegmentActionRemove;
    }
    return action;
}

@implementation SENTimelineSegment

static NSString* const SENTimelineSegmentServerID = @"id";
static NSString* const SENTimelineSegmentTimestamp = @"timestamp";
static NSString* const SENTimelineSegmentDuration = @"duration_millis";
static NSString* const SENTimelineSegmentEventType = @"event_type";
static NSString* const SENTimelineSegmentMessage = @"message";
static NSString* const SENTimelineSegmentSleepDepth = @"sleep_depth";
static NSString* const SENTimelineSegmentSleepStateKey = @"sleep_state";
static NSString* const SENTimelineSegmentActions = @"valid_actions";
static NSString* const SENTimelineSegmentTimezoneOffset = @"timezone_offset";
static NSString* const SENTimelineSegmentDate = @"event_timestamp";
static NSString* const SENTimelineSegmentKeyType = @"event_type";

- (instancetype)initWithDictionary:(NSDictionary*)segmentData
{
    if (self = [super init]) {
        _date = SENTimelineDateFromTimestamp(segmentData[SENTimelineSegmentTimestamp]);
        _duration = segmentData[SENTimelineSegmentDuration];
        _message = segmentData[SENTimelineSegmentMessage];
        _type = SENTimelineSegmentTypeFromString(segmentData[SENTimelineSegmentEventType]);
        _sleepDepth = [segmentData[SENTimelineSegmentSleepDepth] integerValue];
        _sleepState = SENTimelineSegmentSleepStateFromString(segmentData[SENTimelineSegmentSleepStateKey]);
        _timezone = SENTimelineTimezoneFromOffset(segmentData[SENTimelineSegmentTimezoneOffset]);
        _possibleActions = SENTimelineSegmentActionFromStrings(segmentData[SENTimelineSegmentActions]);
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if (self = [super init]) {
        _date = [aDecoder decodeObjectForKey:SENTimelineSegmentTimestamp];
        _duration = [aDecoder decodeObjectForKey:SENTimelineSegmentDuration];
        _message = [aDecoder decodeObjectForKey:SENTimelineSegmentMessage];
        _type = [aDecoder decodeIntegerForKey:SENTimelineSegmentEventType];
        _sleepDepth = [aDecoder decodeIntegerForKey:SENTimelineSegmentSleepDepth];
        _sleepState = [aDecoder decodeIntegerForKey:SENTimelineSegmentSleepStateKey];
        _possibleActions = [aDecoder decodeIntegerForKey:SENTimelineSegmentActions];
        _timezone = [aDecoder decodeObjectOfClass:[NSTimeZone class] forKey:SENTimelineSegmentTimezoneOffset];
    }
    return self;
}

- (NSString*)description
{
    static NSString* const SENTimelineSegmentDescriptionFormat = @"<SENTimelineSegment @sleepDepth=%ld @duration=%@ @eventType=%ld>";
    return [NSString stringWithFormat:SENTimelineSegmentDescriptionFormat, (long)self.sleepDepth, self.duration, (long)self.type];
}

- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.date forKey:SENTimelineSegmentTimestamp];
    [aCoder encodeObject:self.duration forKey:SENTimelineSegmentDuration];
    [aCoder encodeObject:self.message forKey:SENTimelineSegmentMessage];
    [aCoder encodeInteger:self.type forKey:SENTimelineSegmentEventType];
    [aCoder encodeInteger:self.sleepDepth forKey:SENTimelineSegmentSleepDepth];
    [aCoder encodeInteger:self.possibleActions forKey:SENTimelineSegmentActions];
    [aCoder encodeInteger:self.sleepState forKey:SENTimelineSegmentSleepStateKey];
    [aCoder encodeObject:self.timezone forKey:SENTimelineSegmentTimezoneOffset];
}

- (BOOL)isEqual:(SENTimelineSegment*)object
{
    if (![object isKindOfClass:[SENTimelineSegment class]])
        return NO;
    return ((self.date && [self.date isEqual:object.date]) || (!self.date && !object.date))
        && ((self.duration && [self.duration isEqual:object.duration]) || (!self.duration && !object.duration))
        && ((self.message && [self.message isEqual:object.message]) || (!self.message && !object.message))
        && (self.type == object.type)
        && ((self.timezone && [self.timezone isEqual:object.timezone]) || (!self.timezone && !object.timezone))
        && self.sleepDepth == object.sleepDepth
        && self.sleepState == object.sleepState
        && self.possibleActions == object.possibleActions;
}

- (NSUInteger)hash
{
    return [self.date hash] + [self.duration hash];
}

- (BOOL)updateWithDictionary:(NSDictionary*)data
{
    BOOL changed = NO;
    if (data[SENTimelineSegmentTimestamp]) {
        NSDate* date = SENTimelineDateFromTimestamp(data[SENTimelineSegmentTimestamp]);
        if (![self.date isEqual:date]) {
            self.date = date;
            changed = YES;
        }
    }
    if (data[SENTimelineSegmentDuration] && ![self.duration isEqual:data[SENTimelineSegmentDuration]]) {
        self.duration = data[SENTimelineSegmentDuration];
        changed = YES;
    }
    if (data[SENTimelineSegmentMessage] && ![self.message isEqual:data[SENTimelineSegmentMessage]]) {
        self.message = data[SENTimelineSegmentMessage];
        changed = YES;
    }
    if (data[SENTimelineSegmentEventType]) {
        SENTimelineSegmentType type = SENTimelineSegmentTypeFromString(data[SENTimelineSegmentEventType]);
        if (type != self.type) {
            self.type = type;
            changed = YES;
        }
    }
    if (data[SENTimelineSegmentSleepDepth]) {
        NSInteger sleepDepth = [data[SENTimelineSegmentSleepDepth] integerValue];
        if (self.sleepDepth != sleepDepth) {
            self.sleepDepth = sleepDepth;
            changed = YES;
        }
    }
    if (data[SENTimelineSegmentTimezoneOffset]) {
        NSTimeInterval secondsFromGMT = [data[SENTimelineSegmentTimezoneOffset] doubleValue] / 1000;
        NSTimeZone* zone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
        if (![self.timezone isEqual:zone]) {
            self.timezone = zone;
            changed = YES;
        }
    }
    if (data[SENTimelineSegmentSleepStateKey]) {
        SENTimelineSegmentSleepState state = SENTimelineSegmentSleepStateFromString(data[SENTimelineSegmentSleepStateKey]);
        if (self.sleepState != state) {
            self.sleepState = state;
            changed = YES;
        }
    }
    if (data[SENTimelineSegmentActions]) {
        SENTimelineSegmentAction actions = SENTimelineSegmentActionFromStrings(data[SENTimelineSegmentActions]);
        if (self.possibleActions != actions) {
            self.possibleActions = actions;
            changed = YES;
        }
    }
    return changed;
}

- (BOOL)canPerformAction:(SENTimelineSegmentAction)action {
    return (self.possibleActions & action) == action;
}

@end