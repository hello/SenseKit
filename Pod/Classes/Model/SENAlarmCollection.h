//
//  SENAlarmCollection.h
//  Pods
//
//  Created by Jimmy Lu on 10/4/16.
//
//

#import <Foundation/Foundation.h>
#import "SENSerializable.h"

@class SENAlarm;

@interface SENAlarmCollection : NSObject <SENSerializable>

@property (nonatomic, strong) NSArray<SENAlarm*>* expansionAlarms;
@property (nonatomic, strong) NSArray<SENAlarm*>* voiceAlarms;
@property (nonatomic, strong) NSArray<SENAlarm*>* classicAlarms;

- (NSDictionary*)dictionaryValue;

@end
