//
//  SENServiceHealthKit.m
//  Pods
//
//  Created by Jimmy Lu on 1/26/15.
//
//
#import <CocoaLumberjack/DDLog.h>

#import <HealthKit/HealthKit.h>

#import "SENServiceHealthKit.h"
#import "SENService+Protected.h"
#import "Model.h"
#import "SENAPITimeline.h"
#import "SENLocalPreferences.h"

#ifndef ddLogLevel
#define ddLogLevel LOG_LEVEL_VERBOSE
#endif

static NSString* const SENServiceHKErrorDomain = @"is.hello.service.hk";
static NSString* const SENServiceHKLastDateWritten = @"is.hello.service.hk.lastdate";
static NSString* const SENServiceHKEnable = @"is.hello.service.hk.enable";
static CGFloat const SENServiceHKBackFillLimit = 3;

@interface SENServiceHealthKit()

@property (nonatomic, strong) HKHealthStore* hkStore;

@end

@implementation SENServiceHealthKit

+ (id)sharedService {
    static SENServiceHealthKit* service = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[super allocWithZone:NULL] init];
    });
    return service;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedService];
}

- (id)init {
    self = [super init];
    if (self) {
        [self configureStore];
    }
    return self;
}

- (void)configureStore {
    if ([HKHealthStore isHealthDataAvailable]) {
        [self setHkStore:[[HKHealthStore alloc] init]];
    }
}

#pragma mark - Preferences / Settings

- (void)setEnableHealthKit:(BOOL)enable {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:@(enable) forKey:SENServiceHKEnable];
}

- (BOOL)isHealthKitEnabled {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [[preferences userPreferenceForKey:SENServiceHKEnable] boolValue];
}

- (void)saveLastSyncDate:(NSDate*)date {
    if (date == nil) {
        return;
    }
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    [preferences setUserPreference:date forKey:SENServiceHKLastDateWritten];
}

- (NSDate*)lastSyncDate {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    return [preferences userPreferenceForKey:SENServiceHKLastDateWritten];
}

#pragma mark - Support / Authorization

- (BOOL)isSupported {
    return [self hkStore] != nil;
}

- (BOOL)canWriteSleepAnalysis {
    if (![self isSupported]) return NO;
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    HKAuthorizationStatus status = [[self hkStore] authorizationStatusForType:hkSleepCategory];
    return status == HKAuthorizationStatusSharingAuthorized;
}

- (void)requestAuthorization:(void(^)(NSError* error))completion {
    if (![self isSupported]) {
        if (completion) {
            completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                            code:SENServiceHealthKitErrorNotSupported
                                        userInfo:nil]);
        }
        return;
    }
    
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    
    NSSet* writeTypes = [NSSet setWithObject:hkSleepCategory];
    NSSet* readTypes = [NSSet setWithObject:hkSleepCategory]; // there will be more, soon
    
    [[self hkStore] requestAuthorizationToShareTypes:writeTypes readTypes:readTypes completion:^(BOOL success, NSError *error) {
        NSError* serviceError = error;
        HKAuthorizationStatus status = [[self hkStore] authorizationStatusForType:hkSleepCategory];
        switch (status) {
            case HKAuthorizationStatusSharingDenied:
                serviceError = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                   code:SENServiceHealthKitErrorNotAuthorized
                                               userInfo:nil];
                break;
            case HKAuthorizationStatusNotDetermined: // user cancelled form
                serviceError = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                   code:SENServiceHealthKitErrorCancelledAuthorization
                                               userInfo:nil];
                break;
            default:
                break;
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (serviceError);
            });
        }
        
    }];
}

#pragma mark - Sync

