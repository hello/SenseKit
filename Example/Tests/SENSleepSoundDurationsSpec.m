//
//  SENSleepSoundDurationsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENSleepSoundDurationsSpec)

describe(@"SENSleepSoundDurations", ^{
    
    describe(@"-initWithDictionary:", ^{
        
        __block SENSleepSoundDurations* durations = nil;
        __block NSDictionary* rawData = nil;
        
        beforeEach(^{
            rawData = @{@"durations" : @[@{@"id" : @1,
                                           @"name" : @"long time"}]};
            durations = [[SENSleepSoundDurations alloc] initWithDictionary:rawData];
        });
        
        afterEach(^{
            rawData = nil;
            durations = nil;
        });
        
        it(@"should contain 1 duration", ^{
            [[@([[durations durations] count]) should] equal:@1];
        });
        
        it(@"should contain a sound with id, name, and preview url", ^{
            SENSleepSoundDuration* duration = [[durations durations] firstObject];
            [[[duration identifier] should] equal:@1];
            [[[duration localizedName] should] equal:@"long time"];
        });
        
    });
    
});

SPEC_END
