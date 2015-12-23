//
//  SENAPIQuestionsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/12/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import "SENAPIQuestions.h"
#import "SENQuestion.h"
#import "SENAnswer.h"

@interface SENAPIQuestions (Private)

+ (SENQuestion*)questionFromDict:(NSDictionary*)questionDict;
+ (NSArray*)answersFromReponseArray:(NSArray*)responesArray;
+ (NSArray*)questionsFromResponse:(id)response;
+ (NSDictionary*)dictionaryValueForAnswer:(SENAnswer*)answer;

@end

SPEC_BEGIN(SENAPIQuestionsSpec)

describe(@"SENAPIQuestionsSpec", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    describe(@"+questionFromDict:", ^{

        context(@"response object is valid", ^{
            NSDictionary* dict = @{@"id" : @(123),
                                   @"text" : @"some question",
                                   @"type" : @"CHOICE",
                                   @"choices" : @[@{@"id" : @(321),
                                                    @"text" : @"YUP",
                                                    @"question_id" : @(123)}]};


            it(@"creates a proper SENQuestion object", ^{
                SENQuestion* question = [SENAPIQuestions questionFromDict:dict];
                [[question should] beNonNil];
                [[[question text] should] equal:[dict objectForKey:@"text"]];
                [[@([[question choices] count]) should] equal:@(1)];
                [[[question questionId] should] equal:[dict objectForKey:@"id"]];
            });
        });
    });
    
    describe(@"+answersFromReponseArray:", ^{
        
        it(@"returns an array of SENAnswer objects", ^{
            
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
        
        it(@"generates an array of SENQuestion objects", ^{
            
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
    
    describe(@"+dictionaryValueForAnswer:", ^{
        
        it(@"contains at least id and question id", ^{
            SENAnswer* answer = [[SENAnswer alloc] initWithId:@(0) answer:@"" questionId:@(1)];
            NSDictionary* dict = [SENAPIQuestions dictionaryValueForAnswer:answer];
            NSNumber* answerId = dict[@"id"];
            NSNumber* questionId = dict[@"question_id"];
            [[answerId should] beNonNil];
            [[questionId should] beNonNil];
        });
        
    });
    
    describe(@"+skipQuestion:completion", ^{

        __block NSError* apiError = nil;
        __block SENQuestion* question = nil;

        beforeEach(^{
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });

        afterEach(^{
            question = nil;
            apiError = nil;
        });

        context(@"question is nil", ^{

            beforeEach(^{
                question = nil;
            });

            it(@"calls back with an error of invalid argument", ^{
                [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[@([apiError code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });
        
        context(@"question has no ID", ^{

            beforeEach(^{
                question = [SENQuestion new];
            });

            it(@"calls back with an error of invalid argument", ^{
                [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[@([apiError code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });

        context(@"question has no account ID set", ^{

            beforeEach(^{
                question = [[SENQuestion alloc] initWithId:@(0)
                                         questionAccountId:nil
                                                  question:@""
                                                      type:SENQuestionTypeChoice choices:@[]];
            });

            it(@"calls back with an error of invalid argument", ^{
                [SENAPIQuestions skipQuestion:question completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[@([apiError code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });
    });
    
    describe(@"+sendAnswer:forQuestion:completion:", ^{

        __block SENAnswer* answer = nil;
        __block SENQuestion* question = nil;
        __block NSError* apiErrror = nil;

        beforeEach(^{
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });

        afterEach(^{
            answer = nil;
            question = nil;
            apiErrror = nil;
        });

        context(@"answer is nil", ^{

            beforeEach(^{
                answer = nil;
                question = [[SENQuestion alloc] initWithId:@(0)
                                         questionAccountId:@(1)
                                                  question:@""
                                                      type:SENQuestionTypeChoice choices:@[]];
            });

            it(@"calls back with an invalid argument error", ^{
                [SENAPIQuestions sendAnswer:answer forQuestion:question completion:^(id data, NSError *error) {
                    apiErrror = error;
                }];
                [[@([apiErrror code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });

        context(@"question is nil", ^{

            beforeEach(^{
                answer = [[SENAnswer alloc] initWithId:@(0) answer:@"" questionId:@(0)];
            });

            it(@"calls back with an invalid argument error", ^{
                [SENAPIQuestions sendAnswer:answer forQuestion:question completion:^(id data, NSError *error) {
                    apiErrror = error;
                }];
                [[@([apiErrror code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });

        context(@"question ID is not set", ^{

            beforeEach(^{
                answer = [[SENAnswer alloc] initWithId:@(0) answer:@"" questionId:@(0)];
                question = [[SENQuestion alloc] initWithId:@(0)
                                         questionAccountId:nil
                                                  question:@""
                                                      type:SENQuestionTypeChoice choices:@[]];
            });

            it(@"calls back with an invalid argument error", ^{
                [SENAPIQuestions sendAnswer:answer forQuestion:question completion:^(id data, NSError *error) {
                    apiErrror = error;
                }];
                [[@([apiErrror code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });

        context(@"question ID is nil in answer", ^{

            beforeEach(^{
                answer = [[SENAnswer alloc] initWithId:@(0) answer:@"" questionId:nil];
                question = [[SENQuestion alloc] initWithId:@(0)
                                         questionAccountId:@(1)
                                                  question:@""
                                                      type:SENQuestionTypeChoice choices:@[]];
            });

            it(@"calls back with an invalid argument error", ^{
                [SENAPIQuestions sendAnswer:answer forQuestion:question completion:^(id data, NSError *error) {
                    apiErrror = error;
                }];
                [[@([apiErrror code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });
    });
    
    describe(@"+sendAnswers:forQuestion:completion:", ^{

        __block NSError* apiErrror = nil;
        __block SENQuestion* question = nil;

        context(@"answers is empty list", ^{

            beforeEach(^{
                question = [[SENQuestion alloc] initWithId:@(0)
                                         questionAccountId:@(1)
                                                  question:@""
                                                      type:SENQuestionTypeChoice choices:@[]];
            });

            it(@"calls back with an invalid argument error", ^{
                [SENAPIQuestions sendAnswers:@[] forQuestion:question completion:^(id data, NSError *error) {
                    apiErrror = error;
                }];
                [[@([apiErrror code]) should] equal:@(SENAPIQuestionErrorInvalidParameter)];
            });
        });
    });
    
    describe(@"+getQuestionsFor:completion", ^{
        
        __block NSDate* date = nil;
        __block NSString* dateParam = nil;
        __block NSCalendar* gregorian = nil;
        
        beforeAll(^{
            gregorian = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
            date = [NSDate date];
            
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setCalendar:gregorian];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
            dateParam = [dateFormatter stringFromDate:date];
        });
        
        context(@"buddhist calendar is set", ^{
            
            beforeAll(^{
                NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierBuddhist];
                [NSCalendar stub:@selector(currentCalendar) andReturn:cal];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:cal];
            });
            
            it(@"should send a date parameter in correct gregorian year", ^{
                
                __block NSString* dateString = nil;
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    dateString = [[[params firstObject] pathComponents] lastObject];
                    return nil;
                }];
                [SENAPIQuestions getQuestionsFor:date completion:nil];
                [[dateString should] equal:[NSString stringWithFormat:@"?date=%@", dateParam]];
                
            });
            
        });
        
        context(@"japanese calendar is set", ^{
            
            beforeAll(^{
                NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
                [NSCalendar stub:@selector(currentCalendar) andReturn:cal];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:cal];
            });
            
            it(@"should send a date parameter in correct gregorian year", ^{
                
                __block NSString* dateString = nil;
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    dateString = [[[params firstObject] pathComponents] lastObject];
                    return nil;
                }];
                [SENAPIQuestions getQuestionsFor:date completion:nil];
                [[dateString should] equal:[NSString stringWithFormat:@"?date=%@", dateParam]];
                
            });
            
        });
        
    });

});

SPEC_END