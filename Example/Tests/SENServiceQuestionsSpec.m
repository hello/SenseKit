//
//  SENServiceQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENServiceQuestions.h"

SPEC_BEGIN(SENServiceQuestionsSpec)

describe(@"SENServiceQuestionsSpec", ^{
    
    describe(@"+sharedService", ^{
        
        it(@"should be singleton", ^{
            
            SENServiceQuestions* service1 = [SENServiceQuestions sharedService];
            SENServiceQuestions* service2 = [SENServiceQuestions sharedService];
            [[service1 should] beIdenticalTo:service2];
            
            SENServiceQuestions* service3 = [[SENServiceQuestions alloc] init];
            [[service1 should] beIdenticalTo:service3];
            
        });
        
    });
    
    describe(@"-setQuestionsAskedToday", ^{
        
        it(@"should set key in NSUserDefaults to", ^{
            
            SENServiceQuestions* service = [SENServiceQuestions sharedService];
            [service setQuestionsAskedToday];
            
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            id object = [defaults objectForKey:@"kSENServiceQuestionsKeyDate"];
            [[object should] beNonNil];
            
        });
        
    });
    
    describe(@"-listenForNewQuestions:", ^{
        
        it(@"if callback is nil / null, should not return observer", ^{
            
            SENServiceQuestions* service = [SENServiceQuestions sharedService];
            id observer = [service listenForNewQuestions:nil];
            [[observer should] beNil];
            
        });
        
        it(@"if callback is not nil, observer should not be nil either", ^{
            
            SENServiceQuestions* service = [SENServiceQuestions sharedService];
            id observer = [service listenForNewQuestions:^(NSArray *questions) {}];
            [[observer should] beNonNil];
            
        });
        
    });
    
    describe(@"-stopListening:", ^{
        
        it(@"passing nil should still be OK", ^{
            
            SENServiceQuestions* service = [SENServiceQuestions sharedService];
            [[theBlock(^{
                [service stopListening:nil];
            }) shouldNot] raise];
            
        });
        
    });
    
});

SPEC_END