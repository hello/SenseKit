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
        
        it(@"should call api", ^{
            
            [[SENAPIAccount should] receive:@selector(changePassword:toNewPassword:completionBlock:)];
            [[SENServiceAccount sharedService] changePassword:@"test" toNewPassword:@"test123" completion:nil];
            
        });
        
    });
    
});

SPEC_END
