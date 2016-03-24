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
    
});

SPEC_END
