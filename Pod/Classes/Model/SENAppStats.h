//
//  SENAppStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENAppStats : NSObject

@property (nonatomic, strong, readonly) NSDate* lastViewedInsights;

- (instancetype _Nonnull)initWithDictionary:(NSDictionary* _Nonnull)dictionary;
- (NSDictionary* _Nonnull)dictionaryValue;

@end
