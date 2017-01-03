//
//  SENAPISystemAlertsSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 11/8/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SenseKit/Model.h>
#import <SenseKit/API.h>

SPEC_BEGIN(SENAPISystemAlertsSpec)

describe(@"SENAPISystemAlerts", ^{
    
    describe(@"+getSystemAlerts:", ^{
        
        context(@"api returns 1 expansion unreachable alert", ^{
            
            __block id returnedObj = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params  lastObject];
                    cb (@[@{@"title" : @"title",
                            @"body" : @"body",
                            @"category" : @"EXPANSION_UNREACHABLE"}], nil);
                    return nil;
                }];
                
                [SENAPISystemAlerts getSystemAlerts:^(id data, NSError *error) {
                    returnedObj = data;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                returnedObj = nil;
                apiError = nil;
            });
            
            it(@"should return an array of 1 alert object", ^{
                [[returnedObj should] beKindOfClass:[NSArray class]];
                [[returnedObj should] haveCountOf:1];
                
                SENSystemAlert* alert = [returnedObj firstObject];
                [[[alert localizedTitle] should] beNonNil];
                [[[alert localizedBody] should] beNonNil];
            });
            
            it(@"should not have an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"api returns 1 sense is muted alert", ^{
            
            __block id returnedObj = nil;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params  lastObject];
                    cb (@[@{@"title" : @"title",
                            @"body" : @"body",
                            @"category" : @"SENSE_MUTED"}], nil);
                    return nil;
                }];
                
                [SENAPISystemAlerts getSystemAlerts:^(id data, NSError *error) {
                    returnedObj = data;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                returnedObj = nil;
                apiError = nil;
            });
            
            it(@"should return an array of 1 alert object with proper category", ^{
                [[returnedObj should] beKindOfClass:[NSArray class]];
                [[returnedObj should] haveCountOf:1];
                
                SENSystemAlert* alert = [returnedObj firstObject];
                [[[alert localizedTitle] should] beNonNil];
                [[[alert localizedBody] should] beNonNil];
                [[@([alert category]) should] equal:@(SENAlertCategoryMuted)];
            });
            
            it(@"should not have an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
    });
    
});

SPEC_END
