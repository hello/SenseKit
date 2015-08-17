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
    
    describe(@"+updatePreferencesWithCompletion", ^{

        context(@"returned object is not a dictionary", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[], nil);
                    return nil;
                }];
            });

            it(@"pref is nil", ^{
                __block NSDictionary* updatedPrefs = nil;
                [SENAPIPreferences updatePreferencesWithCompletion:^(id data, NSError *error) {
                    updatedPrefs = data;
                }];
                [[updatedPrefs should] beNil];
            });
        });

        context(@"returned object is valid", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    NSDictionary* body = @{@"HEIGHT_METRIC":@1};
                    SENAPIDataBlock block = [params lastObject];
                    block(body, nil);
                    return nil;
                }];
            });

            it(@"invokes the completion block with data returned", ^{
                __block NSDictionary* updatedPrefs = nil;
                [SENAPIPreferences updatePreferencesWithCompletion:^(id data, NSError *error) {
                    updatedPrefs = data;
                }];
                [[updatedPrefs should] beKindOfClass:[NSDictionary class]];
                SENPreference *pref = updatedPrefs[@(SENPreferenceTypeHeightMetric)];
                [[pref should] beKindOfClass:[SENPreference class]];
                [[@([pref isEnabled]) should] beYes];
            });
        });

    });
    
    describe(@"+getPreferences:", ^{
        
        beforeEach(^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                NSDictionary* body = @{
                    @"ENHANCED_AUDIO" : @(true),
                    @"HEIGHT_METRIC" : @(true),
                    @"FAKE_PREFERENCE" : @(true)
                };
                SENAPIDataBlock block = [params lastObject];
                block(body, nil);
                return nil;
            }];
        });
        
        it(@"response is a dictionary", ^{
            
            __block id response = nil;
            [SENAPIPreferences getPreferences:^(id data, NSError *error) {
                response = data;
            }];
            [[response should] beKindOfClass:[NSDictionary class]];
            
        });
        
        it(@"fake preference is not translated in to a SENPreference and returned", ^{
            
            __block NSDictionary* preferences = nil;
            [SENAPIPreferences getPreferences:^(id data, NSError *error) {
                preferences = data;
            }];
            [[@([preferences count]) should] equal:@(2)];
            [[[preferences objectForKey:@(SENPreferenceTypeEnhancedAudio)] should] beKindOfClass:[SENPreference class]];
            [[[preferences objectForKey:@(SENPreferenceTypeHeightMetric)] should] beKindOfClass:[SENPreference class]];
            
        });
        
    });
    
});

SPEC_END
