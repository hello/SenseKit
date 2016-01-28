//
//  SENTrendGraph.m
//  Pods
//
//  Created by Jimmy Lu on 1/28/16.
//
//
#import "Model.h"
#import "SENTrendsGraph.h"
#import "SENConditionRange.h"

static NSString* const SENTrendGraphSectionValues = @"values";
static NSString* const SENTrendGraphSectionTitles = @"titles";
static NSString* const SENTrendGraphSectionHighlightedValues = @"highlighted_values";
static NSString* const SENTrendGraphSectionHighlightedTitle = @"highlighted_title";
static NSString* const SENTrendGraphTitle = @"title";
static NSString* const SENTrendGraphValue = @"value";
static NSString* const SENTrendGraphDataType = @"data_type";
static NSString* const SENTrendGraphDataTypeScore = @"SCORES";
static NSString* const SENTrendGraphDataTypeHour = @"HOURS";
static NSString* const SENTrendGraphDataTypePercent = @"PERCENTS";
static NSString* const SENTrendGraphCondition = @"condition";
static NSString* const SENTrendGraphDisplayType = @"graph_type";
static NSString* const SENTrendGraphDisplayTypeGrid = @"GRID";
static NSString* const SENTrendGraphDisplayTypeOverview = @"OVERVIEW";
static NSString* const SENTrendGraphDisplayTypeBar = @"BAR";
static NSString* const SENTrendGraphDisplayTypeBubble = @"BUBBLES";
static NSString* const SENTrendGraphTimeScale = @"time_scale";
static NSString* const SENTrendGraphTimeScaleWeek = @"last_week";
static NSString* const SENTrendGraphTimeScaleMonth = @"last_month";
static NSString* const SENTrendGraphTimeScaleQuarter = @"last_3_months";
static NSString* const SENTrendGraphMinValue = @"min_value";
static NSString* const SENTrendGraphMaxValue = @"max_value";
static NSString* const SENTrendGraphSections = @"sections";
static NSString* const SENTrendGraphConditionRanges = @"condition_ranges";
static NSString* const SENTrendGraphAnnotations = @"annotations";

SENTrendDataType SENTrendDataTypeFromString(id dataType) {
    SENTrendDataType type = SENTrendDataTypeUnknown;
    if ([dataType isKindOfClass:[NSString class]]) {
        if ([dataType isEqualToString:SENTrendGraphDataTypeScore]) {
            type = SENTrendDataTypeScore;
        } else if ([dataType isEqualToString:SENTrendGraphDataTypeHour]) {
            type = SENTrendDataTypeHour;
        } else if ([dataType isEqualToString:SENTrendGraphDataTypePercent]) {
            type = SENTrendDataTypePercent;
        }
    }
    return type;
}

SENTrendTimeScale SENTrendTimeScaleFromString(id timeScale) {
    SENTrendTimeScale time = SENTrendTimeScaleUnknown;
    if ([timeScale isKindOfClass:[NSString class]]) {
        if ([timeScale isEqualToString:SENTrendGraphTimeScaleWeek]) {
            time = SENTrendTimeScaleWeek;
        } else if ([timeScale isEqualToString:SENTrendGraphTimeScaleMonth]) {
            time = SENTrendTimeScaleMonth;
        } else if ([timeScale isEqualToString:SENTrendGraphTimeScaleQuarter]) {
            time = SENTrendTimeScaleQuarter;
        }
    }
    return time;
}

@interface SENTrendGraphSection()

@property (nonatomic, strong) NSArray<NSNumber*>* values;
@property (nonatomic, strong) NSArray<NSString*>* titles;
@property (nonatomic, strong) NSArray<NSNumber*>* highlightedValues;
@property (nonatomic, strong) NSArray<NSString*>* highlightedTitles;

@end

