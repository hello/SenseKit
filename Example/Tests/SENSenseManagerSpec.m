#import <Kiwi/Kiwi.h>
#import <LGBluetooth/LGBluetooth.h>
#import "SENSenseManager.h"
#import "SENSense.h"
#import "SENSenseMessage.pb.h"
#import "SENLocalPreferences.h"

typedef BOOL(^SENSenseUpdateBlock)(id response);

@interface SENSenseManager (Private)

- (NSArray*)blePackets:(SENSenseMessage*)message;
- (SENSenseMessage*)messageFromBlePackets:(NSArray*)packets error:(NSError**)error;
- (void)handleResponseUpdate:(NSData*)data
                       error:(NSError*)error
              forMessageType:(SENSenseMessageType)type
                  allPackets:(NSMutableArray**)allPackets
                totalPackets:(NSNumber**)totalPackets
                     success:(SENSenseSuccessBlock)success
                     failure:(SENSenseFailureBlock)failure;
- (void)sendPackets:(NSArray*)packets
               from:(NSInteger)index
      throughWriter:(LGCharacteristic*)writer
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure;
- (void)scheduleMessageTimeOut:(NSTimeInterval)timeOutInSecs withKey:(NSString*)key;
- (void)timedOut:(NSTimer*)timer;
- (NSMutableDictionary*)messageTimeoutTimers;
- (NSMutableDictionary*)messageSuccessCallbacks;
- (NSData*)dataValueForWiFiPassword:(NSString*)password
                   withSecurityType:(SENWifiEndpointSecurityType)type
                    formattingError:(NSError**)error;
- (void)sendMessage:(SENSenseMessage*)message
            timeout:(NSTimeInterval)timeout
             update:(SENSenseUpdateBlock)update
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure;
- (SENSenseMessageBuilder*)messageBuilderWithType:(SENSenseMessageType)type;
- (BOOL)response:(SENSenseMessage*)response matchesRequestType:(SENSenseMessageType)type;

@end

SPEC_BEGIN(SENSenseManagerSpec)

