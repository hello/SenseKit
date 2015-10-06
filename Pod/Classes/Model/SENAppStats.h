//
//  SENAppStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENAppStats : NSObject

@property (nonatomic, strong, nullable) NSDate* lastViewedInsights;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary*)dictionary;
- (nonnull NSDictionary*)dictionaryValue;

@end
