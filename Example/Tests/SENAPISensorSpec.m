//
//  SENAPISensorSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 9/1/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/API.h>

SPEC_BEGIN(SENAPISensorSpec)

describe(@"SENAPISensor", ^{
    
    describe(@"+currentConditionsWithTempUnit:completion:", ^{
        
        context(@"api returns an error", ^{
            
            __block NSError* apiError = nil;
            __block id apiResponse;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                [SENAPISensor currentConditionsWithTempUnit:SENAPISensorTempUnitCelcius completion:^(id data, NSError *error) {
                    apiResponse = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should return an api error", ^{
                [[apiError should] beNonNil];
            });
            
            it(@"should not return response object", ^{
                [[apiResponse should] beNil];
            });
            
        });
        
        context(@"api returns sensor data", ^{
            
            NSTimeInterval sensorTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
            NSString* sensorName = @"temperature";
            NSDictionary* sensorValues = @{sensorName : @{@"name":sensorName,
                                                          @"value": @(22.8),
                                                          @"unit": @"c",
                                                          @"message": @"It's pretty cold in here.",
                                                          @"ideal_conditions": @"You sleep best when **it isn't freezing in here.**",
                                                          @"condition": @"WARNING",
                                                          @"last_updated_utc": @(sensorTimestamp)}};
            
            __block NSError* apiError = nil;
            __block id apiResponse;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (sensorValues, nil);
                    return nil;
                }];
                [SENAPISensor currentConditionsWithTempUnit:SENAPISensorTempUnitCelcius completion:^(id data, NSError *error) {
                    apiResponse = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should not return an api error", ^{
                [[apiError shouldSoon] beNil];
            });
            
            it(@"should return an array with 1 sensor object", ^{
                [[expectFutureValue(apiResponse) shouldSoon] beKindOfClass:[NSArray class]];
                [[expectFutureValue(@([apiResponse count])) shouldSoon] equal:@1];
                
                id sensor = [apiResponse firstObject];
                [[expectFutureValue(sensor) shouldSoon] beKindOfClass:[SENSensor class]];
            });
            
        });
        
    });
    
});

SPEC_END
