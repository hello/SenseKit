#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPIDevice+Private.h>
#import <SenseKit/SENDevice.h>

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
        
    });
    
});

SPEC_END