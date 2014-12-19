//
//  SENServiceQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENServiceQuestions.h"
#import "SENQuestion.h"

@interface SENServiceQuestions()

@property (nonatomic, strong) NSDate* lastDateAsked;
@property (nonatomic, copy)   NSArray* todaysQuestions;
@property (nonatomic, strong) NSDate* dateQuestionsPulled;

@end

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
    
    describe(@"-updateQuestions:", ^{
        
        it(@"should return nil for questions if already asked", ^{
            
            SENServiceQuestions* service = [SENServiceQuestions sharedService];
            [service setQuestionsAskedToday];
            
            __block NSArray* fakeQuestions = nil;
            __block NSError* noError = nil;
            [service updateQuestions:^(NSArray *questions, NSError *error) {
                fakeQuestions = questions;
                noError = error;
            }];
            
            [[expectFutureValue(fakeQuestions) shouldEventually] beNil];
            [[expectFutureValue(noError) shouldEventually] beNil];
            
        });
        
    });
    
});

SPEC_END