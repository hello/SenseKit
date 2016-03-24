//
//  SENSleepSoundsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 3/24/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Model.h"

SPEC_BEGIN(SENSleepSoundsSpec)

describe(@"SENSleepSounds", ^{
    
    describe(@"-initWithDictionary:", ^{
        
        __block SENSleepSounds* sounds = nil;
        __block NSDictionary* rawData = nil;
        
        beforeEach(^{
            rawData = @{@"sounds" : @[@{@"id" : @1,
                                        @"name" : @"wuf",
                                        @"preview_url" : @"https://hello.is"}]};
            sounds = [[SENSleepSounds alloc] initWithDictionary:rawData];
        });
        
        afterEach(^{
            rawData = nil;
            sounds = nil;
        });
        
        it(@"should contain 1 sound", ^{
            [[@([[sounds sounds] count]) should] equal:@1];
        });
        
        it(@"should contain a sound with id, name, and preview url", ^{
            SENSleepSound* sound = [[sounds sounds] firstObject];
            [[[sound identifier] should] equal:@1];
            [[[sound localizedName] should] equal:@"wuf"];
            [[[sound previewURL] should] equal:@"https://hello.is"];
        });
        
    });
    
});

SPEC_END
