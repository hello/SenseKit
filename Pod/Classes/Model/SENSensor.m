
#import "SENSensor.h"
#import "Model.h"

NSInteger const SENSensorSentinelValue = -1;

// unit values
static NSString* const kSENSensorUnitValueCelcius = @"CELCIUS";
static NSString* const kSENSensorUnitValueFahrenheit = @"FAHRENHEIT";
static NSString* const kSENSensorUnitValueMGCM = @"MG_CM";
static NSString* const kSENSensorUnitValuePercent = @"PERCENT";
static NSString* const kSENSensorUnitValueLux = @"LUX";
static NSString* const kSENSensorUnitValueDB = @"DB";
static NSString* const kSENSensorUnitValueVOC = @"VOC";
static NSString* const kSENSensorUnitValuePPM = @"PPM";
static NSString* const kSENSensorUnitValueRatio = @"RATIO";
static NSString* const kSENSensorUnitValueKelvin = @"KELVIN";
static NSString* const kSENSensorUnitValueKPA = @"KPA";

// type values
static NSString* const kSENSensorTypeValueTemp = @"TEMP";
static NSString* const kSENSensorTypeValueAir = @"AIR";
static NSString* const kSENSensorTypeValueHumidity = @"HUMIDITY";
static NSString* const kSENSensorTypeValueVOC = @"VOC";
static NSString* const kSENSensorTypeValueCO2 = @"C02";
static NSString* const kSENSensorTypeValueUV = @"UV";
static NSString* const kSENSensorTypeValueLight = @"LIGHT";
static NSString* const kSENSensorTypeValueLightTemp = @"LIGHT_TEMP";
static NSString* const kSENSensorTypeValueSound = @"SOUND";
static NSString* const kSENSensorTypeValuePressure = @"PRESSURE";
static

SENSensorUnit SensorUnitFromString(NSString* unitString) {
    NSString* unitStringUpper = [unitString uppercaseString];
    if ([unitStringUpper isEqualToString:kSENSensorUnitValueCelcius]) {
        return SENSensorUnitCelcius;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueFahrenheit]) {
        return SENSensorUnitFahrenheit;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueMGCM]) {
        return SENSensorUnitMGCM;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValuePercent]) {
        return SENSensorUnitPercent;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueLux]) {
        return SENSensorUnitLux;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueDB]) {
        return SENSensorUnitDecibel;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueVOC]) {
        return SENSensorUnitVOC;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValuePPM]) {
        return SENSensorUnitPPM;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueRatio]) {
        return SENSensorUnitRatio;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueKelvin]) {
        return SENSensorUnitKelvin;
    } else if ([unitStringUpper isEqualToString:kSENSensorUnitValueKPA]) {
        return  SENSensorUnitKPA;
    } else {
        return SENSensorUnitUnknown;
    }
}

SENSensorType SensorTypeFromString (NSString* typeString) {
    NSString* typeUpper = [typeString uppercaseString];
    if ([typeUpper isEqualToString:kSENSensorTypeValueTemp]) {
        return  SENSensorTypeTemp;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueAir]) {
        return SENSensorTypeAir;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueHumidity]) {
        return SENSensorTypeHumidity;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueVOC]) {
        return SENSensorTypeVOC;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueCO2]) {
        return SENSensorTypeCO2;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueUV]) {
        return SENSensorTypeUV;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueLight]) {
        return SENSensorTypeLight;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueLightTemp]) {
        return SENSensorTypeLightTemp;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValueSound]) {
        return SENSensorTypeSound;
    } else if ([typeUpper isEqualToString:kSENSensorTypeValuePressure]) {
        return SENSensorTypePressure;
    } else {
        return SENSensorTypeUnknown;
    }
}

@implementation SENSensorDataPoint

static NSString* const SENSensorDataPointValueKey = @"value";
static NSString* const SENSensorDataPointDateKey = @"timestamp";
static NSString* const SENSensorDataPointDateOffsetKey = @"offset_millis";

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super init]) {
        NSNumber* value = dict[SENSensorDataPointValueKey];
        _value = [value floatValue] == SENSensorSentinelValue ? nil : value;
        _dateOffset = dict[SENSensorDataPointDateOffsetKey];
        _date = SENDateFromNumber(dict[SENSensorDataPointDateKey]);
    }
    return self;
}

- (NSUInteger)hash {
    return [self.value hash] + [self.date hash] + [self.dateOffset hash];
}

- (BOOL)isEqual:(SENSensorDataPoint*)object {
    if (![object isKindOfClass:[SENSensorDataPoint class]]) {
        return NO;
    }
    
    SENSensorDataPoint* other = object;
    return SENObjectIsEqual([self value], [other value])
        && SENObjectIsEqual([self date], [other date])
        && SENObjectIsEqual([self dateOffset], [other dateOffset]);
}

- (NSString *)description {
    static NSString* const SENSensorDataPointDescriptionFormat =  @"<SENSensorDataPoint @date=%@ @value=%@>";
    return [NSString stringWithFormat:SENSensorDataPointDescriptionFormat, self.date, self.value];
}

@end

@implementation SENSensorScale

