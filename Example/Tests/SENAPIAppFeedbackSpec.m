//
//  SENAPIAppFeedbackSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 8/26/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import "SENAPIAppFeedback.h"

SPEC_BEGIN(SENAPIAppFeedbackSpec)

describe(@"SENAPIAppFeedback", ^{
    
    describe(@"+sendAppFeedback:reviewedApp:completion", ^{
        
        context(@"request is sent successfully", ^{
           
            __block id likeValue = nil;
            __block id reviewValue = nil;
            __block BOOL calledBack = NO;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(id response, NSError* error) = [params lastObject];
                    NSDictionary* properties = params[1];
                    likeValue = properties[@"like"];
                    reviewValue = properties[@"review"];
                    cb (nil, nil);
                    return nil;
                }];
                
                [SENAPIAppFeedback sendAppFeedback:SENAppReviewFeedbackLikeIt reviewedApp:YES completion:^(NSError *apiError) {
                    calledBack = YES;
                    error = apiError;
                }];
            });
            
            afterEach(^{
                likeValue = nil;
                reviewValue = nil;
                error = nil;
                calledBack = NO;
                [SENAPIClient clearStubs];
            });
            
            it(@"should have sent YES as the like property in the form of a string", ^{
                [[likeValue should] beKindOfClass:[NSString class]];
                [[likeValue should] equal:@"YES"];
            });
            
            it(@"should have sent YES as the review property in the form of a number", ^{
                [[reviewValue should] beKindOfClass:[NSNumber class]];
                [[reviewValue should] beYes];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not have returned an error", ^{
                [[error should] beNil];
            });
            
        });
        
        context(@"request failed", ^{

            __block BOOL calledBack = NO;
            __block NSError* error = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    void(^cb)(id response, NSError* error) = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"is.hello.error" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIAppFeedback sendAppFeedback:SENAppReviewFeedbackLikeIt reviewedApp:YES completion:^(NSError *apiError) {
                    calledBack = YES;
                    error = apiError;
                }];
            });
            
            afterEach(^{
                error = nil;
                calledBack = NO;
                [SENAPIClient clearStubs];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should have returned an error", ^{
                [[error should] beNonNil];
            });
            
        });
        
    });
    
});

SPEC_END
