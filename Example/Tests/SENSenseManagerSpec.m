#import <Kiwi/Kiwi.h>
#import "SENSenseManager+Private.h"
#import "SENSense.h"
#import "SENSenseMessage.pb.h"

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
    
});

SPEC_END