//
//  SENAPIAppStatsSpecs.m
//  SenseKit
//
//  Created by Jimmy Lu on 10/2/15.
//  Copyright © 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAPIAppStats.h"
#import "SENAppStats.h"
#import "SENAppUnreadStats.h"

SPEC_BEGIN(SENAPIAppStatsSpec)

describe(@"SENAPIAppStats", ^{
    
    describe(@"+retrieveStats:", ^{
        
        context(@"api returns an error", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"is.hello.test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIAppStats retrieveStats:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should return an api error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
        context(@"api returns stats", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            __block id stats = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"insights_last_viewed" : @1}, nil);
                    return nil;
                }];
                
                [SENAPIAppStats retrieveStats:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                    stats = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
                stats = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an api error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENAppStats object", ^{
                [[stats should] beKindOfClass:[SENAppStats class]];
            });
            
            it(@"stats should have insights last viewed date", ^{
                SENAppStats* appStats = stats;
                [[[appStats lastViewedInsights] should] beKindOfClass:[NSDate class]];
            });
            
        });
        
    });
    
    describe(@"+updateStats:completion", ^{
        
        __block SENAppStats* stats = nil;
        
        beforeEach(^{
            NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate] * 1000;
            stats = [[SENAppStats alloc] initWithDictionary:@{@"insights_last_viewed" : @(now)}];
        });
        
        afterEach(^{
            stats = nil;
        });
        
        context(@"error from api", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PATCH:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"is.hello.test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIAppStats updateStats:stats completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should return an api error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
        context(@"api accepts the updated stats", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PATCH:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, nil);
                    return nil;
                }];
                
                [SENAPIAppStats updateStats:stats completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an api error", ^{
                [[apiError should] beNil];
            });
            
        });
        
    });
    
    describe(@"+retrieveUnread:", ^{
        
        context(@"api returns an error", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"is.hello.test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIAppStats retrieveUnread:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should return an api error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
        context(@"api returns unread stats", ^{
            
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            __block id stats = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"has_unread_insights" : @(YES),
                          @"has_unanswered_questions" : @(YES)}, nil);
                    return nil;
                }];
                
                [SENAPIAppStats retrieveUnread:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                    stats = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                calledBack = NO;
                stats = nil;
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an api error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENAppUnreadStats object", ^{
                [[stats should] beKindOfClass:[SENAppUnreadStats class]];
            });
            
            it(@"stats should have insights last viewed date", ^{
                SENAppUnreadStats* unreadStats = stats;
                [[@([unreadStats hasUnreadInsights]) should] beYes];
                [[@([unreadStats hasUnreadQuestions]) should] beYes];
            });
            
        });
        
    });
    
});

SPEC_END
