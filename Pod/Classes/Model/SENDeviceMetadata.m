//
//  SENDeviceMetadata.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//

#import "SENDeviceMetadata.h"
#import "Model.h"

static NSString* const SENDeviceMetadataDictPropId = @"id";
static NSString* const SENDeviceMetadataDictPropFW = @"firmware_version";
static NSString* const SENDeviceMetadataDictPropLastUpdated = @"last_updated";
static NSString* const SENDeviceMetadataDictPropActive = @"active";

@interface SENDeviceMetadata()

@property (nonatomic, copy) NSString* uniqueId;
@property (nonatomic, copy) NSString* firmwareVersion;
@property (nonatomic, strong) NSDate* lastSeenDate;
@property (nonatomic, assign, getter=isActive) BOOL active;

@end

@implementation SENDeviceMetadata

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _uniqueId = [SENObjectOfClass(dict[SENDeviceMetadataDictPropId],
                                      [NSString class]) copy];
        _firmwareVersion = [SENObjectOfClass(dict[SENDeviceMetadataDictPropFW],
                                             [NSString class]) copy];
        _lastSeenDate = SENDateFromNumber(dict[SENDeviceMetadataDictPropLastUpdated]);
        
        NSNumber* activeValue = SENObjectOfClass(dict[SENDeviceMetadataDictPropActive],
                                                 [NSNumber class]);
        
        if (activeValue) {
            _active = [activeValue boolValue];
        } else {
            _active = YES; // default to YES
        }
        
    }
    return self;
}

- (NSDictionary*)dictionaryValue {
    return @{SENDeviceMetadataDictPropId : [self uniqueId] ?: @"",
             SENDeviceMetadataDictPropFW : [self firmwareVersion] ?: @"",
             SENDeviceMetadataDictPropLastUpdated : [self lastSeenDate] ?: @0,
             SENDeviceMetadataDictPropActive : @([self isActive])};
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    
    SENDeviceMetadata* other = object;
    
    return [[self uniqueId] isEqualToString:[other uniqueId]];
}

- (NSUInteger)hash {
    return [[self uniqueId] hash];
}

@end
