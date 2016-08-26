//
//  SENUpgradeStatus.m
//  Pods
//
//  Created by Jimmy Lu on 8/25/16.
//
//

#import "SENUpgradeStatus.h"
#import "Model.h"

static NSString* const kSENUpgradeStatusProp = @"status";
static NSString* const kSENUpgradeStatusEnumOk = @"OK";
static NSString* const kSENUpgradeStatusEnumMultiple = @"ACCOUNT_PAIRED_TO_MULTIPLE_SENSE";
static NSString* const kSENUpgradeStatusEnumAnother = @"NEW_SENSE_PAIRED_TO_DIFFERENT_ACCOUNT";

@implementation SENUpgradeStatus

- (instancetype)initWithDictionary:(NSDictionary *)data {
    self = [super init];
    if (self && data) {
        NSString* status = SENObjectOfClass(data[kSENUpgradeStatusProp], [NSString class]);
        _response = [self responseValueFromString:status];
    }
    return self;
}


- (SENUpgradeResponse)responseValueFromString:(NSString*)response {
    SENUpgradeResponse value = SENUpgradeResponseOk;
    if ([[response uppercaseString] isEqualToString:kSENUpgradeStatusEnumMultiple]) {
        value = SENUpgradeResponseTooManyDevices;
    } else if ([[response uppercaseString] isEqualToString:kSENUpgradeStatusEnumAnother]) {
        value = SENUpgradeResponsePairedToAnother;
    }
    return value;
}

@end