static NSString* const kSENSensorScaleAttrMin = @"min";
static NSString* const kSENSensorScaleAttrMax = @"max";
static NSString* const kSENSensorScaleAttrName = @"name";
static NSString* const kSENSensorScaleAttrCondition = @"condition";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _min = SENObjectOfClass(data[kSENSensorScaleAttrMin], [NSNumber class]);
        _max = SENObjectOfClass(data[kSENSensorScaleAttrMax], [NSNumber class]);
        _localizedName = [SENObjectOfClass(data[kSENSensorScaleAttrName], [NSString class]) copy];
        
        NSString* conditionStr = SENObjectOfClass(data[kSENSensorScaleAttrCondition], [NSString class]);
        _condition = SENConditionFromString(conditionStr);
    }
    return self;
}

- (NSUInteger)hash {
    return [[self min] hash] + [[self max] hash] + [[self localizedName] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSensorScale* other = object;
    return SENObjectIsEqual([self localizedName], [other localizedName])
        && SENObjectIsEqual([self min], [other min])
        && SENObjectIsEqual([self max], [other max])
        && [self condition] == [other condition];
}

@end

@implementation SENSensor

static NSString* const kSENSensorAttrName = @"name";
static NSString* const kSENSensorAttrMessage = @"message";
static NSString* const kSENSensorAttrValue = @"value";
static NSString* const kSENSensorAttrUnit = @"unit";
static NSString* const kSENSensorAttrType = @"type";
static NSString* const kSENSensorAttrScale = @"scale";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (self = [super init]) {
        _localizedName = [SENObjectOfClass(data[kSENSensorAttrName], [NSString class]) copy];
        _localizedMessage = [SENObjectOfClass(data[kSENSensorAttrMessage], [NSString class]) copy];
        _value = SENObjectOfClass(data[kSENSensorAttrValue], [NSNumber class]);
        _unit = SensorUnitFromString(SENObjectOfClass(data[kSENSensorAttrUnit], [NSString class]));
        _type = SensorTypeFromString(SENObjectOfClass(data[kSENSensorAttrType], [NSString class]));
        _scales = [self scaleArrayFromObject:SENObjectOfClass(data[kSENSensorAttrScale], [NSArray class])];
    }
    return self;
}

- (NSArray*)scaleArrayFromObject:(NSArray*)scales {
    NSMutableArray* scaleArray = [NSMutableArray arrayWithCapacity:[scales count]];
    NSDictionary* scaleDict = nil;
    for (id scaleObj in scales) {
        scaleDict = SENObjectOfClass(scaleDict, [NSDictionary class]);
        if (scaleDict) {
            [scaleArray addObject:[[SENSensorScale alloc] initWithDictionary:scaleDict]];
        }
    }
    return scaleArray;
}

- (NSUInteger)hash {
    return [[self localizedName] hash]
        + [self type]
        + [[self value] hash]
        + [[self localizedMessage] hash]
        + [self unit]
        + [[self scales] hash];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENSensor* other = object;
    return SENObjectIsEqual([self localizedName], [other localizedName])
        && SENObjectIsEqual([self localizedMessage], [other localizedMessage])
        && SENObjectIsEqual([self value], [other value])
        && SENObjectIsEqual([self scales], [other scales])
        && [self type] == [other type]
        && [self unit] == [other unit];
}

- (NSString*)typeStringValue {
    switch ([self type]) {
        case SENSensorTypeTemp:
            return kSENSensorTypeValueTemp;
        case SENSensorTypeUV:
            return kSENSensorTypeValueUV;
        case SENSensorTypeAir:
            return kSENSensorTypeValueAir;
        case SENSensorTypeCO2:
            return kSENSensorTypeValueCO2;
        case SENSensorTypeVOC:
            return kSENSensorTypeValueVOC;
        case SENSensorTypeLight:
            return kSENSensorTypeValueLight;
        case SENSensorTypeLightTemp:
            return kSENSensorTypeValueLightTemp;
        case SENSensorTypeSound:
            return kSENSensorTypeValueSound;
        case SENSensorTypeHumidity:
            return kSENSensorTypeValueHumidity;
        case SENSensorTypePressure:
            return kSENSensorTypeValuePressure;
        case SENSensorTypeUnknown:
        default:
            return @"";
    }
}

- (NSString*)unitStringValue {
    switch ([self unit]) {
        case SENSensorUnitKPA:
            return kSENSensorUnitValueKPA;
        case SENSensorUnitLux:
            return kSENSensorUnitValueLux;
        case SENSensorUnitPPM:
            return kSENSensorUnitValuePPM;
        case SENSensorUnitVOC:
            return kSENSensorUnitValueVOC;
        case SENSensorUnitMGCM:
            return kSENSensorUnitValueMGCM;
        case SENSensorUnitRatio:
            return kSENSensorUnitValueRatio;
        case SENSensorUnitKelvin:
            return kSENSensorUnitValueKelvin;
        case SENSensorUnitCelcius:
            return kSENSensorUnitValueCelcius;
        case SENSensorUnitFahrenheit:
            return kSENSensorUnitValueFahrenheit;
        case SENSensorUnitDecibel:
            return kSENSensorUnitValueDB;
        case SENSensorUnitPercent:
            return kSENSensorUnitValuePercent;
        case SENSensorUnitUnknown:
        default:
            return @"";
    }
}

@end
