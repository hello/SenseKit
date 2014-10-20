//
//  SENAPIQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>

#import "SENAPIQuestions.h"
#import "SENQuestion.h"
#import "SENAnswer.h"

@interface SENAPIQuestions (Private)

+ (SENQuestion*)questionFromDict:(NSDictionary*)questionDict;
+ (NSArray*)answersFromReponseArray:(NSArray*)responesArray;
+ (NSArray*)questionsFromResponse:(id)response;

@end

SPEC_BEGIN(SENAPIQuestionsSpec)

describe(@"SENAPIQuestionsSpec", ^{
    
    describe(@"+questionFromDict:", ^{
        
        it(@"proper question dict should create a proper SENQuestion object", ^{
            
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
        
    });
    
    describe(@"+answersFromReponseArray:", ^{
        
        it(@"an array of choices from the server should return an array of SENAnswer objects", ^{
            
            NSArray* rawAnswers = @[@{@"id" : @(321),
                                      @"text" : @"YUP",
                                      @"question_id" : @(123)}];
            NSArray* answers = [SENAPIQuestions answersFromReponseArray:rawAnswers];
            [[answers should] beNonNil];
            [[@([answers count]) should] equal:@(1)];
            
            id answer = answers[0];
            [[answer should] beKindOfClass:[SENAnswer class]];
            
        });
        
    });
    
    describe(@"+questionsFromResponse:", ^{
        
        it(@"an array of questions from server should generate an array of SENQuestion objects", ^{
            
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
    
    describe(@"+skipQuestion:completion", ^{
        
        it(@"should callback with an error of invalid argument with no question passed", ^{
            __block NSError* apiErrror = nil;
            [SENAPIQuestions skipQuestion:nil completion:^(id data, NSError *error) {
                apiErrror = error;
            }];
            [[expectFutureValue(@([apiErrror code])) shouldEventually] equal:@(SENAPIQuestionErrorInvalidParameter)];
        });
        
        it(@"should callback with an error of invalid argument with no question id set", ^{
            __block NSError* apiErrror = nil;
            [SENAPIQuestions skipQuestion:[[SENQuestion alloc] init] completion:^(id data, NSError *error) {
                apiErrror = error;
            }];
            [[expectFutureValue(@([apiErrror code])) shouldEventually] equal:@(SENAPIQuestionErrorInvalidParameter)];
        });

    });

});

SPEC_END