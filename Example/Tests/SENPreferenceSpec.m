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
    
    describe(@"-initWithType:", ^{
        
        __block SENPreference *timePreference = nil;
        __block SENPreference *tempPreference = nil;
        __block SENPreference *weightPreference = nil;
        __block SENPreference *heightPreference = nil;
        __block SENPreference *audioPreference = nil;
        __block SENPreference *pushConditionsPreference = nil;
        __block SENPreference *pushScorePreference = nil;
        
        context(@"US locale", ^{
            
            beforeAll(^{
                NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
                [NSLocale stub:@selector(currentLocale) andReturn:locale];
                
                timePreference = [[SENPreference alloc] initWithType:SENPreferenceTypeTime24];
                tempPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeTempCelcius];
                weightPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeWeightMetric];
                heightPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeHeightMetric];
                audioPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio];
                pushConditionsPreference = [[SENPreference alloc] initWithType:SENPreferenceTypePushConditions];
                pushScorePreference = [[SENPreference alloc] initWithType:SENPreferenceTypePushScore];
            });
            
            afterAll(^{
                [NSLocale clearStubs];
            });
                                  
            it(@"time preference is 12hr, not enabled for military time", ^{
                [[@([timePreference isEnabled]) should] beNo];
            });
            
            it(@"temp preference is not celcius", ^{
                [[@([tempPreference isEnabled]) should] beNo];
            });
            
            it(@"weight preference is not using metric system", ^{
                [[@([weightPreference isEnabled]) should] beNo];
            });
            
            it(@"height preference is not using metric system", ^{
                [[@([heightPreference isEnabled]) should] beNo];
            });
            
            it(@"audio preference is disabled", ^{
                [[@([audioPreference isEnabled]) should] beNo];
            });
            
            it(@"push condition preference is enabled", ^{
                [[@([pushConditionsPreference isEnabled]) should] beYes];
            });
            
            it(@"push score preference is enabled", ^{
                [[@([pushScorePreference isEnabled]) should] beYes];
            });
        });
        
        context(@"German locale, non US", ^{
            
            beforeAll(^{
                NSLocale* locale = [NSLocale localeWithLocaleIdentifier:@"de_EU"];
                [NSLocale stub:@selector(currentLocale) andReturn:locale];
                
                timePreference = [[SENPreference alloc] initWithType:SENPreferenceTypeTime24];
                tempPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeTempCelcius];
                weightPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeWeightMetric];
                heightPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeHeightMetric];
                audioPreference = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio];
                pushConditionsPreference = [[SENPreference alloc] initWithType:SENPreferenceTypePushConditions];
                pushScorePreference = [[SENPreference alloc] initWithType:SENPreferenceTypePushScore];
            });
            
            afterAll(^{
                [NSLocale clearStubs];
            });
            
            it(@"time preference is 24hr", ^{
                [[@([timePreference isEnabled]) should] beYes];
            });
            
            it(@"temp preference is celcius", ^{
                [[@([tempPreference isEnabled]) should] beYes];
            });
            
            it(@"weight preference is using metric system", ^{
                [[@([weightPreference isEnabled]) should] beYes];
            });
            
            it(@"height preference is using metric system", ^{
                [[@([heightPreference isEnabled]) should] beYes];
            });
            
            it(@"audio preference is disabled", ^{
                [[@([audioPreference isEnabled]) should] beNo];
            });
            
            it(@"push condition preference is enabled", ^{
                [[@([pushConditionsPreference isEnabled]) should] beYes];
            });
            
            it(@"push score preference is enabled", ^{
                [[@([pushScorePreference isEnabled]) should] beYes];
            });
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
