#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>
#import <SenseKit/SENAPIDevice.h>

NSDictionary* (^CreateFakeSenseData)(void) = ^(void) {
    return @{@"id" : @"1",
             @"firmware_version" : @"1",
             @"last_updated" : @([NSDate timeIntervalSinceReferenceDate]),
             @"state" : @"NORMAL",
             @"color" : @"BLACK",
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
                fakeSense = CreateFakeSenseData();
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
                SENSenseMetadata* senseMetadata = [devices senseMetadata];
                [[[senseMetadata uniqueId] should] equal:fakeSense[@"id"]];
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
                SENPillMetadata* pillMetadata = [devices pillMetadata];
                [[[pillMetadata uniqueId] should] equal:fakePill[@"id"]];
            });
        
        });
        
        context(@"a pill and sense is paired", ^{
            
            __block NSError* apiError = nil;
            __block id responseObj = nil;
            __block NSDictionary* fakePill = nil;
            __block NSDictionary* fakeSense = nil;
            
            beforeEach(^{
                fakeSense = CreateFakeSenseData();
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
                SENSenseMetadata* senseMetadata = [devices senseMetadata];
                [[[senseMetadata uniqueId] should] equal:fakeSense[@"id"]];
            });
            
            it(@"should contain a proper pill metadata object", ^{
                SENPairedDevices* devices = responseObj;
                SENPillMetadata* pillMetadata = [devices pillMetadata];
                [[[pillMetadata uniqueId] should] equal:fakePill[@"id"]];
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
                
                NSDictionary* fakeSenseData = CreateFakeSenseData();
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
                
                NSMutableDictionary* fakeSenseData = [CreateFakeSenseData() mutableCopy];
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
                
                NSDictionary* fakeSenseData = CreateFakeSenseData();
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
                
                NSMutableDictionary* fakeSenseData = [CreateFakeSenseData() mutableCopy];
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
    
});

SPEC_END