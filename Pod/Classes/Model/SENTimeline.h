
#import <Foundation/Foundation.h>
#import "SENCondition.h"
#import "SENTimelineSegment.h"
#import "SENTimelineMetric.h"
#import "SENSerializable.h"

extern NSInteger const SENTimelineSentinelValue;

@interface SENTimeline : NSObject <NSCoding, SENSerializable, SENUpdatable>

+ (instancetype)timelineForDate:(NSDate*)date;

@property (nonatomic, strong) NSDate* date;
@property (nonatomic, strong) NSNumber* score;
@property (nonatomic) SENCondition scoreCondition;
@property (nonatomic, strong) NSString* message;
@property (nonatomic, strong) NSArray* segments;
@property (nonatomic, strong) NSOrderedSet* sleepPeriods;
@property (nonatomic, strong) NSArray* metrics;
@property (nonatomic, assign, getter=isLocked) BOOL locked;

/**
 *  Persist changes
 */
- (void)save;
@end
