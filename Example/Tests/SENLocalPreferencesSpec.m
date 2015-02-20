//
//  SENLocalPreferencesSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 2/19/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENAuthorizationService.h"
#import "Model.h"

SPEC_BEGIN(SENLocalPreferencesSpec)

describe(@"SENLocalPreferencesSpec", ^{
    
    describe(@"+sharedPreferences", ^{
        
        it(@"is singleton", ^{
            SENLocalPreferences* preferences1 = [SENLocalPreferences sharedPreferences];
            SENLocalPreferences* preferences2 = [SENLocalPreferences sharedPreferences];
            [[preferences1 should] beIdenticalTo:preferences2];
        });
        
    });
    
    describe(@"user preferences", ^{
        
        context(@"authorized user", ^{
            
            __block SENLocalPreferences* preferences;
            __block NSString* key = @"healthkit";
            __block NSNumber* enabled = @YES;
            
            beforeEach(^{
                preferences = [SENLocalPreferences sharedPreferences];
                [SENAuthorizationService stub:@selector(accountIdOfAuthorizedUser) andReturn:@"1"];
                [preferences setUserPreference:enabled forKey:key];
            });
            
            afterEach(^{
                [SENAuthorizationService clearStubs];
            });
            
            it(@"preference should be set", ^{
                [[[preferences userPreferenceForKey:key] should] equal:enabled];
            });
            
            it(@"preference should be removed", ^{
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                [preferences setUserPreference:nil forKey:key];
                [[[preferences userPreferenceForKey:key] should] beNil];
            });
            
        });
        
        context(@"not authorized user", ^{
            
            __block NSString* key = @"healthkit";
            __block NSNumber* enabled = @YES;
            
            beforeEach(^{
                [SENAuthorizationService stub:@selector(accountIdOfAuthorizedUser) andReturn:nil];
            });
            
            afterEach(^{
                [SENAuthorizationService clearStubs];
            });
            
            it(@"preference should not be set", ^{
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                BOOL wasSet = [preferences setUserPreference:enabled forKey:key];
                [[@(wasSet) should] beNo];
                [[[preferences userPreferenceForKey:key] should] beNil];
            });
            
        });
        
    });
    
    describe(@"session preferences", ^{
        
        __block SENLocalPreferences* preferences;
        __block NSString* key = @"time";
        __block NSNumber* format = @1;
        
        beforeEach(^{
            preferences = [SENLocalPreferences sharedPreferences];
            [preferences setSessionPreference:format forKey:key];
            [SENAuthorizationService stub:@selector(accountIdOfAuthorizedUser) andReturn:@"2"];
        });
        
        afterEach(^{
            [SENAuthorizationService clearStubs];
        });
        
        it(@"preference should be set", ^{
            [[[preferences sessionPreferenceForKey:key] should] equal:format];
        });
        
        context(@"remove preferences", ^{
            
            it(@"nil will remove preference", ^{
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                [preferences setSessionPreference:nil forKey:key];
                [[[preferences sessionPreferenceForKey:key] should] beNil];
            });
            
            it(@"remove session preferences only", ^{
                NSString* userKey = @"user";
                NSString* persistentKey = @"persistent";
                
                [preferences setUserPreference:@YES forKey:userKey];
                [preferences setPersistentPreference:@YES forKey:persistentKey];
                
                [preferences removeSessionPreferences];
                [[[preferences sessionPreferenceForKey:key] should] beNil];
                
                [[[preferences userPreferenceForKey:userKey] should] beNonNil];
                [[[preferences persistentPreferenceForKey:persistentKey] should] beNonNil];
            });
            
        });
        
    });
    
    describe(@"persistent preferences", ^{
        
        __block SENLocalPreferences* preferences;
        __block NSString* key = @"time";
        __block NSNumber* format = @1;
        
        beforeEach(^{
            preferences = [SENLocalPreferences sharedPreferences];
            [preferences setPersistentPreference:format forKey:key];
        });
        
        it(@"should be set", ^{
            [[[preferences persistentPreferenceForKey:key] should] beNonNil];
        });
        
        it(@"setting nil should remove it", ^{
            [preferences setPersistentPreference:nil forKey:key];
            [[[preferences persistentPreferenceForKey:key] should] beNil];
        });
        
    });
    
});

SPEC_END