@implementation SENTrendGraphSection

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _values = SENObjectOfClass(dictionary[SENTrendGraphSectionValues], [NSArray class]);
        _titles = SENObjectOfClass(dictionary[SENTrendGraphSectionTitles], [NSArray class]);
        _highlightedValues = SENObjectOfClass(dictionary[SENTrendGraphSectionHighlightedValues], [NSArray class]);
        _highlightedTitles = SENObjectOfClass(dictionary[SENTrendGraphSectionHighlightedTitle], [NSArray class]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENTrendGraphSection class]]) {
        return NO;
    }
    
    SENTrendGraphSection* other = object;
    return ((![self values] && ![other values]) || [[self values] isEqual:[other values]])
    && ((![self titles] && ![other titles]) || [[self titles] isEqual:[other titles]])
    && ((![self highlightedValues] && ![other highlightedValues]) || [[self highlightedValues] isEqual:[other highlightedValues]])
    && ((![self highlightedTitles] && ![other highlightedTitles]) || [[self highlightedTitles] isEqual:[other highlightedTitles]]);
}

- (NSUInteger)hash {
    NSUInteger const prime = 7;
    NSUInteger result = prime + [[self values] hash];
    result = prime * result + [[self titles] hash];
    result = prime * result + [[self highlightedValues] hash];
    result = prime * result + [[self highlightedTitles] hash];
    return result;
}

@end

@interface SENTrendAnnotation()

@property (nonatomic, copy) NSString* title;
@property (nonatomic, strong) NSNumber* value;
@property (nonatomic, assign) SENTrendDataType dataType;
@property (nonatomic, assign) SENCondition condition;

@end

@implementation SENTrendAnnotation

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _title = SENObjectOfClass(dictionary[SENTrendGraphTitle], [NSString class]);
        _value = SENObjectOfClass(dictionary[SENTrendGraphValue], [NSNumber class]);
        _dataType = SENTrendDataTypeFromString(dictionary[SENTrendGraphDataType]);
        _condition = SENConditionFromString(dictionary[SENTrendGraphCondition]);
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENTrendAnnotation class]]) {
        return NO;
    }
    
    SENTrendAnnotation* other = object;
    return ((![self title] && ![other title]) || [[self title] isEqualToString:[other title]])
        && ((![self value] && ![other value]) || [[self value] isEqual:[other value]])
        && [self dataType] == [other dataType]
        && [self condition] == [other condition];
}

- (NSUInteger)hash {
    NSUInteger const prime = 11;
    NSUInteger result = prime + [[self title] hash];
    result = prime * result + [[self value] hash];
    result = prime * result + [self dataType];
    result = prime * result + [self condition];
    return result;
}

@end

@interface SENTrendsGraph()

@property (nonatomic, assign) SENTrendTimeScale timeScale;
@property (nonatomic, assign) SENTrendDataType dataType;
@property (nonatomic, assign) SENTrendDisplayType displayType;
@property (nonatomic, copy)   NSString* title;
@property (nonatomic, strong) NSNumber* minValue;
@property (nonatomic, strong) NSNumber* maxValue;
@property (nonatomic, strong) NSArray<SENConditionRange*>* conditionRanges;
@property (nonatomic, strong) NSArray<SENTrendGraphSection*>* sections;
@property (nonatomic, strong) NSArray<SENTrendAnnotation*>* annotations;

@end

@implementation SENTrendsGraph

