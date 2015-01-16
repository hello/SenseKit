//
//  SENPreferenceSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 1/15/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

SPEC_BEGIN(SENPreferenceSpec)

describe(@"SENPreference", ^{
    
    describe(@"-initWithDictionary", ^{
        
        it(@"should have a type of unknown if not recognized", ^{
            
            NSDictionary* dict = @{@"pref" : @"VEGETARIAN", @"enabled" : @(YES)};
            SENPreference* pref = [[SENPreference alloc] initWithDictionary:dict];
            [[@([pref type]) should] equal:@(SENPreferenceTypeUnknown)];
            [[@([pref enabled]) should] equal:@(YES)];
            
        });
        
        it(@"instance should be nil if dictionary is nil", ^{
            
            SENPreference* pref = [[SENPreference alloc] initWithDictionary:nil];
            [[pref should] beNil];
            
        });
        
        it(@"instance should be properly initialized with right dictionary", ^{
            
            NSDictionary* dict = @{@"pref" : @"ENHANCED_AUDIO", @"enabled" : @(YES)};
            SENPreference* pref = [[SENPreference alloc] initWithDictionary:dict];
            [[@([pref type]) should] equal:@(SENPreferenceTypeEnhancedAudio)];
            
        });
        
        it(@"instance should be properly initialized even with missing properties", ^{
            
            NSDictionary* dict = @{@"pref" : @"ENHANCED_AUDIO"};
            SENPreference* pref = [[SENPreference alloc] initWithDictionary:dict];
            [[@([pref type]) should] equal:@(SENPreferenceTypeEnhancedAudio)];
            [[@([pref enabled]) should] equal:@(NO)];
            
        });
        
    });
    
    describe(@"-initWithType:enable:", ^{
        
        it(@"instance should be properly initialized", ^{
            
            SENPreference* pref = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
            [[@([pref type]) should] equal:@(SENPreferenceTypeEnhancedAudio)];
            [[@([pref enabled]) should] equal:@(YES)];
            
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
