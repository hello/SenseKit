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
    
});

SPEC_END