//
//  SENPillMetadataSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/1/15.
//  Copyright © 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENPillMetadata.h>

@interface SENPillMetadata()

- (SENPillState)stateFromValue:(NSString*)stateValue;

@end

SPEC_BEGIN(SENPillMetadataSpec)

describe(@"SENPillMetadata", ^{
    
    describe(@"-stateFromValue", ^{
        
        it(@"should return low battery state if LOW_BATTERY", ^{
            SENPillMetadata* pillMeta = [SENPillMetadata new];
            SENPillState state = [pillMeta stateFromValue:@"LOW_BATTERY"];
            [[@(state) should] equal:@(SENPillStateLowBattery)];
        });
        
        it(@"should return normal state if NORMAL", ^{
            SENPillMetadata* pillMeta = [SENPillMetadata new];
            SENPillState state = [pillMeta stateFromValue:@"NORMAL"];
            [[@(state) should] equal:@(SENPillStateNormal)];
        });
        
    });
    
});

SPEC_END