- (void)sync:(void(^)(NSError* error))completion {
    void(^done)(NSError* error) = ^(NSError* error) {
        if (completion) {
            completion (error);
        }
    };
    
    BOOL enabled = [self isHealthKitEnabled];
    BOOL supported = [self isSupported];
    BOOL authorized = [self canWriteSleepAnalysis];
    
    if (enabled && supported && authorized) {
        [self syncRecentMissingDays:done];
    } else {
        SENServiceHealthKitError code;
        if (!enabled) {
            code = SENServiceHealthKitErrorNotEnabled;
        } else if (!supported) {
            code = SENServiceHealthKitErrorNotSupported;
        } else {
            code = SENServiceHealthKitErrorNotAuthorized;
        }
        done ([NSError errorWithDomain:SENServiceHKErrorDomain code:code userInfo:nil]);
    }
}

- (void)syncRecentMissingDays:(void(^)(NSError* error))completion {
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // last night
    NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents* todayComponents = [calendar components:unitsWeCareAbout fromDate:[NSDate date]];
    NSDate* today = [calendar dateFromComponents:todayComponents];
    
    NSDateComponents* lastNightComponents = [[NSDateComponents alloc] init];
    [lastNightComponents setDay:-1];
    NSDate* lastNight = [calendar dateByAddingComponents:lastNightComponents toDate:today options:0];
    
    // last time it was sync'ed
    NSDate* lastSyncDate = [self lastSyncDate];
    NSDate* syncFromDate = nil;
    
    if (lastSyncDate) {
        NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                                   fromDate:lastSyncDate
                                                     toDate:lastNight
                                                    options:0];
        if ([difference day] == 0) {
            completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                            code:SENServiceHealthKitErrorAlreadySynced
                                        userInfo:nil]);
            return;
        } else if ([difference day] == 1) {
            // special case for when user is consistently syncing everyday.  This
            // can be handled by the else case, but this just avoids having to do
            // the arithmetic
            syncFromDate = lastNight;
        } else {
            NSDateComponents* backFillComps = [[NSDateComponents alloc] init];
            [backFillComps setDay:-MAX([difference day] - 1, SENServiceHKBackFillLimit)];
            syncFromDate = [calendar dateByAddingComponents:backFillComps
                                                     toDate:lastNight
                                                    options:0];
        }
    } else { // if never been sync'ed before, just sync last night's data
        syncFromDate = lastNight;
    }
    
    __weak typeof(self) weakSelf = self;
    [self syncTimelineDataFrom:syncFromDate until:lastNight withCalendar:calendar completion:^(NSArray* timelines, NSError *error) {
        if (!error) {
            [weakSelf saveLastSyncDate:lastNight];
        }
        completion (error);
    }];
}

- (void)syncTimelineDataFrom:(NSDate*)startDate
                       until:(NSDate*)endDate
                withCalendar:(NSCalendar*)calendar
                  completion:(void(^)(NSArray* timelines, NSError* error))completion {
    NSCalendarUnit unitsWeCareAbout = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDate* nextStartDate = startDate;
    NSUInteger daysFromStartDate = 0;
    NSDateComponents* components = nil;
    
    BOOL haveTimelines = NO;
    NSMutableArray* timelines = [NSMutableArray array];
    dispatch_group_t getTimelineGroup = dispatch_group_create();
    
    __weak typeof(self) weakSelf = self;
    while ([calendar compareDate:nextStartDate toDate:endDate toUnitGranularity:unitsWeCareAbout] != NSOrderedDescending) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        haveTimelines = YES;
        
        dispatch_group_enter(getTimelineGroup);
        [strongSelf timelineForDate:nextStartDate completion:^(SENTimeline *timeline, NSError *error) {
            if (timeline) {
                [timelines addObject:timeline];
            }
            dispatch_group_leave(getTimelineGroup);
        }];
        
        daysFromStartDate++;
        components = [[NSDateComponents alloc] init];
        [components setDay:daysFromStartDate];
        nextStartDate = [calendar dateByAddingComponents:components toDate:nextStartDate options:0];
    }
    
    if (!haveTimelines) {
        completion (nil, [NSError errorWithDomain:SENServiceHKErrorDomain
                                             code:SENServiceHealthKitErrorNoDataToWrite
                                         userInfo:@{NSLocalizedDescriptionKey : @"start and end date did not evaluate to timelines"}]);
        return;
    }
    
    long queuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT;
    dispatch_queue_t queue = dispatch_get_global_queue(queuePriority, 0);
    dispatch_group_notify(getTimelineGroup, queue, ^{
        [weakSelf syncTimelinesToHealthKit:timelines completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion (timelines, error);
            });
        }];
    });

}

