//
//  SENAPIPreferenceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPIPreferences.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENAPIPreferencesSpec)

describe(@"SENAPIPreferencesSpec", ^{
    
    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });
    
    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });
    
    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    describe(@"+updatePreference:completion", ^{

        context(@"returned object is not a dictionary", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[], nil);
                    return nil;
                }];
            });

            it(@"pref is nil", ^{
                __block SENPreference* updatedPref = nil;
                SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
                [SENAPIPreferences updatePreference:pref completion:^(id data, NSError *error) {
                    updatedPref = data;
                }];
                [[updatedPref should] beNil];
            });
        });

        context(@"returned object is valid", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    NSDictionary* body = params[1];
                    SENAPIDataBlock block = [params lastObject];
                    block(body, nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block with data returned", ^{
                __block SENPreference* updatedPref = nil;
                SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
                [SENAPIPreferences updatePreference:pref completion:^(id data, NSError *error) {
                    updatedPref = data;
                }];
                [[updatedPref should] beKindOfClass:[SENPreference class]];
            });
        });

    });
    
});

SPEC_END
