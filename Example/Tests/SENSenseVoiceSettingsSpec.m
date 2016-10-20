//
//  SENSenseVoiceSettingsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 10/19/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENSenseVoiceSettingsSpec)

describe(@"ENSenseVoiceSettings", ^{
    
    describe(@"-isEqual:", ^{
        
        it(@"should be equal when all properties match", ^{
            NSDictionary* settings = @{@"muted" : @1,
                                       @"is_primary_user" : @1,
                                       @"volume" : @88};
            SENSenseVoiceSettings* v1 = [[SENSenseVoiceSettings alloc] initWithDictionary:settings];
            SENSenseVoiceSettings* v2 = [[SENSenseVoiceSettings alloc] initWithDictionary:settings];
            NSNumber* equality = @([v1 isEqual:v2]);
            [[equality should] beYes];
        });
        
        it(@"should not be equal when 1 property does not match", ^{
            NSDictionary* settings1 = @{@"muted" : @0,
                                        @"is_primary_user" : @1,
                                        @"volume" : @88};
            NSDictionary* settings2 = @{@"muted" : @1,
                                        @"is_primary_user" : @1,
                                        @"volume" : @88};
            SENSenseVoiceSettings* v1 = [[SENSenseVoiceSettings alloc] initWithDictionary:settings1];
            SENSenseVoiceSettings* v2 = [[SENSenseVoiceSettings alloc] initWithDictionary:settings2];
            NSNumber* equality = @([v1 isEqual:v2]);
            [[equality should] beNo];
        });
        
    });
    
});

SPEC_END
