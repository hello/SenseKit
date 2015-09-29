//
//  SENAnalyticsLoggerSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAnalyticsLogger.h"

@interface SENAnalyticsLogger()

- (NSMutableDictionary*)timedEvents;

@end

SPEC_BEGIN(SENAPIAnalyticsLoggerSpec)

describe(@"SENAPIAnalyticsLogger", ^{
    
    __block SENAnalyticsLogger* logger;
    
    beforeEach(^{
        logger = [[SENAnalyticsLogger alloc] init];
    });
    
    describe(@"-endEvent:", ^{
        
        it(@"should remove cached timed event", ^{
            NSString* event = @"Test endEvent:";
            [logger startEvent:event];
            [logger endEvent:event];
            [[[[logger timedEvents] valueForKey:event] should] beNil];
        });
        
    });
    
});

SPEC_END
