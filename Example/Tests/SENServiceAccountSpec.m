//
//  SENServiceAccountSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 12/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import "SENServiceAccount.h"
#import "SENAPIAccount.h"
#import "SENAPIPreferences.h"
#import "SENPreference.h"
#import "SENAuthorizationService.h"
#import "SENPreference.h"

@interface SENServiceAccount()

- (void)setPreferences:(NSDictionary*)preferences;

@end

SPEC_BEGIN(SENServiceAccountSpec)

describe(@"SENServiceAccountSpec", ^{
    
    describe(@"+sharedService", ^{
        
        it(@"should be singleton", ^{
            
            SENServiceAccount* service1 = [SENServiceAccount sharedService];
            SENServiceAccount* service2 = [SENServiceAccount sharedService];
            [[service1 should] beIdenticalTo:service2];
            
            SENServiceAccount* service3 = [[SENServiceAccount alloc] init];
            [[service1 should] beIdenticalTo:service3];
            
        });
        
    });
    
    describe(@"-changePassword:toNewPassword:completion", ^{
        
        it(@"should return error if passwords are not provided", ^{
            
            __block NSError* invalidError = nil;
            [[SENServiceAccount sharedService] changePassword:nil toNewPassword:@"test123" forUsername:@"test" completion:^(NSError *error) {
                invalidError = error;
            }];
            
            [[expectFutureValue(invalidError) shouldSoon] beNonNil];
            [[expectFutureValue(@([invalidError code])) shouldSoon] equal:@(SENServiceAccountErrorInvalidArg)];
        });
        
    });
    
    describe(@"-changeEmail:completion", ^{
        
        it(@"should return error if email not provided", ^{
            
            __block NSError* invalidError = nil;
            [[SENServiceAccount sharedService] changeEmail:nil completion:^(NSError *error) {
                invalidError = error;
            }];
            
            [[expectFutureValue(invalidError) shouldSoon] beNonNil];
            [[expectFutureValue(@([invalidError code])) shouldSoon] equal:@(SENServiceAccountErrorInvalidArg)];
        });
        
        it(@"should call refreshAccount:", ^{
            
            SENServiceAccount* service = [SENServiceAccount sharedService];
            [[service shouldSoon] receive:@selector(refreshAccount:)];
            [service changeEmail:@"test@test.com" completion:nil];
            
        });
        
    });
    
    describe(@"-updateAccount", ^{
        
        it(@"should call refreshAccount if account is not yet cached", ^{
            
            SENServiceAccount* service = [SENServiceAccount sharedService];
            [[service shouldSoon] receive:@selector(refreshAccount:)];
            [service updateAccount:nil];
            
        });
        
        context(@"account refreshed", ^{
            
            beforeEach(^{
                
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [service stub:@selector(refreshAccount:) withBlock:^id(NSArray *params) {
                    SENAccountResponseBlock cb = [params firstObject];
                    cb(nil);
                    return nil;
                }];
                
            });
            
            it(@"should call updateAccount:completionBlock of API", ^{
                
                [[SENAPIAccount shouldSoon] receive:@selector(updateAccount:completionBlock:)];
                [[SENServiceAccount sharedService] updateAccount:nil];
                
            });
            
            it(@"should make a callback", ^{
                
                [SENAPIAccount stub:@selector(updateAccount:completionBlock:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb ([params firstObject], nil);
                    return nil;
                }];
                
                __block BOOL calledback = NO;
                [[SENServiceAccount sharedService] updateAccount:^(NSError *error) {
                    calledback = YES;
                }];
                [[expectFutureValue(@(calledback)) shouldSoon] equal:@(YES)];
                
            });
            
        });
        
        describe(@"-updateAccount", ^{
            
            __block SENPreference* preference = nil;
            
            beforeEach(^{
                preference = [[SENPreference alloc] initWithType:SENPreferenceTypeEnhancedAudio enable:YES];
                [SENAPIPreferences stub:@selector(updatePreference:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
            });
            
            it(@"should call preference api", ^{
                
                SENServiceAccount* service = [SENServiceAccount sharedService];
                [[SENAPIPreferences shouldSoon] receive:@selector(updatePreference:completion:)];
                [service updatePreference:preference completion:nil];
                
            });
            
            it(@"should make a callback", ^{
                
                __block BOOL called = NO;
                [[SENServiceAccount sharedService] updatePreference:preference completion:^(NSError *error) {
                    called = YES;
                }];
                [[expectFutureValue(@(called)) shouldSoon] equal:@(YES)];
                
            });
            
        });
        
        
    });
    
});

SPEC_END
