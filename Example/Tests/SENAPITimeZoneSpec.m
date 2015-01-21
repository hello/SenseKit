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

        beforeEach(^{
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });
        
        it(@"should call completion block", ^{
            __block BOOL calledback = NO;
            [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
                calledback = YES;
            }];
            [[@(calledback) should] beYes];
            
        });
        
    });
});

SPEC_END
