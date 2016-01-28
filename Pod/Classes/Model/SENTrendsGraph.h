//
//  SENTrendsGraph.h
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//

#import <Foundation/Foundation.h>
#import "SENConditionRange.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SENTrendTimeScale) {
    SENTrendTimeScaleUnknown = 1,
    SENTrendTimeScaleWeek,
    SENTrendTimeScaleMonth,
    SENTrendTimeScaleQuarter
};

typedef NS_ENUM(NSUInteger, SENTrendDataType) {
    SENTrendDataTypeUnknown = 1,
    SENTrendDataTypeScore,
    SENTrendDataTypeHour,
    SENTrendDataTypePercent
};

typedef NS_ENUM(NSUInteger, SENTrendDisplayType) {
    SENTrendDisplayTypeUnknown = 1,
    SENTrendDisplayTypeGrid,
    SENTrendDisplayTypeOverview,
    SENTrendDisplayTypeBar,
    SENTrendDisplayTypeBubble
};

SENTrendDataType SENTrendDataTypeFromString(id dataType);
SENTrendTimeScale SENTrendTimeScaleFromString(id timeScale);

@interface SENTrendGraphSection : NSObject

@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber*>* values;
@property (nonatomic, strong, readonly, nullable) NSArray<NSString*>* titles;
@property (nonatomic, strong, readonly, nullable) NSArray<NSNumber*>* highlightedValues;
@property (nonatomic, strong, readonly, nullable) NSArray<NSString*>* highlightedTitles;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENTrendAnnotation : NSObject

@property (nonatomic, copy, readonly, nullable) NSString* title;
@property (nonatomic, strong, readonly, nullable) NSNumber* value;
@property (nonatomic, assign, readonly) SENTrendDataType dataType;
@property (nonatomic, assign, readonly) SENCondition condition;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

@interface SENTrendsGraph : NSObject

@property (nonatomic, assign, readonly) SENTrendTimeScale timeScale;
@property (nonatomic, assign, readonly) SENTrendDataType dataType;
@property (nonatomic, assign, readonly) SENTrendDisplayType displayType;
@property (nonatomic, copy, readonly, nullable)   NSString* title;
@property (nonatomic, strong, readonly, nullable) NSNumber* minValue;
@property (nonatomic, strong, readonly, nullable) NSNumber* maxValue;
@property (nonatomic, strong, readonly, nullable) NSArray<SENConditionRange*>* conditionRanges;
@property (nonatomic, strong, readonly, nullable) NSArray<SENTrendGraphSection*>* sections;
@property (nonatomic, strong, readonly, nullable) NSArray<SENTrendAnnotation*>* annotations;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@end

NS_ASSUME_NONNULL_END