//
//  SENAPIQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAPIQuestions+Private.h"
#import "SENQuestion.h"
#import "SENAnswer.h"

SPEC_BEGIN(SENAPIQuestionsSpec)

describe(@"SENAPIQuestionsSpec", ^{
    
    describe(@"+questionFromDict:", ^{
        
        NSDictionary* dict = @{@"id" : @(123),
                               @"text" : @"some question",
                               @"type" : @"CHOICE",
                               @"choices" : @[@{@"id" : @(321),
                                                @"text" : @"YUP",
                                                @"question_id" : @(123)}]};
        SENQuestion* question = [SENAPIQuestions questionFromDict:dict];
        [[question should] beNonNil];
        [[[question question] should] equal:[dict objectForKey:@"text"]];
        [[@([[question choices] count]) should] equal:@(1)];
        [[[question questionId] should] equal:[dict objectForKey:@"id"]];
        
    });
    
    describe(@"+answersFromReponseArray:", ^{
        
        NSArray* rawAnswers = @[@{@"id" : @(321),
                                  @"text" : @"YUP",
                                  @"question_id" : @(123)}];
        NSArray* answers = [SENAPIQuestions answersFromReponseArray:rawAnswers];
        [[answers should] beNonNil];
        [[@([answers count]) should] equal:@(1)];
        
        id answer = answers[0];
        [[answer should] beKindOfClass:[SENAnswer class]];
        
    });
    
    describe(@"+questionsFromResponse:", ^{
        
        NSArray* rawQuestions = @[@{@"id" : @(123),
                                    @"text" : @"some question",
                                    @"type" : @"CHOICE",
                                    @"choices" : @[@{@"id" : @(321),
                                                     @"text" : @"YUP",
                                                     @"question_id" : @(123)}]}];
        NSArray* questions = [SENAPIQuestions questionsFromResponse:rawQuestions];
        [[questions should] beNonNil];
        [[@([questions count]) should] equal:@(1)];
        
        id question = questions[0];
        [[question should] beKindOfClass:[SENQuestion class]];
        
    });
    
});

SPEC_END