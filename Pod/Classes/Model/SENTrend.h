//
//  SENTrend.h
//  Pods
//
//  Created by Delisa Mason on 1/14/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENTrendGraphType) {
    SENTrendGraphTypeUnknown,
    SENTrendGraphTypeHistogram,
    SENTrendGraphTypeTimeSeriesLine,
};

typedef NS_ENUM(NSUInteger, SENTrendDataPointQuality) {
    SENTrendDataPointQualityUnknown,
    SENTrendDataPointQualityGood,
    SENTrendDataPointQualityOk,
    SENTrendDataPointQualityBad,
};

@interface SENTrend : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong, readonly) NSString* title;
@property (nonatomic, strong, readonly) NSString* dataType;
@property (nonatomic, strong, readonly) NSString* timePeriod;
@property (nonatomic, strong, readonly) NSArray* dataPoints;
@property (nonatomic, strong, readonly) NSArray* options;
@property (nonatomic, readonly) SENTrendGraphType graphType;
@end

@interface SENTrendDataPoint : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@property (nonatomic, strong, readonly) NSDate* date;
@property (nonatomic, readonly) CGFloat xValue;
@property (nonatomic, readonly) CGFloat yValue;
@property (nonatomic, readonly) CGFloat millisecondsOffset;
@property (nonatomic, readonly) SENTrendDataPointQuality quality;
@end