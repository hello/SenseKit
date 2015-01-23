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
#import "SENAuthorizationService.h"

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
            [[SENServiceAccount sharedService] changePassword:nil toNewPassword:@"test123" completion:^(NSError *error) {
                invalidError = error;
            }];
            
            [[expectFutureValue(invalidError) should] beNonNil];
            [[expectFutureValue(@([invalidError code])) should] equal:@(SENServiceAccountErrorInvalidArg)];
        });
        
    });
    
    describe(@"-changeEmail:completion", ^{
        
        it(@"should return error if email not provided", ^{
            
            __block NSError* invalidError = nil;
            [[SENServiceAccount sharedService] changeEmail:nil completion:^(NSError *error) {
                invalidError = error;
            }];
            
            [[expectFutureValue(invalidError) should] beNonNil];
            [[expectFutureValue(@([invalidError code])) should] equal:@(SENServiceAccountErrorInvalidArg)];
        });
        
        it(@"should call refreshAccount:", ^{
            
            SENServiceAccount* service = [SENServiceAccount sharedService];
            [[service should] receive:@selector(refreshAccount:)];
            [service changeEmail:@"test@test.com" completion:nil];
            
        });
        
    });
    
});

SPEC_END
