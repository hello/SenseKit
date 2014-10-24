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
    
    describe(@"+ getPairedDevices", ^{
        
        beforeAll(^{
            [[LSNocilla sharedInstance] start];
        });
        
        afterAll(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        it(@"should return empty array", ^{
            
            __block NSArray* devices = nil;
            stubRequest(@"GET", @".*".regex).andReturn(200).withBody(@"[]").withHeader(@"Content-Type", @"application/json");
            [SENAPIDevice getPairedDevices:^(NSArray* data, NSError *error) {
                devices = data;
            }];
            [[expectFutureValue(devices) shouldEventually] beNonNil];
            
        });
        
    });
    
    describe(@"+ devicesFromRawResponse", ^{
        
        it(@"should return an empty array", ^{
            
            NSArray* devices = [SENAPIDevice devicesFromRawResponse:@[]];
            [[devices should] beNonNil];
            
        });
        
        it(@"should return 1 SENDevice object", ^{
            
            NSArray* deviceResponse = @[@{@"device_id" : @"1", @"type" : @"SENSE", @"state" : @"NORMAL"}];
            NSArray* devices = [SENAPIDevice devicesFromRawResponse:deviceResponse];
            [[@([devices count]) should] equal:@(1)];
            
            id device = [devices lastObject];
            [[device should] beKindOfClass:[SENDevice class]];
        });
        
        it(@"last_updated and firmware version should be set", ^{
            NSString* version = @"alpha-1";
            NSArray* deviceResponse = @[
                @{@"device_id" : @"1",
                  @"type" : @"SENSE",
                  @"state" : @"NORMAL",
                  @"firmware_version" : version,
                  @"last_updated" : @"1412730626330"}
            ];
            
            SENDevice* device = [SENAPIDevice devicesFromRawResponse:deviceResponse][0];
            [[[device lastSeen] should] beKindOfClass:[NSDate class]];
            [[[device firmwareVersion] should] equal:version];
        });
        
    });
    
    describe(@"unregister devices", ^{
        
        beforeAll(^{
            [[LSNocilla sharedInstance] start];
            stubRequest(@"DELETE", @".*".regex).andReturn(204).withHeader(@"Content-Type", @"application/json");
        });
        
        afterAll(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        context(@"+unregisterPill:completion", ^{
            
            it(@"should return error with invalid argument error", ^{
                
                __block NSError* apiError = nil;
                SENDevice* device = [[SENDevice alloc] init];
                [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(@([apiError code])) shouldEventually] equal:@(SENAPIDeviceErrorInvalidParam)];
                
                device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                        type:SENDeviceTypeSense
                                                       state:SENDeviceStateNormal
                                             firmwareVersion:@"1"
                                                    lastSeen:[NSDate date]];
                
                [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(@([apiError code])) shouldEventually] equal:@(SENAPIDeviceErrorInvalidParam)];
                
            });
            
            it(@"should return with no error", ^{
                
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypePill
                                                                  state:SENDeviceStateNormal
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                
                __block NSError* apiError = nil;
                [SENAPIDevice unregisterPill:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(apiError) shouldEventually] beNil];
                
            });
            
        });
        
        context(@"+unregisterSense:completion", ^{
            
            it(@"should return error with invalid argument error", ^{
                
                __block NSError* apiError = nil;
                SENDevice* device = [[SENDevice alloc] init];
                [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(@([apiError code])) shouldEventually] equal:@(SENAPIDeviceErrorInvalidParam)];
                
                device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                        type:SENDeviceTypePill
                                                       state:SENDeviceStateNormal
                                             firmwareVersion:@"1"
                                                    lastSeen:[NSDate date]];
                
                [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(@([apiError code])) shouldEventually] equal:@(SENAPIDeviceErrorInvalidParam)];
                
            });
            
            it(@"should return with no error", ^{
                
                SENDevice* device = [[SENDevice alloc] initWithDeviceId:@"1"
                                                                   type:SENDeviceTypeSense
                                                                  state:SENDeviceStateNormal
                                                        firmwareVersion:@"1"
                                                               lastSeen:[NSDate date]];
                
                __block NSError* apiError = nil;
                [SENAPIDevice unregisterSense:device completion:^(id data, NSError *error) {
                    apiError = error;
                }];
                [[expectFutureValue(apiError) shouldEventually] beNil];
                
            });
            
        });
        
    });
    
});

SPEC_END