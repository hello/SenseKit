//
//  SENAPISupportSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 6/25/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPIClient.h>
#import <SenseKit/SENAPISupport.h>
#import <SenseKit/SENSupportTopic.h>

SPEC_BEGIN(SENAPISupportSpec)

describe(@"SENAPISupportSpec", ^{
    
    describe(@"+supportTopics", ^{
        
        context(@"API returns an error", ^{
        
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"is.hello.is.api"
                                                 code:500
                                             userInfo:nil]);
                    return nil;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should return nil for the list of topics", ^{
                
                __block NSArray* topics = nil;
                __block NSError* apiError = nil;
                [SENAPISupport supportTopics:^(id data, NSError *error) {
                    topics = data;
                    apiError = error;
                }];
                
                [[topics should] beNil];
                [[apiError shouldNot] beNil];
                
            });
            
        });
        
        context(@"API returns an array of topics", ^{
            
            __block NSInteger topicCount = 0;
            __block NSArray* rawResponse = nil;
            beforeEach(^{
                rawResponse = @[@{@"topic" : @"pair_sense", @"display_name" : @"Pair your Sense"},
                                @{@"topic" : @"pair_pill", @"display_name" : @"Pair your Sleep Pill"},
                                @{@"topic" : @"feedback", @"display_name" : @"Feedback"}];
                
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (rawResponse, nil);
                    return nil;
                }];
                topicCount = 3;
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should return an array of SENSupportTopic objects", ^{
                
                __block NSArray* topics = nil;
                __block NSError* apiError = nil;
                [SENAPISupport supportTopics:^(id data, NSError *error) {
                    topics = data;
                    apiError = error;
                }];
                
                [[apiError should] beNil];
                [[@([topics count]) should] equal:@(topicCount)];
                
                BOOL areAllSupportTopicObjects = YES;
                for (id topic in topics) {
                    if (![topic isKindOfClass:[SENSupportTopic class]]) {
                        areAllSupportTopicObjects = NO;
                        break;
                    }
                }
                [[@(areAllSupportTopicObjects) should] equal:@(YES)];
                
            });
            
            it(@"should return objects in the same order as the response", ^{
                
                __block NSArray* topics = nil;
                __block NSError* apiError = nil;
                [SENAPISupport supportTopics:^(id data, NSError *error) {
                    topics = data;
                    apiError = error;
                }];
                
                [[apiError should] beNil];
                [[@([topics count]) should] equal:@(topicCount)];
                
                BOOL areInOrder = YES;
                for (int i = 0; i < [topics count]; i++) {
                    SENSupportTopic* topic = topics[i];
                    NSDictionary* raw = rawResponse[i];
                    if (![[topic topic] isEqualToString:raw[@"topic"]]) {
                        areInOrder = NO;
                        break;
                    }
                }
                [[@(areInOrder) should] equal:@(YES)];
                
            });
            
        });
        
    });
    
});

SPEC_END
