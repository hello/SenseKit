//
//  SENAlarmCollection.m
//  Pods
//
//  Created by Jimmy Lu on 10/4/16.
//
//

#import "SENAlarmCollection.h"
#import "Model.h"

static NSString* const kSENAlarmsAttrExpansions = @"expansions";
static NSString* const kSENAlarmsAttrVoice = @"voice";
static NSString* const kSENAlarmsAttrClassic = @"classic";

@implementation SENAlarmCollection

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        NSArray* rawExpansions = SENObjectOfClass(data[kSENAlarmsAttrExpansions], [NSArray class]);
        _expansionAlarms = [self alarmsFromResponse:rawExpansions];
        
        rawExpansions = SENObjectOfClass(data[kSENAlarmsAttrVoice], [NSArray class]);
        _voiceAlarms = [self alarmsFromResponse:rawExpansions];
        
        rawExpansions = SENObjectOfClass(data[kSENAlarmsAttrClassic], [NSArray class]);
        _classicAlarms = [self alarmsFromResponse:rawExpansions];
    }
    return self;
}

- (NSArray<SENAlarm*>*)alarmsFromResponse:(NSArray*)rawAlarms {
    NSMutableArray<SENAlarm*>* alarms = [NSMutableArray arrayWithCapacity:[rawAlarms count]];
    for (id rawAlarm in rawAlarms) {
        if ([rawAlarm isKindOfClass:[NSDictionary class]]) {
            [alarms addObject:[[SENAlarm alloc] initWithDictionary:rawAlarm]];
        }
    }
    return alarms;
}

- (NSArray<NSDictionary*>*)serializeAlarms:(NSArray<SENAlarm*>*)alarms {
    NSMutableArray<NSDictionary*>* rawAlarms = [NSMutableArray arrayWithCapacity:[alarms count]];
    for (SENAlarm* alarm in alarms) {
        [rawAlarms addObject:[alarm dictionaryValue]];
    }
    return rawAlarms;
}

- (NSDictionary*)dictionaryValue {
    return @{kSENAlarmsAttrExpansions : [self serializeAlarms:[self expansionAlarms]],
             kSENAlarmsAttrVoice : [self serializeAlarms:[self voiceAlarms]],
             kSENAlarmsAttrClassic : [self serializeAlarms:[self classicAlarms]]};
}

@end
