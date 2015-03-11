//
//  SENAnalytics.m
//  Pods
//
//  Created by Jimmy Lu on 10/20/14.
//
//

#import "SENAnalytics.h"
#import "SENAuthorizationService.h"
#import "SENAnalyticsMixpanel.h"
#import "SENAnalyticsLogger.h"

NSString* const kSENAnalyticsConfigAPIKey = @"kSENAnalyticsConfigAPIKey";
NSString* const kSENAnalyticsPropConnection = @"connection";
NSString* const kSENAnalyticsPropCode = @"code";
NSString* const kSENAnalyticsPropMessage = @"message";
NSString* const kSENAnalyticsPropDomain = @"domain";

@implementation SENAnalytics

static NSMutableDictionary* providers;

+ (void)configure:(SENAnalyticsProviderName)name with:(NSDictionary*)properties {
    id<SENAnalyticsProvider> provider;

    switch (name) {
        case SENAnalyticsProviderNameMixpanel:
            provider = [[SENAnalyticsMixpanel alloc] init];
            break;
        case SENAnalyticsProviderNameLogger:
            provider = [[SENAnalyticsLogger alloc] init];
            break;
        default:
            break;
    }

    [provider configureWithProperties:properties];
    if (!providers)
        providers = [NSMutableDictionary new];
    if (provider)
        providers[@(name)] = provider;
}

+ (void)setUserId:(NSString*)userId properties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider setUserId:userId withProperties:properties];
    }];
}

+ (void)userWithId:(NSString*)userId didSignUpWithProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider userWithId:userId didSignupWithProperties:properties];
    }];
}

+ (void)setGlobalEventProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider setGlobalEventProperties:properties];
    }];
}

+ (void)setUserProperties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider setUserProperties:properties];
    }];
}

+ (void)track:(NSString*)eventName {
    [self track:eventName properties:nil];
}

+ (void)track:(NSString*)eventName properties:(NSDictionary*)properties {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider track:eventName withProperties:properties];
    }];
}

+ (void)trackError:(NSError*)error withEventName:(NSString*)eventName {
    NSMutableDictionary* mutableProps = [NSMutableDictionary dictionaryWithCapacity:2];
    if ([error isKindOfClass:[NSError class]]) { // making sure error is an error.  sometimes it can be NSNull...
        [mutableProps setValue:@([error code]) forKey:kSENAnalyticsPropCode];
        [mutableProps setValue:[error localizedDescription] forKey:kSENAnalyticsPropMessage];
        [mutableProps setValue:[error domain] forKey:kSENAnalyticsPropDomain];
    }
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider track:eventName withProperties:mutableProps];
    }];
}

+ (void)startEvent:(NSString *)eventName {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider startEvent:eventName];
    }];
}

+ (void)endEvent:(NSString *)eventName {
    [providers enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, id<SENAnalyticsProvider> provider, BOOL *stop) {
        [provider endEvent:eventName];
    }];
}

@end
