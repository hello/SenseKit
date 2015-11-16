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
static NSString* const SENAppStatsQuestionsLastViewed = @"questions_last_viewed";

@implementation SENAppStats

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _lastViewedInsights = SENDateFromNumber(dictionary[SENAppStatsInsightsLastViewed]);
        _lastViewedQuestions = SENDateFromNumber(dictionary[SENAppStatsQuestionsLastViewed]);
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    if (![self lastViewedInsights]) {
        return @{};
    }
    return @{SENAppStatsInsightsLastViewed : SENDateMillisecondsSince1970([self lastViewedInsights]),
             SENAppStatsQuestionsLastViewed : SENDateMillisecondsSince1970([self lastViewedQuestions])};
}

@end
