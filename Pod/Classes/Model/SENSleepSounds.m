//
//  SENSleepSounds.m
//  Pods
//
//  Created by Jimmy Lu on 3/9/16.
//
//

#import "SENSleepSounds.h"
#import "Model.h"

@interface SENSleepSound()

@property (nonatomic, strong) NSNumber* identifier;
@property (nonatomic, copy) NSString* previewURL;
@property (nonatomic, copy) NSString* localizedName;

@end

@implementation SENSleepSound

static NSString* const SleepSoundParamId = @"id";
static NSString* const SleepSoundParamUrl = @"preview_url";
static NSString* const SleepSoundParamName = @"name";

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        _identifier = SENObjectOfClass(dictionary[SleepSoundParamId], [NSNumber class]);
        _previewURL = [SENObjectOfClass(dictionary[SleepSoundParamUrl], [NSString class]) copy];
        _localizedName = [SENObjectOfClass(dictionary[SleepSoundParamName], [NSString class]) copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENSleepSound class]]) {
        return NO;
    }
    
    SENSleepSound* other = object;
    return ((![self identifier] && ![other identifier]) || [[self identifier] isEqual:[other identifier]])
        && ((![self previewURL] && ![other previewURL]) || [[self previewURL] isEqual:[other previewURL]])
        && ((![self localizedName] && ![other localizedName]) || [[self localizedName] isEqual:[other localizedName]]);
}

- (NSUInteger)hash {
    NSUInteger prime = 7;
    NSUInteger result = prime + [[self identifier] hash];
    result = result * prime + [[self previewURL] hash];
    result = result * prime + [[self localizedName] hash];
    return result;
}

@end

@interface SENSleepSounds()

@property (nonatomic, strong) NSArray<SENSleepSound*>* sounds;
@property (nonatomic, assign) SENSleepSoundsFeatureState state;

@end

@implementation SENSleepSounds

static NSString* const SleepSoundsParamSounds = @"sounds";
static NSString* const SleepSoundsParamState = @"state";
static NSString* const SleepSoundsStateValueOK = @"OK";
static NSString* const SleepSoundsStateValueNoSounds = @"SOUNDS_NOT_DOWNLOADED";
static NSString* const SleepSoundsStateValueFWNeeeded = @"SENSE_UPDATE_REQUIRED";
static NSString* const SleepSoundsStateValueDisabled = @"FEATURE_DISABLED";

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        NSArray* rawSounds = SENObjectOfClass(dictionary[SleepSoundsParamSounds], [NSArray class]);
        _sounds = [self parseRawSoundsObject:rawSounds];
        _state = [self stateFromRawValue:SENObjectOfClass(dictionary[SleepSoundsParamState], [NSString class])];
    }
    return self;
}

- (SENSleepSoundsFeatureState)stateFromRawValue:(NSString*)rawValue {
    NSString* uppercase = [rawValue uppercaseString];
    SENSleepSoundsFeatureState state = SENSleepSoundsFeatureStateDisabled;
    if ([uppercase isEqualToString:SleepSoundsStateValueNoSounds]) {
        state = SENSleepSoundsFeatureStateNoSounds;
    } else if ([uppercase isEqualToString:SleepSoundsStateValueFWNeeeded]){
        state = SENSleepSoundsFeatureStateFWRequired;
    } else if ([uppercase isEqualToString:SleepSoundsStateValueOK]) {
        state = SENSleepSoundsFeatureStateOK;
    }
    return state;
}

- (NSArray<SENSleepSound*>*)parseRawSoundsObject:(NSArray*)rawSounds {
    NSMutableArray<SENSleepSound*>* sleepSounds = [NSMutableArray arrayWithCapacity:[rawSounds count]];
    for (id object in rawSounds) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [sleepSounds addObject:[[SENSleepSound alloc] initWithDictionary:object]];
        }
    }
    return sleepSounds;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[SENSleepSounds class]]) {
        return NO;
    }
    
    SENSleepSounds* other = object;
    return ((![self sounds] && ![other sounds]) || [[self sounds] isEqualToArray:[other sounds]]);
}

- (NSUInteger)hash {
    NSUInteger prime = 5;
    return prime + [[self sounds] hash];
}

@end
