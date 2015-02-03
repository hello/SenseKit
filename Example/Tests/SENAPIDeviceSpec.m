#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENDevice.h>
#import <SenseKit/SENAPIDevice.h>

@interface SENAPIDevice (Private)

+ (SENDevice*)deviceFromRawResponse:(id)rawResponse;
+ (NSArray*)devicesFromRawResponse:(id)rawResponse;

@end

SPEC_BEGIN(SENAPIDeviceSpec)

describe(@"SENAPIDevice", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"+ getPairedDevices", ^{

        context(@"there are no paired devices", ^{

            beforeEach(^{
                [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock block = [params lastObject];
                    block(@[], nil);
                    return nil;
                }];
            });

            it(@"should return empty array", ^{
                __block NSArray* devices = nil;
                [SENAPIDevice getPairedDevices:^(NSArray* data, NSError *error) {
                    devices = data;
                }];
                [[devices should] haveCountOf:0];
                
            });
        });
        
    });
    
    describe(@"+ devicesFromRawResponse", ^{

        __block NSArray* devices;

        context(@"there are no devices", ^{

            beforeEach(^{
                devices = [SENAPIDevice devicesFromRawResponse:@[]];
            });

            it(@"should return an empty array", ^{
                [[devices should] haveCountOf:0];
            });
        });

        context(@"there is one device", ^{

            beforeEach(^{
                NSArray* deviceResponse = @[@{@"device_id" : @"1", @"type" : @"SENSE", @"state" : @"NORMAL"}];
                devices = [SENAPIDevice devicesFromRawResponse:deviceResponse];
            });

            it(@"returns 1 SENDevice object", ^{
                [[devices should] haveCountOf:1];
                id device = [devices lastObject];
                [[device should] beKindOfClass:[SENDevice class]];
            });
        });

        context(@"last_updated and firmware version are set", ^{
            NSString* version = @"alpha-1";
            NSArray* deviceResponse = @[
                @{@"device_id" : @"1",
                  @"type" : @"SENSE",
                  @"state" : @"NORMAL",
                  @"firmware_version" : version,
                  @"last_updated" : @"1412730626330"}
            ];

            it(@"sets last_updated and firmware version", ^{
                SENDevice* device = [SENAPIDevice devicesFromRawResponse:deviceResponse][0];
                [[[device lastSeen] should] beKindOfClass:[NSDate class]];
                [[[device firmwareVersion] should] equal:version];
            });

        });
    });
    
    describe(@"unregister devices", ^{

        __block SENDevice* device = nil;
        __block NSError* apiError = nil;

        beforeEach(^{
            [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, nil);
                return nil;
            }];
        });

        afterEach(^{
            device = nil;
            apiError = nil;
        });

        describe(@"+unregisterPill:completion", ^{

            context(@"device has no type", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] init];
                });

                it(@"calls the block with an invalid argument error", ^{
                    [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
                });
            });

            context(@"device is a sense", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                            type:SENDeviceTypeSense
                                                           state:SENDeviceStateNormal
                                                 firmwareVersion:@"1"
                                                        lastSeen:[NSDate date]];
                });

                it(@"calls the block with an invalid argument error", ^{
                    [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
                });
            });

            context(@"device is a pill", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                            type:SENDeviceTypePill
                                                           state:SENDeviceStateNormal
                                                 firmwareVersion:@"1"
                                                        lastSeen:[NSDate date]];
                });

                it(@"returns with no error", ^{
                    [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[apiError should] beNil];
                });
            });
        });
        
        describe(@"+unregisterSense:completion", ^{

            context(@"device has no type", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] init];
                });

                it(@"calls the block with an invalid argument error", ^{
                    [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
                });
            });

            context(@"device is a pill", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                            type:SENDeviceTypePill
                                                           state:SENDeviceStateNormal
                                                 firmwareVersion:@"1"
                                                        lastSeen:[NSDate date]];
                });

                it(@"calls the block with an invalid argument error", ^{
                    [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[@([apiError code]) should] equal:@(SENAPIDeviceErrorInvalidParam)];
                });
            });

            context(@"device is a sense", ^{

                beforeEach(^{
                    device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                            type:SENDeviceTypeSense
                                                           state:SENDeviceStateNormal
                                                 firmwareVersion:@"1"
                                                        lastSeen:[NSDate date]];
                });

                it(@"returns with no error", ^{
                    [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                        apiError = error;
                    }];
                    [[apiError should] beNil];
                });
            });
        });
        
    });
    
    describe(@"+getSenseMetaData", ^{
        
        afterEach(^{
            [SENAPIClient clearStubs];
        });
        
        it(@"should return a SENDeviceMetadata object", ^{
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(@{@"sense_id" : @"Sense",
                        @"paired_accounts" : @(1)}, nil);
                return nil;
            }];
            
            __block id metadata = nil;
            [SENAPIDevice getSenseMetaData:^(id data, NSError *error) {
                metadata = data;
            }];
            [[metadata should] beKindOfClass:[SENDeviceMetadata class]];
            
        });
        
        it(@"should fail with no metadata", ^{
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                return nil;
            }];
            
            __block id metadata = nil;
            __block NSError* metadataError = nil;
            [SENAPIDevice getSenseMetaData:^(id data, NSError *error) {
                metadata = data;
                metadataError = error;
            }];
            [[metadata should] beNil];
            [[metadataError should] beNonNil];
            
        });
        
    });
    
    describe(@"+getNumberOfAccountsForPairedSense", ^{
        
        __block NSString* senseId;
        
        beforeEach(^{
            senseId = @"123";
        });
        
        afterEach(^{
            [SENAPIClient clearStubs];
            [SENAPIDevice clearStubs];
        });
        
        it(@"should succeed when matching senseId and no error", ^{
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(@{@"sense_id" : senseId,
                        @"paired_accounts" : @(1)}, nil);
                return nil;
            }];
            
            __block NSNumber* accounts = nil;
            __block NSError* deviceError = nil;
            [SENAPIDevice getNumberOfAccountsForPairedSense:senseId completion:^(id data, NSError *error) {
                accounts = data;
                deviceError = error;
            }];
            
            [[accounts should] equal:@(1)];
            [[deviceError should] beNil];
            
        });
        
        it(@"should fail if sense id returned from server does not match ", ^{
            
            [SENAPIDevice stub:@selector(getSenseMetaData:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block ([[SENDeviceMetadata alloc] initWithDictionary:@{@"sense_id" : @"doesnotexist",
                                                                       @"paired_accounts" : @(1)}
                                                            withType:SENDeviceTypeSense], nil);
                return nil;
            }];
            
            __block NSNumber* accounts = nil;
            __block NSError* deviceError = nil;
            [SENAPIDevice getNumberOfAccountsForPairedSense:senseId completion:^(id data, NSError *error) {
                accounts = data;
                deviceError = error;
            }];
            
            [[accounts should] beNil];
            [[deviceError should] beNonNil];
            
        });
        
        it(@"should fail if API client fails ", ^{
            
            [SENAPIClient stub:@selector(GET:parameters:completion:) withBlock:^id(NSArray *params) {
                SENAPIDataBlock block = [params lastObject];
                block(nil, [NSError errorWithDomain:@"test" code:-1 userInfo:nil]);
                return nil;
            }];
            
            __block NSNumber* accounts = nil;
            __block NSError* deviceError = nil;
            [SENAPIDevice getNumberOfAccountsForPairedSense:senseId completion:^(id data, NSError *error) {
                accounts = data;
                deviceError = error;
            }];
            
            [[accounts should] beNil];
            [[deviceError should] beNonNil];
            
        });
        
    });
    
});

SPEC_END