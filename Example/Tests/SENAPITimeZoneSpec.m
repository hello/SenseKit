//
//  SENAPITimeZoneSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 10/29/14.
//  Copyright (c) 2014 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPITimeZone.h>

SPEC_BEGIN(SENAPITimeZoneSpec)

describe(@"SENAPITimeZone", ^{
    
    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });
    
    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    describe(@"+ setTimeZone:completion", ^{
        
        it(@"should make a POST call", ^{
            [[SENAPIClient should] receive:@selector(POST:parameters:completion:)];
            [SENAPITimeZone setTimeZone:[NSTimeZone localTimeZone] completion:nil];
        });
        
        it(@"should call completion block", ^{
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
            
            __block BOOL calledBack = NO;
            [SENAPITimeZone setTimeZone:[NSTimeZone localTimeZone] completion:^(id data, NSError *error) {
                calledBack = YES;
            }];
            [[@(calledBack) should] beYes];
        });
        
        it(@"should complete with error", ^{
            __block NSError* timezoneError = nil;
            [SENAPITimeZone setTimeZone:nil completion:^(id data, NSError *error) {
                timezoneError = error;
            }];
            [[timezoneError should] beNonNil];
        });
        
    });
    
    describe(@"+ setCurrentTimeZone", ^{

        it(@"should call setTimeZone:completion", ^{
            [[SENAPITimeZone should] receive:@selector(setTimeZone:completion:)];
            [SENAPITimeZone setCurrentTimeZone:nil];
        });
        
        it(@"should call completion block", ^{
            [SENAPITimeZone stub:@selector(setTimeZone:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
            
            __block BOOL calledback = NO;
            [SENAPITimeZone setCurrentTimeZone:^(id data, NSError *error) {
                calledback = YES;
            }];
            [[@(calledback) should] beYes];
            
        });
        
    });
    
    describe(@"+ getConfiguredTimeZone", ^{
        
        it(@"should return an error, without a timezone", ^{
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                return nil;
            }];
            
            __block NSTimeZone* timeZone = nil;
            __block NSError* timeZoneError = nil;
            [SENAPITimeZone getConfiguredTimeZone:^(id data, NSError *error) {
                timeZone = data;
                timeZoneError = error;
            }];
            
            [[timeZone should] beNil];
            [[timeZoneError should] beNonNil];
            
        });
        
        it(@"should return a NSTimeZone object", ^{
            
            NSString* timeZoneId = @"America/Los_Angeles";
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb (@{@"timezone_id" : timeZoneId}, nil);
                return nil;
            }];
            
            __block NSTimeZone* timeZone = nil;
            [SENAPITimeZone getConfiguredTimeZone:^(id data, NSError *error) {
                timeZone = data;
            }];
            
            [[timeZone should] beKindOfClass:[NSTimeZone class]];
            [[[timeZone name] should] equal:timeZoneId];
            
        });
        
        it(@"should return an invalid response error", ^{
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock cb = [params lastObject];
                cb (@{@"haha" : @"what?"}, nil);
                return nil;
            }];
            
            __block NSError* tzError = nil;
            [SENAPITimeZone getConfiguredTimeZone:^(id data, NSError *error) {
                tzError = error;
            }];
            
            [[@([tzError code]) should] equal:@(SENAPITimeZoneErrorInvalidResponse)];

        });
        
    });
    
});

SPEC_END
