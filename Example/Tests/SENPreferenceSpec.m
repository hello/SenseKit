//
//  SENPreferenceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SenseKit.h>

SPEC_BEGIN(SENPreferenceSpec)

describe(@"SENPreference", ^{
    
    describe(@"-initWithDictionary", ^{
        __block SENPreference* pref = nil;

        afterEach(^{
            pref = nil;
        });

        context(@"type is not recognized", ^{

            beforeEach(^{
                NSDictionary* dict = @{@"pref" : @"VEGETARIAN", @"enabled" : @(YES)};
                pref = [[SENPreference alloc] initWithDictionary:dict];
            });

            it(@"has a type of unknown", ^{
                [[@([pref type]) should] equal:@(SENPreferenceTypeUnknown)];
            });

            it(@"sets the value", ^{
                [[@([pref isEnabled]) should] equal:@(YES)];
            });
        });

        context(@"dict is nil", ^{

            it(@"is nil", ^{
                pref = [[SENPreference alloc] initWithDictionary:nil];
                [[pref should] beNil];
            });
        });

        context(@"value is missing", ^{
            NSDictionary* dict = @{@"pref" : @"ENHANCED_AUDIO"};

            it(@"is not enabled", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref isEnabled]) should] equal:@(NO)];
            });
        });
        
        context(@"pref represents enhanced audio", ^{
            NSDictionary* dict = @{@"pref" : @"ENHANCED_AUDIO", @"enabled" : @(YES)};

            it(@"has a type of enhanced audio", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypeEnhancedAudio)];
            });
        });

        context(@"pref represents temperature format", ^{
            NSDictionary* dict = @{@"pref" : @"TEMP_CELSIUS", @"enabled" : @(YES)};

            it(@"has a type of enhanced audio", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypeTempCelcius)];
            });
        });

        context(@"pref represents time format", ^{
            NSDictionary* dict = @{@"pref" : @"TIME_TWENTY_FOUR_HOUR", @"enabled" : @(YES)};

            it(@"has a type of enhanced audio", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypeTime24)];
            });
        });

        context(@"pref represents height format", ^{
            NSDictionary* dict = @{@"pref" : @"HEIGHT_METRIC", @"enabled" : @(YES)};

            it(@"has a type of height", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypeHeightMetric)];
            });
        });

        context(@"pref represents weight format", ^{
            NSDictionary* dict = @{@"pref" : @"WEIGHT_METRIC", @"enabled" : @(YES)};

            it(@"has a type of weight", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypeWeightMetric)];
            });
        });

        context(@"pref represents push notifications for alert conditions", ^{
            NSDictionary* dict = @{@"pref" : @"PUSH_ALERT_CONDITIONS", @"enabled" : @(YES)};

            it(@"has a type of push conditions", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypePushConditions)];
            });
        });

        context(@"pref represents push notifications for score", ^{
            NSDictionary* dict = @{@"pref" : @"PUSH_SCORE", @"enabled" : @(YES)};

            it(@"has a type of push score", ^{
                pref = [[SENPreference alloc] initWithDictionary:dict];
                [[@([pref type]) should] equal:@(SENPreferenceTypePushScore)];
            });
        });
    });

    describe(@"-initWithType:enable:", ^{
        
        it(@"instance should be properly initialized", ^{
            
            SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
            [[@([pref type]) should] equal:@(SENPreferenceTypeEnhancedAudio)];
            [[@([pref isEnabled]) should] equal:@(YES)];
            
        });
        
    });
    
    
    describe(@"-dictionaryValue", ^{
        
        it(@"should always return a dictionary", ^{
            
            SENPreference* pref = [[SENPreference alloc] init];
            NSDictionary* dict = [pref dictionaryValue];
            [[dict shouldNot] beNil];
            [[[dict valueForKey:@"pref"] should] equal:@""];
            
        });
        
        it(@"return enhanced audio", ^{
            
            SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
            NSDictionary* dict = [pref dictionaryValue];
            [[[dict valueForKey:@"pref"] should] equal:@"ENHANCED_AUDIO"];
            [[[dict valueForKey:@"enabled"] should] equal:@(YES)];
            
        });
        
    });
    
});

SPEC_END
