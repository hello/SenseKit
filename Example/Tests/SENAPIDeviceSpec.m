#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPIDevice.h>

NSDictionary* (^CreateFakeSenseData)(BOOL active) = ^(BOOL active) {
    return @{@"id" : @"1",
             @"firmware_version" : @"1",
             @"last_updated" : @([NSDate timeIntervalSinceReferenceDate]),
             @"state" : @"NORMAL",
             @"color" : @"BLACK",
             @"active" : @(active),
             @"wifi_info" : @{@"ssid" : @"Hello",
                              @"rssi" : @(-50),
                              @"condition" : @"FAIR",
                              @"last_updated" : @([NSDate timeIntervalSinceReferenceDate])}};
};

NSDictionary* (^CreateFakePillData)(void) = ^(void) {
    return @{@"id" : @"1",
             @"firmware_version" : @"1",
             @"last_updated" : @([NSDate timeIntervalSinceReferenceDate]),
             @"state" : @"LOW_BATTERY",
             @"color" : @"BLUE",
             @"battery_level" : @100};
};

NSDictionary* (^CreateFakePairingInfo)(void) = ^(void) {
    return @{@"sense_id" : @"1", @"paired_accounts" : @1};
};

@interface SENAPIDevice (Private)

@end

SPEC_BEGIN(SENAPIDeviceSpec)

