//
//  SENAPITimeZoneSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 10/29/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPITimeZone.h>

SPEC_BEGIN(SENAPITimeZoneSpec)

describe(@"SENAPITimeZone", ^{
    
    describe(@"+ setCurrentTimeZone", ^{
        
        beforeAll(^{
            [[LSNocilla sharedInstance] start];
        });
        
        afterAll(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        it(@"should call completion block", ^{
            
            __block BOOL calledback = NO;
            stubRequest(@"POST", @".*".regex).andReturn(200).withBody(@"{}").withHeader(@"Content-Type", @"application/json");
            [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
                calledback = YES;
            }];
            [[expectFutureValue(@(calledback)) shouldEventually] equal:@(YES)];
            
        });
        
    });
});

SPEC_END
