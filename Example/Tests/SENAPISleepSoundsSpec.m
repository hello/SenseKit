//
//  SENAPISleepSoundsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 3/23/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "API.h"
#import "Model.h"

SPEC_BEGIN(SENAPISleepSoundsSpec)

describe(@"SENAPISleepSounds", ^{
    
    describe(@"+availableSleepSounds:", ^{
        
        context(@"server decided to return an array of sleep sounds", ^{
            
            __block SENSleepSounds* sounds = nil;
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[], nil);
                    return nil;
                }];
                
                [SENAPISleepSounds availableSleepSounds:^(id data, NSError *error) {
                    sounds = data;
                    apiError = error;
                    calledBack = YES;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                sounds = nil;
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should not return any data back", ^{
                [[sounds should] beNil];
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
        context(@"server returned a dictionary for data", ^{
            
            __block SENSleepSounds* sounds = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{}, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds availableSleepSounds:^(id data, NSError *error) {
                    sounds = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                sounds = nil;
                apiError = nil;
            });
            
            it(@"should return a sleep sounds object", ^{
                [[sounds should] beKindOfClass:[SENSleepSounds class]];
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should not contain any data in the sleep sounds object", ^{
                [[[sounds sounds] should] beEmpty];
            });
            
        });
        
        context(@"server returned an error", ^{
            
            __block SENSleepSounds* sounds = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"t"
                                                 code:-1
                                             userInfo:nil]);
                    return nil;
                }];
                
                [SENAPISleepSounds availableSleepSounds:^(id data, NSError *error) {
                    sounds = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                sounds = nil;
                apiError = nil;
            });
            
            it(@"should not return a sleep sounds object", ^{
                [[sounds should] beNil];
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
    });
    
    describe(@"+availableDurations:", ^{
        
        context(@"server decided to return an array of durations", ^{
            
            __block SENSleepSoundDuration* durations = nil;
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[], nil);
                    return nil;
                }];
                
                [SENAPISleepSounds availableDurations:^(id data, NSError *error) {
                    durations = data;
                    apiError = error;
                    calledBack = YES;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                durations = nil;
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should not return any data back", ^{
                [[durations should] beNil];
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
        context(@"server returned a dictionary for data", ^{
            
            __block SENSleepSoundDurations* durations = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{}, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds availableDurations:^(id data, NSError *error) {
                    durations = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                durations = nil;
                apiError = nil;
            });
            
            it(@"should return a sleep sound duration object", ^{
                [[durations should] beKindOfClass:[SENSleepSoundDurations class]];
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should not contain any data in the sleep durations object", ^{
                [[[durations durations] should] beEmpty];
            });
            
        });
        
        context(@"server returned an error", ^{
            
            __block SENSleepSoundDurations* durations = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"t"
                                                 code:-1
                                             userInfo:nil]);
                    return nil;
                }];
                
                [SENAPISleepSounds availableDurations:^(id data, NSError *error) {
                    durations = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                durations = nil;
                apiError = nil;
            });
            
            it(@"should not return a sleep sound durations object", ^{
                [[durations should] beNil];
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
    });
    
    describe(@"+checkRequestStatus:", ^{
        
        context(@"server returned a dictionary for data", ^{
            
            __block SENSleepSoundStatus* status = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"playing" : @(YES),
                          @"sound" : @{},
                          @"duration" : @{}}, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds checkRequestStatus:^(id data, NSError *error) {
                    status = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                status = nil;
                apiError = nil;
            });
            
            it(@"should return a status object", ^{
                [[status should] beKindOfClass:[SENSleepSoundStatus class]];
            });
            
            it(@"should be playing", ^{
                [[@([status isPlaying]) should] beYes];
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"server returned an error", ^{
            
            __block SENSleepSoundStatus* status = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"t"
                                                 code:-1
                                             userInfo:nil]);
                    return nil;
                }];
                
                [SENAPISleepSounds checkRequestStatus:^(id data, NSError *error) {
                    status = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                status = nil;
                apiError = nil;
            });
            
            it(@"should not return a status object", ^{
                [[status should] beNil];
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
    });
    
    describe(@"+checkRequestStatus:", ^{
        
        context(@"execute a play request", ^{
            
            __block SENSleepSoundRequest* request;
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            __block NSString* path = nil;
            
            beforeEach(^{
                request = [SENSleepSoundRequestPlay new];
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    path = [params firstObject];
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds executeRequest:request completion:^(NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                request = nil;
                apiError = nil;
                path = nil;
                calledBack = YES;
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should have called the play api", ^{
                NSString* lastPath = [path lastPathComponent];
                [[lastPath should] equal:@"play"];
            });
            
        });
        
        context(@"execute a stop request", ^{
            
            __block SENSleepSoundRequest* request;
            __block NSError* apiError = nil;
            __block BOOL calledBack = NO;
            __block NSString* path = nil;
            
            beforeEach(^{
                request = [SENSleepSoundRequestStop new];
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    path = [params firstObject];
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds executeRequest:request completion:^(NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                request = nil;
                apiError = nil;
                path = nil;
                calledBack = YES;
            });
            
            it(@"should not return any errors back", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should have called the stop api", ^{
                NSString* lastPath = [path lastPathComponent];
                [[lastPath should] equal:@"stop"];
            });
            
        });
        
    });
    
    describe(@"+sleepSoundsState:", ^{
        
        context(@"server returned an error", ^{
            
            __block NSError* apiError = nil;
            __block SENSleepSoundsState* state = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPISleepSounds sleepSoundsState:^(id data, NSError *error) {
                    state = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                state = nil;
                apiError = nil;
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
            it(@"should not return any state", ^{
                [[state should] beNil];
            });
            
        });
        
        context(@"server an unexpected json object", ^{
            
            __block NSError* apiError = nil;
            __block SENSleepSoundsState* state = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[@{@"availableSounds" : @{}}], nil);
                    return nil;
                }];
                
                [SENAPISleepSounds sleepSoundsState:^(id data, NSError *error) {
                    state = data;
                    apiError = error;
                    calledBack = YES;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                state = nil;
                apiError = nil;
                calledBack = NO;
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should not return any state", ^{
                [[state should] beNil];
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
        context(@"server returned a combined state dictionary", ^{
            
            __block NSError* apiError = nil;
            __block SENSleepSoundsState* state = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"availableSounds" : @{},
                          @"availableDurations" : @{},
                          @"status" : @{}}, nil);
                    return nil;
                }];
                
                [SENAPISleepSounds sleepSoundsState:^(id data, NSError *error) {
                    state = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                state = nil;
                apiError = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a state", ^{
                [[state should] beKindOfClass:[SENSleepSoundsState class]];
                [[[state sounds] should] beNonNil];
                [[[state durations] should] beNonNil];
                [[[state status] should] beNonNil];
            });
            
        });
        
    });
    
});

SPEC_END
