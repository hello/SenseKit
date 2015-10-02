//
//  SENAppStats.m
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import "SENAppStats.h"
#import "Model.h"

static NSString* const SENAppStatsInsightsLastViewed = @"insights_last_viewed";

@interface SENAppStats()

@property (nonatomic, strong) NSDate* lastViewedInsights;

@end

@implementation SENAppStats

- (nonnull instancetype)initWithDictionary:(nonull NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _lastViewedInsights = SENDateFromNumber(dictionary[SENAppStatsInsightsLastViewed]);
    }
    return self;
}

- (nonnull NSDictionary*)dictionaryValue {
    if (![self lastViewedInsights]) {
        return @{};
    }
    return @{SENAppStatsInsightsLastViewed : SENDateMillisecondsSince1970([self lastViewedInsights])};
}

@end
