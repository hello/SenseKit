//
//  SENDevices.m
//  Pods
//
//  Created by Jimmy Lu on 10/21/15.
//
//
#import "SENPairedDevices.h"
#import "Model.h"

static NSString* const HEMDevicesDictPropSenses = @"senses";
static NSString* const HEMDevicesDictPropPills = @"pills";

@interface SENPairedDevices()

@property (nonatomic, strong) NSArray<SENSenseMetadata*> *senses;
@property (nonatomic, strong) NSArray<SENPillMetadata*> *pills;

@end

@implementation SENPairedDevices

- (instancetype)initWithDictionary:(NSDictionary*)dict {
    self = [super init];
    if (self) {
        _senses = [self senseArrayFromValue:dict[HEMDevicesDictPropSenses]];
        _pills = [self pillArrayFromValue:dict[HEMDevicesDictPropPills]];
    }
    return self;
}

- (NSArray<SENSenseMetadata *>*)senseArrayFromValue:(NSArray*)value {
    NSMutableArray<SENSenseMetadata*>* senses = [NSMutableArray new];
    
    for (id object in value) {
        NSDictionary* dict = SENObjectOfClass(object, [NSDictionary class]);
        [senses addObject:[[SENSenseMetadata alloc] initWithDictionary:dict]];
    }
                           
    return senses;
}

- (NSArray<SENPillMetadata *>*)pillArrayFromValue:(NSArray*)value {
    NSMutableArray<SENPillMetadata*>* pills = [NSMutableArray new];
    
    for (id object in value) {
        NSDictionary* dict = SENObjectOfClass(object, [NSDictionary class]);
        [pills addObject:[[SENPillMetadata alloc] initWithDictionary:dict]];
    }
    
    return pills;
}

- (SENSenseMetadata*)activeSenseMetadata {
    SENSenseMetadata* activeSense = nil;
    for (SENSenseMetadata* sense in [self senses]) {
        if ([sense isActive]) {
            activeSense = sense;
            break;
        }
    }
    return activeSense;
}

- (SENPillMetadata*)activePillMetadata {
    SENPillMetadata* activePill = nil;
    for (SENPillMetadata* pill in [self pills]) {
        if ([pill isActive]) {
            activePill = pill;
            break;
        }
    }
    return activePill;
}

- (BOOL)hasPairedSense {
    return [[[self activeSenseMetadata] uniqueId] length] > 0;
}

- (BOOL)hasPairedPill {
    return [[[self activePillMetadata] uniqueId] length] > 0;
}

- (void)removePill:(SENPillMetadata*)pillMetadata {
    NSMutableArray<SENPillMetadata*>* mutablePills = [[self pills] mutableCopy];
    [mutablePills removeObject:pillMetadata];
    [self setPills:mutablePills];
}

- (void)removeSense:(SENSenseMetadata*)senseMetadata {
    NSMutableArray<SENSenseMetadata*>* mutableSenses = [[self senses] mutableCopy];
    [mutableSenses removeObject:senseMetadata];
    [self setSenses:mutableSenses];
}

@end
