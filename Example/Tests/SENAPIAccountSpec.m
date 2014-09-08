//
//  SENAPIAccountSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/5/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "SENapiAccount+Private.h"
#import "SENAccount.h"

SPEC_BEGIN(SENAPIaccountSpec)

describe(@"SENAPIAccount", ^{
    
    describe(@"+accountFromResponse:", ^{
        
        it(@"if response is not a dictionary, should be nil", ^{
            
            SENAccount* account = [SENAPIAccount accountFromResponse:@[]];
            [[account should] beNil];
            
        });
        
        it(@"if response is a dictionary, account should be instantiated", ^{
            
            SENAccount* account = [SENAPIAccount accountFromResponse:@{}];
            [[account should] beNonNil];
            
        });
        
        it(@"if response contains null value, corresponding property should be nil", ^{
            
            NSDictionary* response = @{
                @"id" : @"0000-00-00000",
                @"last_modified" : @(1409861723884),
                @"name" : [NSNull null]
            };
            SENAccount* account = [SENAPIAccount accountFromResponse:response];
            [[account should] beNonNil];
            [[[account accountId] should] equal:@"0000-00-00000"];
            [[[account name] should] beNil];
            
        });
        
    });
    
    describe(@"+dictionaryValue:", ^{
        __block SENAccount* account;
        
        beforeAll(^{
            account = [[SENAccount alloc] initWithAccountId:@"0" lastModified:@(123)];
        });
        
        it(@"make sure account id is not set in the dictionary since it will fail the request", ^{
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"id"] should] beNil];
        });
        
        it(@"if value in account object is nil, dictionary does not contain key", ^{
            [account setWeight:@(165)];
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"name"] should] beNil];
        });
        
        it(@"make sure gender is properly converted", ^{
            
            NSDictionary* dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"OTHER"];
            
            [account setGender:SENAccountGenderMale];
            dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"MALE"];
            
            [account setGender:SENAccountGenderFemale];
            dict = [SENAPIAccount dictionaryValue:account];
            [[[dict valueForKey:@"gender"] should] equal:@"FEMALE"];
        });
        
    });
    
});

SPEC_END
