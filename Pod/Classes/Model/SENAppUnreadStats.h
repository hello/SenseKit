//
//  SENAppUnreadStats.h
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import <Foundation/Foundation.h>

@interface SENAppUnreadStats : NSObject

@property (nonatomic, assign, readonly, getter=hasUnreadInsights) BOOL unreadInsights;
@property (nonatomic, assign, readonly, getter=hasUnreadQuestions) BOOL unreadQuestions;

- (instancetype _Nonnull)initWithDictionary:(NSDictionary* _Nonnull)dictionary;
- (NSDictionary* _Nonnull)dictionaryValue;

@end