describe(@"SENAPIDevice", ^{

    describe(@"+ getPairedDevices:", ^{

        context(@"there are no paired devices", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@{@"senses" : @[], @"pills" : @[]}, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
            });

            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENPairedDevices object", ^{
                [[responseObj should] beKindOfClass:[SENPairedDevices class]];
            });
            
            it(@"should not have a paired sense", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedSense]) should] beNo];
            });
            
            it(@"should not have a paired pill", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedPill]) should] beNo];
            });
            
        });
        
        context(@"a sense is paired", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSDictionary* fakeSense = nil;
            
            beforeEach(^{
                fakeSense = CreateFakeSenseData(YES);
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@{@"senses" : @[fakeSense], @"pills" : @[]}, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
                fakeSense = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENPairedDevices object", ^{
                [[responseObj should] beKindOfClass:[SENPairedDevices class]];
            });
            
            it(@"should have a paired sense", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedSense]) should] beYes];
            });
            
            it(@"should contain a proper sense metadata object", ^{
                SENPairedDevices* devices = responseObj;
                SENSenseMetadata* senseMetadata = [devices activeSenseMetadata];
                [[[senseMetadata uniqueId] should] equal:fakeSense[@"id"]];
                [[@([senseMetadata isActive]) should] beYes];
            });
            
            it(@"should not have a paired pill", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedPill]) should] beNo];
            });
            
        });
        
        context(@"a pill is paired", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSDictionary* fakePill = nil;
            
            beforeEach(^{
                fakePill = CreateFakePillData();
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@{@"senses" : @[], @"pills" : @[fakePill]}, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
                fakePill = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENPairedDevices object", ^{
                [[responseObj should] beKindOfClass:[SENPairedDevices class]];
            });
            
            it(@"should not have a paired sense", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedSense]) should] beNo];
            });
            
            it(@"should have a paired pill", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedPill]) should] beYes];
            });
            
            it(@"should contain a proper pill metadata object", ^{
                SENPairedDevices* devices = responseObj;
                SENPillMetadata* pillMetadata = [devices activePillMetadata];
                [[[pillMetadata uniqueId] should] equal:fakePill[@"id"]];
                [[@([pillMetadata isActive]) should] beYes];
            });
        
        });
        
        context(@"a pill and sense is paired", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSDictionary* fakePill = nil;
            __block NSDictionary* fakeSense = nil;
            
            beforeEach(^{
                fakeSense = CreateFakeSenseData(YES);
                fakePill = CreateFakePillData();
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@{@"senses" : @[fakeSense], @"pills" : @[fakePill]}, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
                fakePill = nil;
                fakeSense = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENPairedDevices object", ^{
                [[responseObj should] beKindOfClass:[SENPairedDevices class]];
            });
            
            it(@"should have a paired sense", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedSense]) should] beYes];
            });
            
            it(@"should have a paired pill", ^{
                SENPairedDevices* devices = responseObj;
                [[@([devices hasPairedPill]) should] beYes];
            });
            
            it(@"should contain a proper sense metadata object", ^{
                SENPairedDevices* devices = responseObj;
                SENSenseMetadata* senseMetadata = [devices activeSenseMetadata];
                [[[senseMetadata uniqueId] should] equal:fakeSense[@"id"]];
            });
            
            it(@"should contain a proper pill metadata object", ^{
                SENPairedDevices* devices = responseObj;
                SENPillMetadata* pillMetadata = [devices activePillMetadata];
                [[[pillMetadata uniqueId] should] equal:fakePill[@"id"]];
            });
            
        });
        
        context(@"multiple senses, where 1 is inactive", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSDictionary* activeSense = nil;
            __block NSDictionary* inactiveSense = nil;
            
            beforeEach(^{
                activeSense = CreateFakeSenseData(YES);
                inactiveSense = CreateFakeSenseData(NO);
                
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@{@"senses" : @[activeSense, inactiveSense]}, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
                activeSense = nil;
                inactiveSense = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENPairedDevices object", ^{
                [[responseObj should] beKindOfClass:[SENPairedDevices class]];
            });
            
            it(@"should return 2 Sense metdata objects", ^{
                SENPairedDevices* devices = responseObj;
                [[@([[devices senses] count]) should] equal:@2];
            });
            
            it(@"should return 0 Pill metdata objects", ^{
                SENPairedDevices* devices = responseObj;
                [[@([[devices pills] count]) should] equal:@0];
            });
            
            it(@"should return 1 active Sense, and 1 inactive Sense", ^{
                SENPairedDevices* devices = responseObj;
                SENSenseMetadata* firstSense = [[devices senses] firstObject];
                SENSenseMetadata* lastSense = [[devices senses] lastObject];
                [[@([firstSense isActive]) should] beYes];
                [[@([lastSense isActive]) should] beNo];
            });
            
        });
        
    });
    
    describe(@"+ getPairingInfo", ^{
        
        context(@"no sense paired to account", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairedDevices:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseObj = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should not return any data", ^{
                [[responseObj should] beNil];
            });
            
        });
        
        context(@"sense paired to account", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSNumber* accountsPairedToSense = nil;
            
            beforeEach(^{
                NSDictionary* fakePairingInfo = CreateFakePairingInfo();
                accountsPairedToSense = fakePairingInfo[@"paired_accounts"];
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(fakePairingInfo, nil);
                    return nil;
                }];
                
                [SENAPIDevice getPairingInfo:^(id data, NSError *error) {
                    apiError = error;
                    responseObj = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                accountsPairedToSense = nil;
                apiError = nil;
                responseObj = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should return a SENDevicePairingInfo object", ^{
                [[responseObj should] beKindOfClass:[SENDevicePairingInfo class]];
            });
            
            it(@"should return same account paired count", ^{
                SENDevicePairingInfo* pairingInfo = responseObj;
                [[[pairingInfo pairedAccounts] should] equal:accountsPairedToSense];
            });
            
        });
        
    });
    
    describe(@"+ unregisterPill:completion", ^{
        
        context(@"no error is encountered", ^{
           
            __block BOOL calledBack = NO;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSDictionary* fakePillData = CreateFakePillData();
                SENPillMetadata* pillMetadata = [[SENPillMetadata alloc] initWithDictionary:fakePillData];
                [SENAPIDevice unregisterPill:pillMetadata completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                calledBack = YES;
                apiError = nil;
            });
            
            it(@"should callback", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"no pill id in metadata", ^{
            
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSMutableDictionary* fakePillData = [CreateFakePillData() mutableCopy];
                [fakePillData removeObjectForKey:@"id"];
                SENPillMetadata* pillMetadata = [[SENPillMetadata alloc] initWithDictionary:fakePillData];
                [SENAPIDevice unregisterPill:pillMetadata completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
            });
            
            it(@"should not return an invalid param error", ^{
                [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
            });
            
        });
        
    });
    
    describe(@"+ unregisterSense:completion", ^{
        
        context(@"no error is encountered", ^{
            
            __block BOOL calledBack = NO;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSDictionary* fakeSenseData = CreateFakeSenseData(YES);
                SENSenseMetadata* senseMetadata = [[SENSenseMetadata alloc] initWithDictionary:fakeSenseData];
                [SENAPIDevice unregisterSense:senseMetadata completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                calledBack = YES;
                apiError = nil;
            });
            
            it(@"should callback", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"no sense id in metadata", ^{
            
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSMutableDictionary* fakeSenseData = [CreateFakeSenseData(YES) mutableCopy];
                [fakeSenseData removeObjectForKey:@"id"];
                SENSenseMetadata* senseMetadata = [[SENSenseMetadata alloc] initWithDictionary:fakeSenseData];
                [SENAPIDevice unregisterSense:senseMetadata completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
            });
            
            it(@"should not return an invalid param error", ^{
                [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
            });
            
        });
        
    });
    
    describe(@"+ removeAssociationsToSense:completion", ^{
        
        context(@"no error is encountered", ^{
            
            __block BOOL calledBack = NO;
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSDictionary* fakeSenseData = CreateFakeSenseData(YES);
                SENSenseMetadata* senseMetadata = [[SENSenseMetadata alloc] initWithDictionary:fakeSenseData];
                [SENAPIDevice removeAssociationsToSense:senseMetadata completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                calledBack = YES;
                apiError = nil;
            });
            
            it(@"should callback", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
        });
        
        context(@"no sense id in metadata", ^{
            
            __block NSError* apiError = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                NSMutableDictionary* fakeSenseData = [CreateFakeSenseData(YES) mutableCopy];
                [fakeSenseData removeObjectForKey:@"id"];
                SENSenseMetadata* senseMetadata = [[SENSenseMetadata alloc] initWithDictionary:fakeSenseData];
                [SENAPIDevice removeAssociationsToSense:senseMetadata completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
            });
            
            it(@"should not return an invalid param error", ^{
                [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
            });
            
        });
        
    });
    
    describe(@"+getOTAStatus", ^{
        
        context(@"api returned an error", ^{
            
            __block SENDFUStatus* status = nil;
            __block NSError* otaError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:)
                         withBlock:^id(NSArray *params) {
                             SENAPIDataBlock cb = [params lastObject];
                             cb (nil, [NSError errorWithDomain:@"test"
                                                          code:-1
                                                      userInfo:nil]);
                             return nil;
                         }];
                
                [SENAPIDevice getOTAStatus:^(id data, NSError *error) {
                    status = data;
                    otaError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should not return a status", ^{
                [[status should] beNil];
            });
            
            it(@"should return an api error", ^{
                [[otaError should] beNonNil];
            });
            
        });
        
        context(@"api returned a required status", ^{
            
            __block SENDFUStatus* status = nil;
            __block NSError* otaError = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:)
                         withBlock:^id(NSArray *params) {
                             SENAPIDataBlock cb = [params lastObject];
                             cb (@{@"status" : @"REQUIRED"}, nil);
                             return nil;
                         }];
                
                [SENAPIDevice getOTAStatus:^(id data, NSError *error) {
                    status = data;
                    otaError = error;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"should return a required state", ^{
                [[status should] beNonNil];
                [[@([status currentState]) should] equal:@(SENDFUStateRequired)];
            });
            
            it(@"should not return an api error", ^{
                [[otaError should] beNil];
            });
            
        });
        
    });
    
    describe(@"+issueIntentToSwapWithDeviceId:completion:", ^{
        
        context(@"api return successfully", ^{
            
            __block NSError* apiError = nil;
            __block id responseData = nil;
            __block NSString* apiPath = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    apiPath = [params firstObject];
                    cb (@{@"status" : @"OK"}, nil);
                    return nil;
                }];
                
                [SENAPIDevice issueIntentToSwapWithDeviceId:@"abc" completion:^(id data, NSError *error) {
                    apiError = error;
                    responseData = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseData = nil;
                apiPath = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have made a request to correct path", ^{
                [[apiPath should] equal:@"v2/devices/swap"];
            });
            
            it(@"should return a upgrade status", ^{
                [[responseData should] beKindOfClass:[SENSwapStatus class]];
            });
            
            it(@"should return an OK response", ^{
                SENSwapStatus* status = responseData;
                SENSwapResponse response = [status response];
                [[@(response) should] equal:@(SENSwapResponseOk)];
            });
            
        });
        
        context(@"api returns an error status", ^{
            
            __block NSError* apiError = nil;
            __block id responseData = nil;
            __block NSString* apiPath = nil;
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    apiPath = [params firstObject];
                    cb (@{@"status" : @"NEW_SENSE_PAIRED_TO_DIFFERENT_ACCOUNT"}, nil);
                    return nil;
                }];
                
                [SENAPIDevice issueIntentToSwapWithDeviceId:@"abc" completion:^(id data, NSError *error) {
                    apiError = error;
                    responseData = data;
                }];
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
                apiError = nil;
                responseData = nil;
                apiPath = nil;
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have made a request to correct path", ^{
                [[apiPath should] equal:@"v2/devices/swap"];
            });
            
            it(@"should return a upgrade status", ^{
                [[responseData should] beKindOfClass:[SENSwapStatus class]];
            });
            
            it(@"should return a paired to another response", ^{
                SENSwapStatus* status = responseData;
                SENSwapResponse response = [status response];
                [[@(response) should] equal:@(SENSwapResponsePairedToAnother)];
            });
            
        });
        
    });
    
});

SPEC_END