//
//  SENServiceQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAuthorizationService.h>
#import "SENServiceQuestions.h"
#import "SENQuestion.h"

@interface SENServiceQuestions()

@property (nonatomic, strong) NSDate* lastDateAsked;
@property (nonatomic, copy)   NSArray* todaysQuestions;
@property (nonatomic, strong) NSDate* dateQuestionsPulled;

@end

SPEC_BEGIN(SENServiceQuestionsSpec)

describe(@"SENServiceQuestions", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    describe(@"+sharedService", ^{
        
        it(@"should be singleton", ^{
            
            SENServiceQuestions* service1 = [SENServiceQuestions sharedService];
            SENServiceQuestions* service2 = [SENServiceQuestions sharedService];
            [[service1 should] beIdenticalTo:service2];
            
            SENServiceQuestions* service3 = [[SENServiceQuestions alloc] init];
            [[service1 should] beIdenticalTo:service3];
            
        });
        
    });
    
    describe(@"-updateQuestions:", ^{

        __block NSArray* fakeQuestions = nil;
        __block NSError* noError = nil;

        context(@"user is unauthorized", ^{

            SENServiceQuestions* service = [SENServiceQuestions sharedService];

            beforeEach(^{
                [SENAuthorizationService stub:@selector(isAuthorized) andReturn:@(NO)];
                [service updateQuestions:^(NSArray *questions, NSError *error) {
                    fakeQuestions = questions;
                    noError = error;
                }];
            });

            it(@"returns nil", ^{
                [[fakeQuestions should] beNil];
                [[noError should] beNil];
            });
        });
    });
    
});

SPEC_END