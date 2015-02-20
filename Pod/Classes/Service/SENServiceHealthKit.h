//
//  SENServiceHealthKit.h
//  Pods
//
//  Created by Jimmy Lu on 1/26/15.
//
//

#import "SENService.h"

typedef NS_ENUM(NSUInteger, SENServiceHealthKitError) {
    SENServiceHealthKitErrorNotAuthorized,
    SENServiceHealthKitErrorNotSupported
};

@interface SENServiceHealthKit : SENService

/**
 * Obtain the shared HealthKit service, which will integrate Sense with
 * iOS 8+'s HealthKit
 */
+ (id)sharedService;

/**
 * Request authorization from the user to read/write from/in to HealthKit
 * @param completion: block to invoke when user completes denying/authorizing
 */
- (void)requestAuthorization:(void(^)(NSError* error))completion;

/**
 * @return YES if service can write sleep analysis to HealthKit, NO otherwise
 */
- (BOOL)canWriteSleepAnalysis;

/**
 * @return YES if healthKit is supported on device.  No otherwise
 */
- (BOOL)isSupported;

/**
 * @discussion
 * Set a user specific preference to determine the preference of the user.  This
 * flag operates independently of whether user actually gave us permission as
 * writing and saving are diffrent system flags.  This flag mainly just remembers
 * the user's preference.
 *
 * Yes is required to write or read to healthkit, regardless of permission
 *
 * @param enable: YES to enable it, NO otherwise
 */
- (void)setEnableHealthKit:(BOOL)enable;

/**
 * @return user preference flag to determine if user enabled it or not, regardless
 * of whether or not we were given permission as that can be changed per device
 * and not per user
 */
- (BOOL)isHealthKitEnabled;

@end
