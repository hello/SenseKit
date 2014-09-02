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
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:nil];
            [manager enablePairingMode:YES success:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
            }];
        });
        
        it(@"should fail if sense not initialized properly", ^{
            SENSense* sense = [[SENSense alloc] init];
            SENSenseManager* manager = [[SENSenseManager alloc] initWithSense:sense];
            [manager enablePairingMode:YES success:^(id response) {
                fail(@"should not be called");
            } failure:^(NSError *error) {
                [[@([error code]) should] equal:@(SENSenseManagerErrorCodeNoDeviceSpecified)];
            }];
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
    
});

SPEC_END