- (void)timelineForDate:(NSDate*)date completion:(void(^)(SENTimeline* timeline, NSError* error))completion {
    SENTimeline* timeline = [SENTimeline timelineForDate:date];
    if ([[timeline metrics] count] > 0 && [timeline scoreCondition] != SENConditionUnknown) {
        completion (timeline, nil);
    } else {
        [SENAPITimeline timelineForDate:date completion:^(id data, NSError *error) {
            SENTimeline* timeline = data;
            if (!error) {
                if ([timeline isKindOfClass:[SENTimeline class]]) {
                    [timeline save];
                } else {
                    timeline = nil;
                    error = [NSError errorWithDomain:SENServiceHKErrorDomain
                                                code:SENServiceHealthKitErrorUnexpectedAPIResponse
                                            userInfo:nil];
                }
            }
            completion (timeline, error);
        }];
    }
}

- (void)syncTimelinesToHealthKit:(NSArray*)timelines completion:(void(^)(NSError* error))completion {
    NSUInteger timelineCount = [timelines count];
    if (timelineCount == 0) {
        completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                        code:SENServiceHealthKitErrorNoDataToWrite
                                    userInfo:nil]);
        return;
    }
    
    HKSample* sample = nil;
    NSMutableArray* samples = [NSMutableArray arrayWithCapacity:timelineCount];
    for (SENTimeline* timeline in timelines) {
        sample = [self sleepSampleFromTimeline:timeline];
        if (sample) {
            [samples addObject:sample];
        }
    }
    
    if ([samples count] == 0) {
        completion ([NSError errorWithDomain:SENServiceHKErrorDomain
                                        code:SENServiceHealthKitErrorNoDataToWrite
                                    userInfo:nil]);
        return;
    }
    
    [[self hkStore] saveObjects:samples withCompletion:^(BOOL success, NSError *error) {
        completion (error);
    }];
}

- (HKSample*)sleepSampleFromTimeline:(SENTimeline*)sleepResult {
    HKSample* sample = nil;
    HKCategoryType* hkSleepCategory = [HKObjectType categoryTypeForIdentifier:HKCategoryTypeIdentifierSleepAnalysis];
    NSDate* wakeUpDate = nil;
    NSDate* sleepDate = nil;
    NSArray* metrics = [sleepResult metrics];

    for (SENTimelineMetric* metric in metrics) {
        CGFloat metricValue = [metric.value doubleValue];
        
        if (!sleepDate
            && metric.type == SENTimelineMetricTypeFellAsleep
            && metric.unit == SENTimelineMetricUnitTimestamp
            && metricValue > 0) {
            sleepDate = SENDateFromNumber(metric.value);
        }

        if (sleepDate != nil
            && metric.type == SENTimelineMetricTypeWokeUp
            && metric.unit == SENTimelineMetricUnitTimestamp
            && metricValue > 0) {
            wakeUpDate = SENDateFromNumber(metric.value);
        }
    }
    
    if (wakeUpDate != nil && sleepDate != nil) {
        DDLogVerbose(@"adding asleep data point");
        if ([wakeUpDate compare:sleepDate] > NSOrderedAscending) {
            sample = [HKCategorySample categorySampleWithType:hkSleepCategory
                                                        value:HKCategoryValueSleepAnalysisAsleep
                                                    startDate:sleepDate
                                                      endDate:wakeUpDate];
        } else {
            DDLogVerbose(@"wake up time %@ is before sleep time %@", wakeUpDate, sleepDate);
        }
    }
    
    return sample;
}

@end
