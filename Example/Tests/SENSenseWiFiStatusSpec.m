//
//  SENSenseWiFiStatusSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 7/22/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSenseWiFiStatus.h>
#import <SenseKit/SENSenseMessage.pb.h>

SPEC_BEGIN(SENSenseWiFiStatusSpec)

describe(@"SENSenseWiFiStatus", ^{
    
    describe(@"-initWithMessage:", ^{
        
        context(@"initialized with connected message", ^{
            
            __block SENSenseWiFiStatus* status;
            
            beforeAll(^{
                SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
                [builder setWifiState:WiFiStateConnected];
                [builder setVersion:1];
                [builder setType:SENSenseMessageTypeConnectionState];
                SENSenseMessage* message = [builder build];
                status = [[SENSenseWiFiStatus alloc] initWithMessage:message];
            });
            
            it(@"should not report an error", ^{
                [[@([status encounteredError]) should] equal:@(NO)];
            });
            
            it(@"should report that it is connected", ^{
                [[@([status isConnected]) should] equal:@(YES)];
            });
            
            it(@"should indicate state as connected to server", ^{
                [[@([status state]) should] equal:@(SENWiFiConnectionStateConnectedToServer)];
            });
            
            it(@"should not contain http status code", ^{
                [[[status httpStatusCode] should] beNil];
            });
            
            it(@"should have 0 for socket error code", ^{
                [[@([status socketErrorCode]) should] equal:@(0)];
            });
            
        });
        
        context(@"initialized with connecting message", ^{
            
            __block SENSenseWiFiStatus* status;
            
            beforeAll(^{
                SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
                [builder setWifiState:WiFiStateWlanConnecting];
                [builder setVersion:1];
                [builder setType:SENSenseMessageTypeConnectionState];
                SENSenseMessage* message = [builder build];
                status = [[SENSenseWiFiStatus alloc] initWithMessage:message];
            });
            
            it(@"should not report an error", ^{
                [[@([status encounteredError]) should] equal:@(NO)];
            });
            
            it(@"should report that it is NOT connected", ^{
                [[@([status isConnected]) should] equal:@(NO)];
            });
            
            it(@"should indicate state as connecting", ^{
                [[@([status state]) should] equal:@(SENWiFiConnectionStateConnectingToNetwork)];
            });
            
            it(@"should not contain http status code", ^{
                [[[status httpStatusCode] should] beNil];
            });
            
            it(@"should have 0 for socket error code", ^{
                [[@([status socketErrorCode]) should] equal:@(0)];
            });
            
        });
        
        context(@"initialized with SSL failed message", ^{
            
            __block SENSenseWiFiStatus* status;
            __block NSString* httpStatus = nil;
            
            beforeAll(^{
                httpStatus = @"404";
                SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
                [builder setWifiState:WiFiStateSslFail];
                [builder setVersion:1];
                [builder setType:SENSenseMessageTypeConnectionState];
                [builder setHttpResponseCode:httpStatus];
                SENSenseMessage* message = [builder build];
                status = [[SENSenseWiFiStatus alloc] initWithMessage:message];
            });
            
            it(@"should report an error", ^{
                [[@([status encounteredError]) should] equal:@(YES)];
            });
            
            it(@"should report that it is NOT connected", ^{
                [[@([status isConnected]) should] equal:@(NO)];
            });
            
            it(@"should indicate state as SSL failure", ^{
                [[@([status state]) should] equal:@(SENWiFiConnectionStateSSLFailure)];
            });
            
            it(@"should contain http status code", ^{
                [[[status httpStatusCode] should] equal:httpStatus];
            });
            
            it(@"should have 0 for socket error code", ^{
                [[@([status socketErrorCode]) should] equal:@(0)];
            });
            
        });
        
        context(@"initialized with a message regarding currently connected wifi", ^{
            
            __block SENSenseWiFiStatus* status;
            
            beforeAll(^{
                SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
                [builder setVersion:1];
                [builder setType:SENSenseMessageTypeGetWifiEndpoint];
                [builder setWifiSsid:@"hello"];
                [builder setWifiState:WiFiStateIpObtained];
                SENSenseMessage* message = [builder build];
                status = [[SENSenseWiFiStatus alloc] initWithMessage:message];
            });
            
            it(@"should not report an error", ^{
                [[@([status encounteredError]) should] equal:@(NO)];
            });
            
            it(@"should report that it is connected", ^{
                [[@([status isConnected]) should] equal:@(YES)];
            });
            
            it(@"should not contain http status code", ^{
                [[[status httpStatusCode] should] beNil];
            });
            
            it(@"should have 0 for socket error code", ^{
                [[@([status socketErrorCode]) should] equal:@(0)];
            });
            
        });
        
    });
    
});

SPEC_END
