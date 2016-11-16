//
//  SENAPIExpansionSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/27/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SenseKit/Model.h>
#import <SenseKit/API.h>

SPEC_BEGIN(SENAPIExpansionSpec)

describe(@"SENAPIExpansion", ^{
    
    describe(@"+getSupportedExpansions:", ^{
        
        context(@"api returned expansions", ^{
            
            __block id responseObj = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[@{@"id" : @"1",
                            @"category" : @"TEMPERATURE",
                            @"device_name" : @"Nest Thermostat",
                            @"service_name" : @"Nest",
                            @"icon_uri" : @"https://s3.amazon.com",
                            @"auth_uri" : @"https://oauth.com",
                            @"completion_uri" : @"https://complete.oauth.com",
                            @"state" : @"NOT_CONNECTED"}], nil);
                    return nil;
                }];
                
                [SENAPIExpansion getSupportedExpansions:^(id data, NSError *error) {
                    responseObj = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                responseObj = nil;
                apiError = nil;
            });
            
            it(@"should return list of SENExpansion objects", ^{
                [[responseObj should] beKindOfClass:[NSArray class]];
                
                id objectInside = [responseObj firstObject];
                [[objectInside should] beKindOfClass:[SENExpansion class]];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
    });
    
    describe(@"+getExpansionById:", ^{
        
        context(@"api returned expansion", ^{
            
            __block id responseObj = nil;
            __block NSError* apiError = nil;
            __block NSNumber* expansionId = @1;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@{@"id" : expansionId,
                          @"category" : @"TEMPERATURE",
                          @"device_name" : @"Nest Thermostat",
                          @"service_name" : @"Nest",
                          @"icon_uri" : @"https://s3.amazon.com",
                          @"auth_uri" : @"https://oauth.com",
                          @"completion_uri" : @"https://complete.oauth.com",
                          @"state" : @"NOT_CONNECTED"}, nil);
                    return nil;
                }];
                
                [SENAPIExpansion getExpansionById:[expansionId stringValue] completion:^(id data, NSError *error) {
                    responseObj = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                responseObj = nil;
                apiError = nil;
            });
            
            it(@"should return 1 SENExpansion object", ^{
                [[responseObj should] beKindOfClass:[SENExpansion class]];
                SENExpansion* exp = responseObj;
                [[[exp identifier] should] equal:expansionId];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
    });
    
    describe(@"+getExpansionConfigurationsFor:completion:", ^{
        
        context(@"api returned list of configurations", ^{
            
            __block id responseObj = nil;
            __block NSError* apiError = nil;
            __block SENExpansion* expansion = nil;
            
            beforeEach(^{
                NSDictionary* expDict = @{@"id" : @"1",
                                          @"category" : @"TEMPERATURE",
                                          @"device_name" : @"Nest Thermostat",
                                          @"service_name" : @"Nest",
                                          @"icon_uri" : @"https://s3.amazon.com",
                                          @"auth_uri" : @"https://oauth.com",
                                          @"completion_uri" : @"https://complete.oauth.com",
                                          @"state" : @"NOT_CONNECTED"};
                expansion = [[SENExpansion alloc] initWithDictionary:expDict];
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (@[@{@"id" : @"1",
                            @"name" : @"bedroom"},
                          @{@"id" : @"2",
                            @"name" : @"living room",
                            @"capabilities" : @[@"HEAT", @"COOL"]}], nil);
                    return nil;
                }];
                
                [SENAPIExpansion getExpansionConfigurationsFor:expansion completion:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                responseObj = nil;
                apiError = nil;
                expansion = nil;
            });
            
            it(@"should return list of configurations", ^{
                [[responseObj should] beKindOfClass:[NSArray class]];
                for (id obj in responseObj) {
                    [[obj should] beKindOfClass:[SENExpansionConfig class]];
                }
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"last object should contain 2 capabilities", ^{
                SENExpansionConfig* config = [responseObj lastObject];
                [[[config capabilities] should] haveCountOf:2];
                [[@([config hasCapability:SENExpansionCapabilityHeat]) should] beYes];
                [[@([config hasCapability:SENExpansionCapabilityCool]) should] beYes];
            });
            
        });
        
    });
    
});

SPEC_END
