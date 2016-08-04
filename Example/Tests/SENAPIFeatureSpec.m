//
//  SENAPIFeatureSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 8/4/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/API.h>

SPEC_BEGIN(SENAPIFeatureSpec)

describe(@"SENAPIFeature", ^{
    
    describe(@"+getFeatures:", ^{
        
        context(@"API returned an error", ^{
            
            __block NSError* apiError = nil;
            __block SENFeatures* features = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                [SENAPIFeature getFeatures:^(id data, NSError *error) {
                    apiError = error;
                    features = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                features = nil;
            });
            
            it(@"should return an error", ^{
                [[apiError should] beNonNil];
            });
            
            it(@"should not return a features object", ^{
                [[features should] beNil];
            });
            
        });
        
        context(@"API returned a features map", ^{
            
            __block NSError* apiError = nil;
            __block SENFeatures* features = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"VOICE" : @YES}, nil);
                    return nil;
                }];
                
                [SENAPIFeature getFeatures:^(id data, NSError *error) {
                    apiError = error;
                    features = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                features = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a features object", ^{
                [[features should] beKindOfClass:[SENFeatures class]];
            });
            
            it(@"should return voice as enabled", ^{
                [[@([features hasVoice]) should] beYes];
            });
        });
        
    });
    
});

SPEC_END