SENTrendDisplayType SENTrendDisplayTypeFromString(id displayType) {
    SENTrendDisplayType type = SENTrendDisplayTypeUnknown;
    if ([displayType isKindOfClass:[NSString class]]) {
        if ([displayType isEqualToString:SENTrendGraphDisplayTypeGrid]) {
            type = SENTrendDisplayTypeGrid;
        } else if ([displayType isEqualToString:SENTrendGraphDisplayTypeOverview]) {
            type = SENTrendDisplayTypeOverview;
        } else if ([displayType isEqualToString:SENTrendGraphDisplayTypeBar]) {
            type = SENTrendDisplayTypeBar;
        } else if ([displayType isEqualToString:SENTrendGraphDisplayTypeBubble]) {
            type = SENTrendDisplayTypeBubble;
        }
    }
    return type;
}

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _timeScale = SENTrendTimeScaleFromString(dictionary[SENTrendGraphTimeScale]);
        _dataType = SENTrendDataTypeFromString(dictionary[SENTrendGraphDataType]);
        _displayType = SENTrendDisplayTypeFromString(dictionary[SENTrendGraphDisplayType]);
        _title = SENObjectOfClass(dictionary[SENTrendGraphTitle], [NSString class]);
        _minValue = SENObjectOfClass(dictionary[SENTrendGraphMinValue], [NSNumber class]);
        _maxValue = SENObjectOfClass(dictionary[SENTrendGraphMaxValue], [NSNumber class]);
        
        NSArray* rawSections = SENObjectOfClass(dictionary[SENTrendGraphSections], [NSArray class]);
        _sections = [self sectionsFromRawValues:rawSections];
        
        NSArray* rawRanges = SENObjectOfClass(dictionary[SENTrendGraphConditionRanges], [NSArray class]);
        _conditionRanges = [self conditionRangesFromRawValues:rawRanges];
        
        NSArray* rawAnnotations = SENObjectOfClass(dictionary[SENTrendGraphAnnotations], [NSArray class]);
        _annotations = [self annotationsFromRawValues:rawAnnotations];
    }
    return self;
}

- (NSArray*)sectionsFromRawValues:(NSArray*)rawSections {
    NSMutableArray*  sections = [NSMutableArray arrayWithCapacity:[rawSections count]];
    for (id rawSection in rawSections) {
        if ([rawSection isKindOfClass:[NSDictionary class]]) {
            [sections addObject:[[SENTrendGraphSection alloc] initWithDictionary:rawSection]];
        }
    }
    return sections;
}

- (NSArray*)conditionRangesFromRawValues:(NSArray*)rawRanges {
    NSMutableArray*  ranges = [NSMutableArray arrayWithCapacity:[rawRanges count]];
    for (id rawRange in rawRanges) {
        if ([rawRange isKindOfClass:[NSDictionary class]]) {
            [ranges addObject:[[SENConditionRange alloc] initWithDictionary:rawRange]];
        }
    }
    return ranges;
}

- (NSArray*)annotationsFromRawValues:(NSArray*)rawAnnotations {
    NSMutableArray*  annotations = [NSMutableArray arrayWithCapacity:[rawAnnotations count]];
    for (id rawAnnotation in rawAnnotations) {
        if ([rawAnnotation isKindOfClass:[NSDictionary class]]) {
            [annotations addObject:[[SENTrendAnnotation alloc] initWithDictionary:rawAnnotation]];
        }
    }
    return annotations;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[SENTrendsGraph class]]) {
        return NO;
    }
    
    SENTrendsGraph* other = object;
    return [self timeScale] == [other timeScale]
        && [self dataType] == [other dataType]
        && [self displayType] == [other displayType]
        && ((![self title] && ![other title]) || [[self title] isEqualToString:[other title]])
        && ((![self minValue] && ![other minValue]) || [[self minValue] isEqual:[other minValue]])
        && ((![self maxValue] && ![other maxValue]) || [[self maxValue] isEqual:[other maxValue]])
        && ((![self sections] && ![other sections]) || [[self sections] isEqual:[other sections]])
        && ((![self conditionRanges] && ![other conditionRanges]) || [[self conditionRanges] isEqual:[other conditionRanges]])
        && ((![self annotations] && ![other annotations]) || [[self annotations] isEqual:[other annotations]]);
}

- (NSUInteger)hash {
    NSUInteger const prime = 23;
    NSUInteger result = prime + [self timeScale];
    result = prime * result + [self dataType];
    result = prime * result + [self displayType];
    result = prime * result + [[self title] hash];
    result = prime * result + [[self minValue] hash];
    result = prime * result + [[self maxValue] hash];
    result = prime * result + [[self sections] hash];
    result = prime * result + [[self conditionRanges] hash];
    result = prime * result + [[self annotations] hash];
    return result;
}

@end
