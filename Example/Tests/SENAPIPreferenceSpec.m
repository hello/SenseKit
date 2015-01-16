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
    
    context(@"+updatePreference:completion", ^{
        
        it(@"invokes the completion block with data returned", ^{
            [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                NSDictionary* body = params[1];
                SENAPIDataBlock block = [params lastObject];
                block(body, nil);
                return nil;
            }];
            
            __block SENPreference* updatedPref = nil;
            SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
            [SENAPIPreferences updatePreference:pref completion:^(id data, NSError *error) {
                updatedPref = data;
            }];
            [[expectFutureValue(updatedPref) shouldSoon] beNonNil];
            [[expectFutureValue(updatedPref) shouldSoon] beKindOfClass:[SENPreference class]];
        });
        
        it(@"if returned object is not a dictionary, pref is nil", ^{
            [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(@[], nil);
                return nil;
            }];
            
            __block SENPreference* updatedPref = nil;
            SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
            [SENAPIPreferences updatePreference:pref completion:^(id data, NSError *error) {
                updatedPref = data;
            }];
            [[expectFutureValue(updatedPref) shouldSoon] beNil];
        });
        
    });
    
});

SPEC_END
