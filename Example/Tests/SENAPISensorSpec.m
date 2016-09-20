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
    
    describe(@"+getSensorStatus:", ^{
        
        context(@"api returns an error", ^{
            
            __block NSError* apiError = nil;
            __block id apiResponse;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                [SENAPISensor getSensorStatus:^(id data, NSError *error) {
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
        
        context(@"api returns sensor status", ^{
            
            NSDictionary* raw = @{@"status" : @"OK",
                                  @"sensors" : @[@{@"type" : @"TEMPERATURE",
                                                  @"name" : @"Temperature",
                                                  @"unit" : @"CELSIUS",
                                                  @"value" : @70,
                                                  @"message" : @"The temperature is just right",
                                                  @"scale" : @[@{@"name" : @"Cold",
                                                                 @"min" : @0,
                                                                 @"max" : @35,
                                                                 @"condition" : @"ALERT"}]}]};
            
            __block NSError* apiError = nil;
            __block id apiResponse;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (raw, nil);
                    return nil;
                }];
                [SENAPISensor getSensorStatus:^(id data, NSError *error) {
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
            
            it(@"should return a sensor status object", ^{
                [[apiResponse should] beKindOfClass:[SENSensorStatus class]];
            });
            
            it(@"should have a state of OK", ^{
                SENSensorStatus* status = apiResponse;
                [[@([status state]) should] equal:@(SENSensorStateOk)];
            });
            
            it(@"should have 1 temperature sensor", ^{
                SENSensorStatus* status = apiResponse;
                SENSensor* sensor = [[status sensors] firstObject];
                [[@([sensor type]) should] equal:@(SENSensorTypeTemp)];
            });
            
        });
        
    });
    
    describe(@"+getSensorDataWithRequest:completion:", ^{
        
        NSDictionary* sensorDict = @{@"type" : @"TEMPERATURE",
                                     @"name" : @"Temperature",
                                     @"unit" : @"CELSIUS",
                                     @"value" : @70,
                                     @"message" : @"The temperature is just right",
                                     @"scale" : @[@{@"name" : @"Cold",
                                                    @"min" : @0,
                                                    @"max" : @35,
                                                    @"condition" : @"ALERT"}]};
        
        context(@"api returns an error", ^{
            
            __block SENSensor* sensor = nil;
            __block NSError* apiError = nil;
            __block id apiResponse;
            
            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:sensorDict];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    cb (nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                    return nil;
                }];
                
                SENSensorDataRequest* request = [[SENSensorDataRequest alloc] initWithScope:SENSensorDataScopeDay5Min];
                [request addSensor:sensor];
                [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
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
            
            __block NSError* apiError = nil;
            __block id apiResponse;
            __block SENSensor* sensor = nil;
            
            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:sensorDict];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    NSString* sensorType = [sensor typeStringValue];
                    cb (@{sensorType : @[]}, nil);
                    return nil;
                }];
                
                SENSensorDataRequest* request = [[SENSensorDataRequest alloc] initWithScope:SENSensorDataScopeDay5Min];
                [request addSensor:sensor];
                [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
                    apiResponse = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should not return an api error", ^{
                [[expectFutureValue(apiError) shouldSoon] beNil];
            });
            
            it(@"should return a data collection", ^{
                Class clazz = [SENSensorDataCollection class];
                [[expectFutureValue(apiResponse) shouldSoon] beKindOfClass:clazz];
            });
            
        });
        
        context(@"3 hour scope requested", ^{
            
            __block id parameters = nil;
            __block NSError* apiError = nil;
            __block id apiResponse;
            __block SENSensor* sensor = nil;
            
            beforeEach(^{
                sensor = [[SENSensor alloc] initWithDictionary:sensorDict];
                
                [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                    parameters = params[1];
                    SENAPIDataBlock cb = [params lastObject];
                    NSString* sensorType = [sensor typeStringValue];
                    cb (@{sensorType : @[]}, nil);
                    return nil;
                }];
                
                SENSensorDataRequest* request = [[SENSensorDataRequest alloc] initWithScope:SENSensorDataScopeLast3H5Min];
                [request addSensor:sensor];
                [SENAPISensor getSensorDataWithRequest:request completion:^(id data, NSError *error) {
                    apiResponse = data;
                    apiError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should not return an api error", ^{
                [[expectFutureValue(apiError) shouldSoon] beNil];
            });
            
            it(@"should return a data collection", ^{
                Class clazz = [SENSensorDataCollection class];
                [[expectFutureValue(apiResponse) shouldSoon] beKindOfClass:clazz];
            });
            
            it(@"should have set parameters accordingly", ^{
                [[parameters should] beKindOfClass:[NSDictionary class]];
                
                NSDictionary* params = parameters;
                NSArray* sensors = params[@"sensors"];
                NSString* sensorType = [sensors firstObject];
                NSString* scope = params[@"scope"];
                
                [[scope should] equal:@"LAST_3H_5_MINUTE"];
                [[sensorType should] equal:[sensor typeStringValue]];
            });
            
        });
        
    });
    
});

SPEC_END
