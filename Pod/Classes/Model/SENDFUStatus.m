//
//  SENDFUStatus.m
//  Pods
//
//  Created by Jimmy Lu on 7/18/16.
//
//

#import "SENDFUStatus.h"
#import "Model.h"

static NSString* const SENDFUStatusNotRequired = @"NOT_REQUIRED";
static NSString* const SENDFUStatusRequired = @"REQUIRED";
static NSString* const SENDFUStatusRequestSent = @"RESPONSE_SENT"; // EH?  should be request?
static NSString* const SENDFUStatusInProgress = @"IN_PROGRESS";
static NSString* const SENDFUStatusComplete = @"COMPLETE";
static NSString* const SENDFUStatusError = @"ERROR";

@implementation SENDFUStatus

- (instancetype)initWithResponse:(id)response {
    self = [super init];
    if (self) {
        _currentState = [self enumValueFromResponse:response];
    }
    return self;
}

- (SENDFUState)enumValueFromResponse:(id)response {
    SENDFUState enumValue = SENDFUStateUnknown;
    NSString* state = [SENObjectOfClass(response, [NSString class]) uppercaseString];
    if ([state isEqualToString:SENDFUStatusNotRequired]) {
        enumValue = SENDFUStateNotRequired;
    } else if ([state isEqualToString:SENDFUStatusRequired]) {
        enumValue = SENDFUStateRequired;
    } else if ([state isEqualToString:SENDFUStatusRequestSent]) {
        enumValue = SENDFUStateRequestSent;
    } else if ([state isEqualToString:SENDFUStatusInProgress]) {
        enumValue = SENDFUStateInProgress;
    } else if ([state isEqualToString:SENDFUStatusComplete]) {
        enumValue = SENDFUStateComplete;
    } else if ([state isEqualToString:SENDFUStatusError]) {
        enumValue = SENDFUStateError;
    }
    return enumValue;
}

@end
