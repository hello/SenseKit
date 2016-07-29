//
//  SENAPISpeechResultSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 7/28/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/API.h>

SPEC_BEGIN(SENAPISpeechSpec)

describe(@"SENAPISpeech", ^{
    
    describe(@"+getRecentVoiceCommands:", ^{
        
        context(@"API returns 1 result", ^{
            
            __block NSArray<SENSpeechResult*>* results = nil;
            __block NSError* apiError = nil;
            __block NSString* path = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[@{@"datetime_utc": @(1469743680000),
                            @"text": @"what is the temperature",
                            @"response_text": @"It's currently 71 degrees.",
                            @"command": @"room_temperature",
                            @"result": @"ok"}], nil);
                    path = [params firstObject];
                    return nil;
                }];
                
                [SENAPISpeech getRecentVoiceCommands:^(id data, NSError *error) {
                    results = data;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                results = nil;
                apiError = nil;
            });
            
            it(@"should return an array with 1 item", ^{
                NSInteger count = [results count];
                [[@(count) should] equal:@1];
            });
            
            it(@"should return an item of class SENSpeechResult", ^{
                SENSpeechResult* result = [results firstObject];
                [[result should] beKindOfClass:[SENSpeechResult class]];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have a correct path", ^{
                [[path should] equal:@"v1/speech/onboarding"];
            });
            
        });
        
        context(@"API returned an error", ^{
            
            __block NSArray<SENSpeechResult*>* results = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPISpeech getRecentVoiceCommands:^(id data, NSError *error) {
                    results = data;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                results = nil;
            });
            
            it(@"should not return any results", ^{
                [[results should] beNil];
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
        });
        
    });
    
});

SPEC_END
