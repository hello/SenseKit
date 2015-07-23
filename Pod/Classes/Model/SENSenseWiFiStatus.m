//
//  SENSenseWiFiStatus.m
//  Pods
//
//  Created by Jimmy Lu on 7/22/15.
//
//

#import "SENSenseWiFiStatus.h"
#import "SENSenseMessage.pb.h"

@interface SENSenseWiFiStatus()

@property (nonatomic, assign) SENWiFiConnectionState state;
@property (nonatomic, copy)   NSString* httpStatusCode;
@property (nonatomic, assign) NSInteger socketErrorCode;

@end

@implementation SENSenseWiFiStatus

- (instancetype)initWithMessage:(SENSenseMessage*)message {
    self = [super init];
    if (self) {
        [self extractStatusFromMessage:message];
    }
    return self;
}

- (void)extractStatusFromMessage:(SENSenseMessage*)message {
    if ([message hasHttpResponseCode]) {
        [self setHttpStatusCode:[message httpResponseCode]];
    }
    
    if ([message hasSocketErrorCode]) {
        [self setSocketErrorCode:[message socketErrorCode]];
    }
    
    if ([message hasWifiState]) {
        // connection state and wifi state's value map 1-1, with the exception
        // of unknown, which will be the default value of -1
        [self setState:(SENWiFiConnectionState)[message wifiState]];
    }
}


- (BOOL)encounteredError {
    return [self state] == SENWiFiConnectionStateSSLFailure
        || [self state] == SENWiFiConnectionStateHelloKeyFailure
        || [self state] == SENWiFiConnectionStateDNSFailed
        || [self state] == SENWiFiConnectionStateServerConnectionFailed;
}

- (BOOL)isConnected {
    return [self state] == SENWiFiConnectionStateConnectedToServer;
}

- (NSString *)description {
    static NSString* const format =  @"<SENSenseWiFiStatus state=%ld, httpStatus=%@, socketError=%ld>";
    return [NSString stringWithFormat:format, (long)[self state], [self httpStatusCode], [self socketErrorCode]];
}

@end
