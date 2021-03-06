//
//  SENAPIQuestions.m
//  Pods
//
//  Created by Jimmy Lu on 9/10/14.
//
//
#import "AFHTTPSessionManager.h"
#import "SENAPIQuestions.h"
#import "Model.h"

static NSDateFormatter* dateFormatter;

static NSString* const kSENAPIQuestionErrorDomain = @"is.hello.api.question";

static NSString* const kSENAPIQuestionsPath = @"v1/questions";
static NSString* const kSENAPIQuestionPropId = @"id";
static NSString* const kSENAPIQuestionPropQuestionAccountId = @"account_question_id";
static NSString* const kSENAPIQuestionPropQuestionId = @"question_id";
static NSString* const kSENAPIQuestionPropText = @"text";
static NSString* const kSENAPIQuestionPropType = @"type";
static NSString* const kSENAPIQuestionPropChoices = @"choices";
static NSString* const kSENAPIQuestionTypeChoice = @"CHOICE";
static NSString* const kSENAPIQuestionTypeCheckbox = @"CHECKBOX";

@implementation SENAPIQuestions

+ (NSError*)invalidParameterError {
    return [NSError errorWithDomain:kSENAPIQuestionErrorDomain
                               code:SENAPIQuestionErrorInvalidParameter
                           userInfo:nil];
}

#pragma mark - GET QUESTIONS

+ (SENQuestionType)typeFromString:(NSString*)typeString {
    SENQuestionType type = SENQuestionTypeChoice;
    NSString* upperType = [typeString uppercaseString];
    if ([upperType isEqualToString:kSENAPIQuestionTypeChoice]) {
        type = SENQuestionTypeChoice;
    } else if ([upperType isEqualToString:kSENAPIQuestionTypeCheckbox]) {
        type = SENQuestionTypeCheckbox;
    }
    return type;
}

+ (NSArray*)answersFromReponseArray:(NSArray*)responesArray {
    NSMutableArray* answers = [NSMutableArray arrayWithCapacity:[responesArray count]];
    for (id answerObject in responesArray) {
        NSDictionary* answerDict = SENObjectOfClass(answerObject, [NSDictionary class]);
        NSNumber* ansId = SENObjectOfClass([answerDict objectForKey:kSENAPIQuestionPropId], [NSNumber class]);
        NSNumber* queId = SENObjectOfClass([answerDict objectForKey:kSENAPIQuestionPropQuestionId], [NSNumber class]);
        NSString* text = SENObjectOfClass([answerDict objectForKey:kSENAPIQuestionPropText], [NSString class]);
        if (ansId != nil && queId != nil && text != nil) {
            [answers addObject:[[SENAnswer alloc] initWithId:ansId answer:text questionId:queId]];
        }
    }
    return answers;
}


+ (SENQuestion*)questionFromDict:(NSDictionary*)questionDict {
    NSNumber* qId = SENObjectOfClass([questionDict objectForKey:kSENAPIQuestionPropId], [NSNumber class]);
    NSNumber* qAId = SENObjectOfClass([questionDict objectForKey:kSENAPIQuestionPropQuestionAccountId], [NSNumber class]);
    NSString* text = SENObjectOfClass([questionDict objectForKey:kSENAPIQuestionPropText], [NSString class]);
    NSString* type = SENObjectOfClass([questionDict objectForKey:kSENAPIQuestionPropType], [NSString class]);
    NSArray* choiceObjs = SENObjectOfClass([questionDict objectForKey:kSENAPIQuestionPropChoices], [NSArray class]);
    
    if (qId == nil || [text length] == 0) {
        return nil;
    }
    
    return [[SENQuestion alloc] initWithId:qId
                         questionAccountId:qAId
                                  question:text
                                      type:[self typeFromString:type]
                                   choices:[self answersFromReponseArray:choiceObjs]];
}

+ (NSArray*)questionsFromResponse:(id)response {
    NSMutableArray* questions = [NSMutableArray array];
    if ([response isKindOfClass:[NSArray class]]) {
        for (id responseObj in response) {
            if ([responseObj isKindOfClass:[NSDictionary class]]) {
                SENQuestion* question = [self questionFromDict:responseObj];
                if (question) {
                    [questions addObject:question];
                }
            }
        }
    }
    return questions;
}

+ (void)getQuestionsFor:(NSDate*)date completion:(SENAPIDataBlock)completion {
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setCalendar:[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
        [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    });
    
    NSString* dateParam = @"";
    if (date) {
        NSString* formattedDate = [dateFormatter stringFromDate:date];
        dateParam = [NSString stringWithFormat:@"?date=%@", formattedDate];
    }
    
    NSString* path = [NSString stringWithFormat:@"%@/%@", kSENAPIQuestionsPath, dateParam];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        if (completion) {
            if (error == nil) {
                completion ([self questionsFromResponse:data], error);
            } else {
                completion (nil, error);
            }
        }
    }];
}

#pragma mark - SENDING RESPONSES

+ (NSArray*)arrayValueForAnswers:(NSArray*)answers {
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:[answers count]];
    for (id answerObject in answers) {
        if ([answerObject isKindOfClass:[SENAnswer class]]) {
            [array addObject:[self dictionaryValueForAnswer:(SENAnswer*)answerObject]];
        }
    }
    return array;
}

+ (NSDictionary*)dictionaryValueForAnswer:(SENAnswer*)answer {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    [dict setValue:[answer answerId] forKey:kSENAPIQuestionPropId];
    [dict setValue:[answer answer] forKey:kSENAPIQuestionPropText];
    [dict setValue:[answer questionId] forKey:kSENAPIQuestionPropQuestionId];
    return dict;
}

+ (void)sendAnswers:(NSArray*)answers forQuestion:(SENQuestion*)question completion:(SENAPIDataBlock)completion {
    if ([answers count] == 0 || question == nil || [question questionAccountId] == nil) {
        if (completion) completion (nil, [self invalidParameterError]);
        return;
    }
    
    NSString* path = [kSENAPIQuestionsPath stringByAppendingFormat:@"/save/?account_question_id=%ld",
                        [[question questionAccountId] longValue]];
    
    NSArray* body = [self arrayValueForAnswers:answers];
    [SENAPIClient POST:path parameters:body completion:completion];
}

+ (void)sendAnswer:(SENAnswer*)answer forQuestion:(SENQuestion*)question completion:(SENAPIDataBlock)completion {
    if (answer == nil || [answer questionId] == nil) { // the rest will be handled by sendAnswers:forQuestion:completion
        if (completion) completion (nil, [self invalidParameterError]);
        return;
    }
    return [self sendAnswers:@[answer] forQuestion:question completion:completion];
}

#pragma mark - SKIPPING QUESTIONS

+ (void)skipQuestion:(SENQuestion*)question completion:(SENAPIDataBlock)completion {
    if (question == nil || [question questionId] == nil || [question questionAccountId] == nil) {
        if (completion) completion (nil, [self invalidParameterError]);
        return;
    }
    
    NSString* path = [kSENAPIQuestionsPath stringByAppendingFormat:@"/skip?id=%ld&account_question_id=%ld",
                        [[question questionId] longValue],
                        [[question questionAccountId] longValue]];
    [SENAPIClient PUT:path parameters:nil completion:completion];
}

@end