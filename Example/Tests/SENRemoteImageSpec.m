//
//  SENRemoteImageSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/2/15.
//  Copyright © 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENRemoteImageSpec)

describe(@"SENRemoteImage", ^{
    
    describe(@"-initWithDictionary", ^{
        
        __block SENRemoteImage* remoteImage = nil;
        
        beforeEach(^{
            remoteImage = [[SENRemoteImage alloc] initWithDictionary:@{@"phone_1x" : @"https://someimage.url.com/1x",
                                                                       @"phone_2x" : @"https://someimage.url.com/2x",
                                                                       @"phone_3x" : @"https://someimage.url.com/3x"}];
        });
        
        afterEach(^{
            remoteImage = nil;
        });
        
        it(@"should contain 3 uris", ^{
            [[[remoteImage normalUri] should] beNonNil];
            [[[remoteImage doubleScaleUri] should] beNonNil];
            [[[remoteImage tripeScaleUri] should] beNonNil];
        });
        
    });
    
});

SPEC_END
