//
//  SENLocalPreferences.h
//  Pods
//
//  Created by Jimmy Lu on 2/19/15.

#import <Foundation/Foundation.h>

extern NSString* const SENLocalPrefAppGroup;
extern NSString* const SENLocalPrefDidChangeNotification;

@interface SENLocalPreferences : NSObject

+ (instancetype)sharedPreferences;

- (BOOL)setUserPreference:(id)preference forKey:(NSString*)key;
- (id)userPreferenceForKey:(NSString*)key;

- (BOOL)setSessionPreference:(id)preference forKey:(NSString*)key;
- (id)sessionPreferenceForKey:(NSString*)key;

- (void)setPersistentPreference:(id)preference forKey:(NSString*)key;
- (id)persistentPreferenceForKey:(NSString*)key;

- (void)removeSessionPreferences;

@end
