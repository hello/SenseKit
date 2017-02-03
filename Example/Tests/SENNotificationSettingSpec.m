//
//  SENNotificationSettingSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 2/3/17.
//  Copyright © 2017 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "Model.h"

SPEC_BEGIN(SENNotificationSettingsSpec)

describe(@"SENNotificationSettings", ^{
    
    describe(@"-initWithDictionary:", ^{
        
        context(@"no name to show", ^{
            
            __block NSDictionary* data = nil;
            __block SENNotificationSetting* setting = nil;
            
            beforeEach(^{
                data = @{@"type" : @"SLEEP_SCORE", @"enabled" : @0};
                setting = [[SENNotificationSetting alloc] initWithDictionary:data];
            });
            
            afterEach(^{
                data = nil;
                setting = nil;
            });
            
            it(@"should not instantiate an object", ^{
                [[setting should] beNil];
            });
            
        });
        
        context(@"brand new type we do not recognize", ^{
            
            __block NSDictionary* data = nil;
            __block SENNotificationSetting* setting = nil;
            
            beforeEach(^{
                data = @{@"type" : @"LOTTERY_WINNER", @"enabled" : @1, @"name" : @"Lottery winner"};
                setting = [[SENNotificationSetting alloc] initWithDictionary:data];
            });
            
            afterEach(^{
                data = nil;
                setting = nil;
            });
            
            it(@"should instantiate an object", ^{
                [[setting should] beNonNil];
            });
            
            it(@"should have an unknown type", ^{
                [[@([setting type]) should] equal:@(SENNotificationTypeUnknown)];
            });
            
            it(@"should have a name equal to the data", ^{
                [[[setting localizedName] should] equal:data[@"name"]];
            });
            
        });
        
        context(@"type that we actually recognize", ^{
            
            __block NSDictionary* data = nil;
            __block SENNotificationSetting* setting = nil;
            
            beforeEach(^{
                data = @{@"type" : @"SLEEP_SCORE", @"enabled" : @1, @"name" : @"Sleep score"};
                setting = [[SENNotificationSetting alloc] initWithDictionary:data];
            });
            
            afterEach(^{
                data = nil;
                setting = nil;
            });
            
            it(@"should instantiate an object", ^{
                [[setting should] beNonNil];
            });
            
            it(@"should have a sleep score type", ^{
                [[@([setting type]) should] equal:@(SENNotificationTypeSleepScore)];
            });
            
            it(@"should have a name equal to the data", ^{
                [[[setting localizedName] should] equal:data[@"name"]];
            });
            
        });
        
    });
    
});

SPEC_END