describe(@"SENSenseManager", ^{
    
    describe(@"+scanForSense:", ^{
        
        it(@"should return NO while in tests", ^{
            [[@([SENSenseManager scanForSense:nil]) should] equal:@(NO)];
        });
        
    });
    
    describe(@"+scanForSenseWithTimeout:completion", ^{
        
        it(@"should return NO while in tests", ^{
            [[@([SENSenseManager scanForSenseWithTimeout:5 completion:nil]) should] equal:@(NO)];
        });
        
    });
    
    describe(@"-enablePairingMode:success:failure", ^{
        
        it(@"should fail with no sense initialized", ^{
            __block NSError* failError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:nil];
            [manager enablePairingMode:YES success:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                failError = error;
            }];
            [[expectFutureValue(@([failError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
        });
        
        it(@"should fail if sense not initialized properly", ^{
            __block NSError* failError = nil;
            SENSense* sense = [[SENSense alloc] init];
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:sense];
            [manager enablePairingMode:YES success:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                failError = error;
            }];
            [[expectFutureValue(@([failError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
        });
        
    });

    describe(@"-removeOtherPairedDevices:failure:", ^{
        __block NSError* failError = nil;
        it(@"should fail with no sense initialized", ^{
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:nil];
            [manager removeOtherPairedDevices:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                failError = error;
            }];
            [[expectFutureValue(@([failError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
        });
        
        it(@"should fail if sense not initialized properly", ^{
            __block NSError* failError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:nil];
            [manager removeOtherPairedDevices:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                failError = error;
            }];
            [[expectFutureValue(@([failError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
        });
        
    });
    
    describe(@"-blePackets:", ^{
        
        it(@"packets should be properly formatted", ^{
            SENSenseManager* manager = [[SENSenseManager alloc] init];
            
            SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
            [builder setType:SENSenseMessageTypeSwitchToPairingMode];
            [builder setVersion:0];
            
            SENSenseMessage* message = [builder build];
            NSArray* packets = [manager blePackets:message];
            
            [[@([packets count]) should] equal:@(1)];
            
            NSData* data = packets[0];
            uint8_t packet[[data length]];
            [data getBytes:&packet length:sizeof(packet)];
            
            uint8_t firstByte = packet[0];
            uint8_t secondByte = packet[1];
            
            [[@(firstByte) should] equal:@(0)];
            [[@(secondByte) should] equal:@(1)];
            [[@(sizeof(packet)) should] equal:@(6)];
        });
        
    });
    
    describe(@"-messageFromBlePackets:error:", ^{
        __block SENSenseManager* manager;
        __block SENSenseMessageBuilder* builder;
        
        beforeEach(^{
            manager = [[SENSenseManager alloc] initWithSense:[[SENSense alloc] init]];
            builder = [[SENSenseMessageBuilder alloc] init];
            [builder setType:SENSenseMessageTypeSwitchToPairingMode];
            [builder setVersion:0];
        });
        
        it(@"a single properly formatted packet should return a message", ^{
            NSData* data = [manager blePackets:[builder build]][0];
            
            NSError* error = nil;
            SENSenseMessage* message = [manager messageFromBlePackets:@[data] error:&error];
            
            [[error should] beNil];
            [[message should] beNonNil];
            [[@([message type]) should] equal:@(SENSenseMessageTypeSwitchToPairingMode)];
        });
        
        it(@"a malformed hello ble packet should return an error", ^{
            SENSenseMessage* input = [builder build];
            
            NSError* error = nil;
            SENSenseMessage* output = [manager messageFromBlePackets:@[[input data]] error:&error];
            
            [[error should] beNonNil];
            [[output should] beNil];
        });
        
    });
    
    describe(@"-handleResponseUpdate:error:forMessageType:allPackets:totalPackets:success:failure", ^{
        __block SENSenseManager* manager;
        __block NSData* data;
        __block NSMutableArray* all;
        __block NSNumber* total;
        
        beforeEach(^{
            manager = [[SENSenseManager alloc] initWithSense:[[SENSense alloc] init]];
            SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
            [builder setType:SENSenseMessageTypeSwitchToPairingMode];
            [builder setVersion:0];
            data = [manager blePackets:[builder build]][0];
            all = [NSMutableArray array];
            total = nil;
        });
        
        
        it(@"handling a response that has only 1 packet should return success", ^{
            __block id responseObject = nil;
            __block SENSenseMessageType type = SENSenseMessageTypeError;
            [manager handleResponseUpdate:data
                                    error:nil
                           forMessageType:SENSenseMessageTypeSwitchToPairingMode
                               allPackets:&all
                             totalPackets:&total
                                  success:^(id response) {
                                      responseObject = response;
                                      type = [((SENSenseMessage*)responseObject) type];
                                  } failure:^(NSError *error) {
                                      fail(@"should not fail");
                                  }];
           
            [[expectFutureValue(responseObject) shouldSoon] beKindOfClass:[SENSenseMessage class]];
            [[expectFutureValue(@(type)) shouldSoon] equal:@(SENSenseMessageTypeSwitchToPairingMode)];
            
        });
        
        it(@"handling a response with error should invoke failure block", ^{
            __block NSError* responseError = nil;
            [manager handleResponseUpdate:data
                                    error:[NSError errorWithDomain:@"test"
                                                              code:-1
                                                          userInfo:nil]
                           forMessageType:SENSenseMessageTypeSwitchToPairingMode
                               allPackets:&all
                             totalPackets:&total
                                  success:^(id response) {
                                      fail(@"fail");
                                  } failure:^(NSError *error) {
                                      responseError = error;
                                  }];
            
            [[expectFutureValue(@([responseError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeUnexpectedResponse)];
        });
        
    });
    
    describe(@"-sendPackets:from:throughWriter:success:failure", ^{
        
        it(@"should fail because there's no connection to ble pheripheral", ^{
            __block NSError* responseError = nil;
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:[[SENSense alloc] init]];
            [manager sendPackets:@[]
                            from:0
                   throughWriter:[[LGCharacteristic alloc] init]
                         success:^(id response) {
                             fail(@"should not succeed");
                         }
                         failure:^(NSError *error) {
                             responseError = error;
                         }];
            [[expectFutureValue(@([responseError code])) shouldSoon] equal:@(SENSenseManagerErrorCodeConnectionFailed)];
        });
        
    });
    
    describe(@"time outs", ^{
        
        __block NSString* key = nil;
        __block SENSenseManager* manager = nil;
        
        beforeAll(^{
            key = @"1";
            manager = [[SENSenseManager alloc] initWithSense:[[SENSense alloc] init]];
            [manager scheduleMessageTimeOut:1.0f withKey:key];
        });
        
        it(@"should cache the timer so that it can be cancelled", ^{
            
            [[[[manager messageTimeoutTimers] objectForKey:key] should] beNonNil];
        });
        
        it(@"when timer fires, calling timedOut:, timer and callbacks should be nil", ^{
            [[[[manager messageTimeoutTimers] objectForKey:key] should] beNonNil];
            
            [[manager messageSuccessCallbacks] setValue:^{} forKey:key];
            [manager timedOut:[NSTimer timerWithTimeInterval:1.0f target:manager
                                                     selector:@selector(timedOut:)
                                                     userInfo:key
                                                     repeats:NO]];
            
            [[[[manager messageTimeoutTimers] objectForKey:key] should] beNil];
            [[[[manager messageSuccessCallbacks] objectForKey:key] should] beNil];
        });
    });
    
    describe(@"+isWepKeyValid", ^{
        
        it(@"should be invalid if empty string", ^{
            
            BOOL valid = [SENSenseManager isWepKeyValid:@""];
            [[@(valid) should] beNo];
            
        });
        
        it(@"should be invalid if key has an odd length", ^{
            
            BOOL valid = [SENSenseManager isWepKeyValid:@"ABCDEF123"];
            [[@(valid) should] beNo];
            
        });
        
        it(@"should be valid with 64/40 bit encryption network key", ^{
            
            BOOL valid = [SENSenseManager isWepKeyValid:@"9436AFD3AD"];
            [[@(valid) should] beYes];
            
        });
        
        it(@"should be valid with 128 bit encryption network key", ^{
            
            BOOL valid = [SENSenseManager isWepKeyValid:@"9436AFD3AD1234567891234567"];
            [[@(valid) should] beYes];
            
        });
        
        it(@"should be valid despite cases in lower and upper case", ^{
            BOOL valid = [SENSenseManager isWepKeyValid:@"9436afD3AD1234567891234567"];
            [[@(valid) should] beYes];
        });
        
        it(@"should be invalid if not hex", ^{
            BOOL valid = [SENSenseManager isWepKeyValid:@"MYNAMEISWEPANDISUCK"];
            [[@(valid) should] beNo];
        });
        
    });
    
    describe(@"setting wifi", ^{
        
        context(@"wifi password converstion to data", ^{
            
            __block SENSenseManager* manager = nil;
            
            beforeAll(^{
                manager = [[SENSenseManager alloc] initWithSense:[[SENSense alloc] init]];
            });
            
            it(@"open networks should return nil as data", ^{
                
                NSError* error = nil;
                NSData* data = [manager dataValueForWiFiPassword:@"123"
                                                withSecurityType:SENWifiEndpointSecurityTypeOpen
                                                 formattingError:&error];
                [[error should] beNil];
                [[data should] beNil];
                
            });
            
            it(@"valid wep network key should return data without error", ^{
                
                NSError* error = nil;
                NSData* data = [manager dataValueForWiFiPassword:@"9436AFD3AD"
                                                withSecurityType:SENWifiEndpointSecurityTypeWep
                                                 formattingError:&error];
                [[error should] beNil];
                [[data should] beNonNil];
                
            });
            
            it(@"invalid wep network key should return error, with no data", ^{
                
                NSError* error = nil;
                NSData* data = [manager dataValueForWiFiPassword:@"9436AFD3AD1"
                                                withSecurityType:SENWifiEndpointSecurityTypeWep
                                                 formattingError:&error];
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeInvalidWEPKey)];
                [[data should] beNil];
                
            });
            
            it(@"WPA passwords should return data with no error", ^{
                
                NSError* error = nil;
                NSData* data = [manager dataValueForWiFiPassword:@"password"
                                                withSecurityType:SENWifiEndpointSecurityTypeWpa
                                                 formattingError:&error];
                [[error should] beNil];
                [[data should] beNonNil];
                
            });
            
        });
        
    });
    
    describe(@"+lastConnectedSense:", ^{
        
        __block SENSense* sense = nil;
        __block NSError* error = nil;
        __block LGCentralManager* central = nil;
        
        beforeAll(^{
            central = [LGCentralManager sharedInstance];
        });
        
        afterAll(^{
            [central clearStubs];
            [[SENLocalPreferences sharedPreferences] clearStubs];
            [SENSenseManager clearStubs];
            
            sense = nil;
            error = nil;
            central = nil;
        });
        
        context(@"ble not available", ^{
            
            beforeAll(^{
                [SENSenseManager stub:@selector(whenBleStateAvailable:) withBlock:^id(NSArray *params) {
                    void(^cb)(BOOL on) = [params lastObject];
                    cb (NO);
                    return nil;
                }];
                
                [SENSenseManager lastConnectedSense:^(SENSense *lastSense, NSError *bleError) {
                    sense = lastSense;
                    error = bleError;
                }];
            });
            
            afterAll(^{
                [SENSenseManager clearStubs];
                sense = nil;
                error = nil;
            });
            
            it(@"should not return a SENSense object", ^{
                [[sense should] beNil];
            });
            
            it(@"should return a no ble error", ^{
                [[error should] beNonNil];
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeNoBLE)];
            });
            
        });
        
        context(@"ble is available, but device never saved the last sense connected to", ^{
            
            beforeAll(^{
                [SENSenseManager stub:@selector(whenBleStateAvailable:) withBlock:^id(NSArray *params) {
                    void(^cb)(BOOL on) = [params lastObject];
                    cb (YES);
                    return nil;
                }];
                
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                [preferences stub:@selector(userPreferenceForKey:) andReturn:nil];
                
                [SENSenseManager lastConnectedSense:^(SENSense *lastSense, NSError *bleError) {
                    sense = lastSense;
                    error = bleError;
                }];
            });
            
            afterAll(^{
                [[SENLocalPreferences sharedPreferences] clearStubs];
                [SENSenseManager clearStubs];
                sense = nil;
                error = nil;
            });
            
            it(@"should not return a SENSense object", ^{
                [[sense should] beNil];
            });
            
            it(@"should return an error with code specifying it never connected", ^{
                [[error should] beNonNil];
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeNeverConnectedToASense)];
            });
            
        });
        
        context(@"ble is available and last connected Sense was saved, but Sense was forgotten", ^{
            
            beforeAll(^{
                [SENSenseManager stub:@selector(whenBleStateAvailable:) withBlock:^id(NSArray *params) {
                    void(^cb)(BOOL on) = [params lastObject];
                    cb (YES);
                    return nil;
                }];
                
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                [preferences stub:@selector(userPreferenceForKey:) andReturn:@"0000FEE1-1212-EFDE-1523-785FEABCD123"];
                
                [central stub:@selector(retrievePeripheralsWithIdentifiers:) andReturn:@[]];
                
                [SENSenseManager lastConnectedSense:^(SENSense *lastSense, NSError *bleError) {
                    sense = lastSense;
                    error = bleError;
                }];
            });
            
            afterAll(^{
                [central clearStubs];
                [[SENLocalPreferences sharedPreferences] clearStubs];
                [SENSenseManager clearStubs];
                sense = nil;
                error = nil;
            });
            
            it(@"should not return a SENSense object", ^{
                [[sense should] beNil];
            });
            
            it(@"should return an error that sense was forgotten", ^{
                [[error should] beNonNil];
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeForgottenSense)];
            });
            
        });
        
        context(@"central found peripheral for the saved sense UUID", ^{
            
            __block NSString* everythingId = @"0000FEE1-1212-EFDE-1523-785FEABCD123";
            
            beforeAll(^{
                [SENSenseManager stub:@selector(whenBleStateAvailable:) withBlock:^id(NSArray *params) {
                    void(^cb)(BOOL on) = [params lastObject];
                    cb (YES);
                    return nil;
                }];
                
                SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
                [preferences stub:@selector(userPreferenceForKey:) andReturn:everythingId];
                
                [central stub:@selector(retrievePeripheralsWithIdentifiers:) andReturn:@[[LGPeripheral new]]];
                
                [SENSenseManager lastConnectedSense:^(SENSense *lastSense, NSError *bleError) {
                    sense = lastSense;
                    error = bleError;
                }];
            });
            
            afterAll(^{
                [central clearStubs];
                [[SENLocalPreferences sharedPreferences] clearStubs];
                [SENSenseManager clearStubs];
                sense = nil;
                error = nil;
            });
            
            it(@"should not return an error", ^{
                [[error should] beNil];
            });
            
            it(@"should return a SENSense object", ^{
                [[sense should] beKindOfClass:[SENSense class]];
            });
            
            it(@"should return a SENSense object with a device id", ^{
                [[[sense deviceId] should] equal:everythingId];
            });
            
        });
        
    });
    
    describe(@"-scanForWifiNetworksForCountry:success:failure", ^{
        
        context(@"sends EU as country code", ^{
            
            __block NSString* countryCode = nil;
            __block SENSenseManager* manager = nil;
            __block SENSenseMessage* message = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                countryCode = @"EU";
                manager = [SENSenseManager new];
                [manager stub:@selector(sendMessage:timeout:update:success:failure:) withBlock:^id(NSArray *params) {
                    message = [params firstObject];
                    SENSenseSuccessBlock success = params[3];
                    success ([SENSenseMessage new]);
                    return nil;
                }];
                
                [manager scanForWifiNetworksInCountry:countryCode success:^(id response) {
                    calledBack = YES;
                } failure:nil];
                
            });
            
            afterEach(^{
                [manager clearStubs];
                countryCode = nil;
                manager = nil;
                message = nil;
            });
            
            it(@"should have EU as country code in sense message", ^{
                [[[message countryCode] should] equal:countryCode];
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
        context(@"no country code sent", ^{
            
            __block SENSenseManager* manager = nil;
            __block SENSenseMessage* message = nil;
            __block BOOL calledBack = NO;
            
            beforeEach(^{
                manager = [SENSenseManager new];
                [manager stub:@selector(sendMessage:timeout:update:success:failure:) withBlock:^id(NSArray *params) {
                    message = [params firstObject];
                    SENSenseSuccessBlock success = params[3];
                    success ([SENSenseMessage new]);
                    return nil;
                }];
                
                [manager scanForWifiNetworksInCountry:nil success:^(id response) {
                    calledBack = YES;
                } failure:nil];
                
            });
            
            afterEach(^{
                [manager clearStubs];
                manager = nil;
                message = nil;
            });
            
            it(@"should not have country code in sense message", ^{
                [[@([message hasCountryCode]) should] beNo];
            });
            
            it(@"should call back", ^{
                [[@(calledBack) should] beYes];
            });
            
        });
        
    });
    
    describe(@"- response:matchesRequestType:", ^{
        
        __block SENSenseManager* manager = nil;
        
        beforeEach(^{
            manager = [SENSenseManager new];
        });
        
        afterEach(^{
            manager = nil;
        });
        
        it(@"should return NO if response for start scan is not start or end", ^{
            SENSenseMessageBuilder* builder = [manager messageBuilderWithType:SENSenseMessageTypeConnectionState];
            BOOL matches = [manager response:[builder build]
                          matchesRequestType:SENSenseMessageTypeStartWifiscan];
            [[@(matches) should] beNo];
        });
        
        it(@"should return YES if response for start scan is to end", ^{
            SENSenseMessageBuilder* builder = [manager messageBuilderWithType:SENSenseMessageTypeStopWifiscan];
            BOOL matches = [manager response:[builder build]
                          matchesRequestType:SENSenseMessageTypeStartWifiscan];
            [[@(matches) should] beYes];
        });
        
        it(@"should return YES if response for set wifi is connection state change", ^{
            SENSenseMessageBuilder* builder = [manager messageBuilderWithType:SENSenseMessageTypeConnectionState];
            BOOL matches = [manager response:[builder build]
                          matchesRequestType:SENSenseMessageTypeSetWifiEndpoint];
            [[@(matches) should] beYes];
        });
        
        it(@"should return YES if response type is request type", ^{
            SENSenseMessageBuilder* builder = [manager messageBuilderWithType:SENSenseMessageTypePairSense];
            BOOL matches = [manager response:[builder build]
                          matchesRequestType:SENSenseMessageTypePairSense];
            [[@(matches) should] beYes];
        });
        
        it(@"should return NO if response type is NOt request type and not one of the wifi commands", ^{
            SENSenseMessageBuilder* builder = [manager messageBuilderWithType:SENSenseMessageTypePairPill];
            BOOL matches = [manager response:[builder build]
                          matchesRequestType:SENSenseMessageTypePairSense];
            [[@(matches) should] beNo];
        });
        
    });
    
});

SPEC_END