//
//  SENSenseManager.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>

#import <CoreBluetooth/CoreBluetooth.h>

#import <LGBluetooth/LGBluetooth.h>

#import "SENSenseManager.h"
#import "SENSense.h"
#import "SENSenseMessage.pb.h"
#import "SENSenseWiFiStatus.h"
#import "SENLocalPreferences.h"

static CGFloat const kSENSenseDefaultTimeout = 20.0f;
static CGFloat const kSENSenseScanTimeout = 10.0f;
static CGFloat const kSENSenseRescanTimeout = 8.0f;
static CGFloat const kSENSenseSetWifiTimeout = 70.0f; // firmware suggestion.  fw times out at 60s
static CGFloat const kSENSenseScanWifiTimeout = 45.0f; // firmware actually suggests 60, but 45 seems to work consistently
static CGFloat const kSENSensePillPairTimeout = 45.0f; // firmware timesout at 20, we need this to be longer.
static CGFloat const kSENSenseLinkAccountTimeout = 45.0f;
static CGFloat const kSENSenseUnsubscribeTimeout = 3.0f;
static CGFloat const kSENSenseLedTimeout = 30.0f;

static NSString* const SENSensePeripheralUUIDKey = @"sense.uuid";

static NSString* const kSENSenseErrorDomain = @"is.hello.ble";
static NSString* const kSENSenseServiceID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";
static NSString* const kSENSenseCharacteristicInputId = @"BEEB";
static NSString* const kSENSenseCharacteristicResponseId = @"B00B";
static NSInteger const kSENSensePacketSize = 20;
static NSInteger const kSENSenseAppVersion = 0;

typedef BOOL(^SENSenseUpdateBlock)(id response);

/**
 * This represents the version of the protobuf that has been updated.  Sense
 * returns this value, which allows us to determine how to proceed with certain
 * commands.  Though, we really should find a better way to communicate this as
 * we will only know this value from a response from Sense and that means if the
 * command we sent initially is now different, we wouldn't know until the response
 * comes back
 */
typedef NS_ENUM(NSUInteger, SENSenseProtobufVersion) {
    SENSenseProtobufVersionPVT = 0,
    SENSenseProtobufVersionWEP = 1
};

@interface SENSenseManager()

@property (nonatomic, assign, readwrite) long messageVersion;
@property (nonatomic, assign, readwrite, getter=isValid) BOOL valid;
@property (nonatomic, strong, readwrite) SENSense* sense;
@property (nonatomic, strong, readwrite) id disconnectNotifyObserver;
@property (nonatomic, strong, readwrite) NSMutableDictionary* disconnectObservers;
@property (nonatomic, strong, readwrite) NSMutableDictionary* messageSuccessCallbacks;
@property (nonatomic, strong, readwrite) NSMutableDictionary* messageFailureCallbacks;
@property (nonatomic, strong, readwrite) NSMutableDictionary* messageUpdateCallbacks;
@property (nonatomic, strong, readwrite) NSMutableDictionary* messageTimeoutTimers;
@property (nonatomic, strong, readwrite) NSMutableDictionary* messageTypeForCallbacks;

@end

@implementation SENSenseManager

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

+ (void)lastConnectedSense:(void(^)(SENSense* sense, NSError* error))completion {
    if (!completion) {
        return;
    }
    
    DDLogVerbose(@"retrieving last connected Sense");
    
    [self whenBleStateAvailable:^(BOOL on) {
        if (!on) {
            completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                                 code:SENSenseManagerErrorCodeNoBLE
                                             userInfo:nil]);
            return;
        }
        
        SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
        NSString* senseUUID = [preferences userPreferenceForKey:SENSensePeripheralUUIDKey];
        NSString* deviceId = [preferences userPreferenceForKey:senseUUID];
        
        SENSense* sense = nil;
        NSError* error = nil;
        if (senseUUID && deviceId) {
            LGCentralManager* central = [LGCentralManager sharedInstance];
            DDLogVerbose(@"last connected Sense UUID %@", senseUUID);
            NSUUID* uuidObject = [[NSUUID alloc] initWithUUIDString:senseUUID];
            NSArray* peripherals = [central retrievePeripheralsWithIdentifiers:@[uuidObject]];
            if ([peripherals count] > 0) {
                DDLogVerbose(@"retrieved last connected sense");
                sense = [[SENSense alloc] initWithPeripheral:peripherals[0] andDeviceId:deviceId];
            } else {
                error = [NSError errorWithDomain:kSENSenseErrorDomain
                                            code:SENSenseManagerErrorCodeForgottenSense
                                        userInfo:nil];
            }
        } else {
            error = [NSError errorWithDomain:kSENSenseErrorDomain
                                        code:SENSenseManagerErrorCodeNeverConnectedToASense
                                    userInfo:nil];
        }
        
        completion (sense, error);
    }];
}

+ (BOOL)scanForSense:(void(^)(NSArray* senses))completion {
    return [self scanForSenseWithTimeout:kSENSenseScanTimeout
                              completion:completion];
}

+ (BOOL)scanForSenseWithTimeout:(NSTimeInterval)timeout
                     completion:(void(^)(NSArray* senses))completion {
    
    LGCentralManager* btManager = [LGCentralManager sharedInstance];
    if (![btManager isCentralReady]) return NO;
    
    DDLogVerbose(@"scanning for Sense started");
    CBUUID* serviceId = [CBUUID UUIDWithString:kSENSenseServiceID];
    [btManager scanForPeripheralsByInterval:timeout
                                   services:@[serviceId]
                                    options:nil
                                 completion:^(NSArray* peripherals) {
                                     NSMutableArray* senses = nil;
                                     NSInteger count = [peripherals count];
                                     SENSense* sense = nil;
                                     if (count > 0) {
                                         senses = [NSMutableArray arrayWithCapacity:count];
                                         for (LGPeripheral* device in peripherals) {
                                             sense = [[SENSense alloc] initWithPeripheral:device];
                                             DDLogVerbose(@"discovered sense %@", sense);
                                             [senses addObject:sense];
                                         }
                                     }
                                     DDLogVerbose(@"scan completed with %ld Sense(s) found", (long)count);
                                     if (completion) completion(senses);
                                 }];
    return YES;
}

+ (void)whenBleStateAvailable:(void(^)(BOOL on))block {
    [self whenReady:block];
}

- (instancetype)initWithSense:(SENSense*)sense {
    self = [super init];
    if (self) {
        DDLogVerbose(@"Sense manager initialized for %@, id %@", [sense name], [sense deviceId]);
        [self setSense:sense];
        [self setValid:YES];
        [self setMessageVersion:SENSenseProtobufVersionPVT];
        [self setMessageSuccessCallbacks:[NSMutableDictionary dictionary]];
        [self setMessageFailureCallbacks:[NSMutableDictionary dictionary]];
        [self setMessageUpdateCallbacks:[NSMutableDictionary dictionary]];
        [self setMessageTimeoutTimers:[NSMutableDictionary dictionary]];
        [self setMessageTypeForCallbacks:[NSMutableDictionary dictionary]];
    }
    return self;
}

#pragma mark - Errors

- (SENSenseManagerErrorCode)errorCodeFrom:(ErrorType)senseErrorType {
    switch (senseErrorType) {
        case ErrorTypeTimeOut:
            return SENSenseManagerErrorCodeTimeout;
        case ErrorTypeDeviceAlreadyPaired:
            return SENSenseManagerErrorCodeSenseAlreadyPaired;
        case ErrorTypeInternalOperationFailed:
            return SENSenseManagerErrorCodeSenseInternalFailure;
        case ErrorTypeDeviceNoMemory:
            return SENSenseManagerErrorCodeSenseOutOfMemory;
        case ErrorTypeDeviceDatabaseFull:
            return SENSenseManagerErrorCodeSenseDbFull;
        case ErrorTypeNetworkError:
            return SENSenseManagerErrorCodeSenseNetworkError;
        case ErrorTypeNoEndpointInRange:
            return SENSenseManagerErrorCodeWifiNotInRange;
        case ErrorTypeWlanConnectionError:
            return SENSenseManagerErrorCodeWLANConnection;
        case ErrorTypeFailToObtainIp:
            return SENSenseManagerErrorCodeFailToObtainIP;
        case ErrorTypeInternalDataError:
            return SENSenseManagerErrorCodeCorruptTransmission;
        case ErrorTypeWlanEndpointDeleteFailed:
            return SENSenseManagerErrorCodeWLANEndpointDeletionFailure;
        case ErrorTypeInvalidAccountId:
            return SENSenseManagerErrorCodeInvalidAccountId;
        case ErrorTypeForceDataPushFailed:
            return SENSenseManagerErrorCodeForceDataPushFailed;
        case ErrorTypeProtobufEncodeFailed:
            return SENSenseManagerErrorCodeProtobufEncodingFailed;
        case ErrorTypeProtobufDecodeFailed:
            return SENSenseManagerErrorCodeProtobufDecodingFailed;
        case ErrorTypeServerConnectionTimeout:
            return SENSenseManagerErrorCodeFailedToConnectToServer;
        default:
            return SENSenseManagerErrorCodeUnexpectedResponse;
    }
}

- (NSError*)errorWithCode:(SENSenseManagerErrorCode)code
              description:(NSString*)description
      fromUnderlyingError:(NSError*)error {
    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    if (error) userInfo[NSUnderlyingErrorKey] = error;
    if (description) userInfo[NSLocalizedDescriptionKey] = description;
    
    return [NSError errorWithDomain:kSENSenseErrorDomain
                               code:code
                           userInfo:userInfo];
}

- (void)failWithBlock:(SENSenseFailureBlock)failure andCode:(SENSenseManagerErrorCode)code {
    [self failWithBlock:failure errorCode:code description:nil];
}

- (void)failWithBlock:(SENSenseFailureBlock)failure
            errorCode:(SENSenseManagerErrorCode)code
          description:(NSString*)description {
    if (failure) {
        failure ([self errorWithCode:code description:description fromUnderlyingError:nil]);
    }
}

#pragma mark -

- (BOOL)isConnected {
    return [[[[self sense] peripheral] cbPeripheral] state] == CBPeripheralStateConnected;
}

- (void)rediscoverToConnectThen:(void(^)(NSError* error))completion {
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"rediscovering Sense %@", [[self sense] name]);
    [[self class] scanForSenseWithTimeout:kSENSenseRescanTimeout completion:^(NSArray *senses) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            BOOL foundAgain = NO;
            if ([senses count] > 0) {
                for (SENSense* sense in senses) {
                    if ([[[strongSelf sense] deviceId] isEqualToString:[sense deviceId]]) {
                        [strongSelf setSense:sense];
                        foundAgain = YES;
                        break;
                    }
                }
                
                if (foundAgain) {
                    DDLogVerbose(@"Sense rediscovered");
                    [strongSelf setValid:YES];
                    LGPeripheral* peripheral = [[strongSelf sense] peripheral];
                    [peripheral connectWithTimeout:kSENSenseDefaultTimeout completion:completion];
                }
            }
            
            if (!foundAgain && completion) {
                DDLogVerbose(@"Sense not found when trying to rediscover");
                completion ([strongSelf errorWithCode:SENSenseManagerErrorCodeInvalidated
                                          description:@"could not rediscover Sense"
                                  fromUnderlyingError:nil]);
            }
            
        }
    }];
}

/**
 * Connect to Sense then invoke the completion block.  If already connected, completion
 * block will be immediately invoked.
 * param: completion block to invoke when connected, or when there is an error
 */
- (void)connectThen:(void(^)(NSError* error))completion {
    if (!completion) return; // even if we do stuff, what would it be for?
    
    LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        completion ([self errorWithCode:SENSenseManagerErrorCodeNoDeviceSpecified
                            description:@"cannot connect to a non-existent Sense"
                    fromUnderlyingError:nil]);
        return;
    }
    
    if (![self isConnected]) {
        __weak typeof(self) weakSelf = self;
        
        id postConnectionBlock = ^(NSError* error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            NSError* connectionError = nil;
            if (error == nil) {
                [strongSelf saveSenseUUID];
                [strongSelf listenForUnexpectedDisconnects];
            } else {
                NSString* format = @"unable to connect to Sense due to %@";
                NSString* description = [NSString stringWithFormat:format, [error localizedDescription]];
                connectionError = [strongSelf errorWithCode:SENSenseManagerErrorCodeCannotConnectToSense
                                                description:description
                                        fromUnderlyingError:error];
                // if you fail to connect to the peripheral once, calling LGPeripheral's
                // connectWithTimeout:completion: will actually never call you back
                // until you obtain a new new instance by scanning again
                [strongSelf setValid:NO];
            }
            completion (connectionError);
        };
        
        if (![self isValid]) {
            [self rediscoverToConnectThen:postConnectionBlock];
        } else {
            DDLogVerbose(@"attempting to connect to Sense %@", [[self sense] name]);
            [peripheral connectWithTimeout:kSENSenseDefaultTimeout
                                completion:postConnectionBlock];
        }
    } else {
        DDLogVerbose(@"Sense %@ is already connected", [[self sense] name]);
        completion (nil);
    }
}

/**
 * Obtain LGCharacteristic objects that match the characteristicIds specified.  On completion, the
 * response in the completion block will be a NSDictionary with the characteristicId as the key and
 * the value being the LGCharacteristic object.
 *
 * To obtain such characteristics, this method will connect to the initialized device, scan for the
 * device service and then retrieve the matching characteristics.
 *
 * @param characteristicIds: a set of characteristicIds to retrieve
 * @param completion: the block to call upon completion
 */
- (void)characteristicsFor:(NSSet*)characteristicIds completion:(SENSenseCompletionBlock)completion {
    [self characteristicsForServiceId:kSENSenseServiceID
                    characteristicIds:characteristicIds
                           completion:completion];
}

/**
 * Discover characteristics for the specified serviceId.  Upon completion, the
 * characteristics will be returned in a dictionary where key is the id of the
 * characteristic and value is an instance of LGCharacteristic.  If an error
 * is encountered, response will be nil and an NSError is returned instead.
 * @param serviceUUID:       the service UUID to discover
 * @param characteristicIds: a set of characteristicIds that the service broadcasts
 * @param completion:        the block to invoke when done
 */
- (void)characteristicsForServiceId:(NSString*)serviceUUID
                  characteristicIds:(NSSet*)characteristicIds
                         completion:(SENSenseCompletionBlock)completion {
    if (!completion) return; // even if we do stuff, what would it be for?
    if ([characteristicIds count] == 0) {
        completion (nil, [self errorWithCode:SENSenseManagerErrorCodeInvalidArgument
                                 description:@"no characteristic ids specified"
                         fromUnderlyingError:nil]);
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [self connectThen:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        if (error) {
            completion (nil, [strongSelf errorWithCode:SENSenseManagerErrorCodeConnectionFailed
                                           description:@"could not connect to Sense"
                                   fromUnderlyingError:error]);
            return;
        }
        
        LGPeripheral* peripheral = [[strongSelf sense] peripheral];
        [strongSelf characteristicsWithIds:characteristicIds
                           insideServiceId:serviceUUID
                             forPeripheral:peripheral
                                completion:completion];
        
    }];
}

- (void)characteristics:(SENSenseCompletionBlock)completion {
    [self characteristicsFor:[NSMutableSet setWithObjects:kSENSenseCharacteristicInputId,
                                                          kSENSenseCharacteristicResponseId,
                                                          nil]
                  completion:completion];
}

#pragma mark - (Private) Sending Data

- (SENSenseMessageBuilder*)messageBuilderWithType:(SENSenseMessageType)type {
    SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
    [builder setType:type];
    [builder setVersion:[self messageVersion]];
    [builder setAppVersion:kSENSenseAppVersion];
    return builder;
}

/**
 * Format the SENSenseMessage in to HELLO BLE PACKET FORMAT where data is divided
 * in to packets with max size kSENSensePacketSize.  Each packet is stored in
 * order in an array and returned.
 * @param message: a sense message to format
 * @return a sorted array of hello ble packets
 */
- (NSArray*)blePackets:(SENSenseMessage*)message {
    NSInteger initialPayloadSize = kSENSensePacketSize - 2;
    NSInteger additionalPacketSize = kSENSensePacketSize - 1;
    NSData* payload = [message data];
    NSInteger totalPayloadSize = [payload length];
    NSInteger addlPacketSize = MAX(0, totalPayloadSize- initialPayloadSize);
    
    double packets = ceil((double)addlPacketSize / (additionalPacketSize));
    uint8_t numberOfPackets = (uint8_t)(1 + packets);
    
    NSMutableArray* helloBlePackets = [NSMutableArray array];
    NSMutableData* packetData = nil;
    int bytesWritten = 0;
    
    for (uint8_t packetNumber = 0; packetNumber < numberOfPackets; packetNumber++) {
        packetData = [NSMutableData data];
        NSInteger payloadSize = additionalPacketSize; // first byte should always be a sequence number
        
        if (packetNumber == 0) {
            payloadSize = initialPayloadSize;
            uint8_t seq = 0;
            [packetData appendData:[NSData dataWithBytes:&seq
                                                  length:sizeof(seq)]];
            [packetData appendData:[NSData dataWithBytes:&numberOfPackets
                                                  length:sizeof(numberOfPackets)]];
        } else {
            [packetData appendData:[NSData dataWithBytes:&packetNumber
                                                  length:sizeof(packetNumber)]];
        }
        
        uint8_t actualSize = MIN(totalPayloadSize - bytesWritten, payloadSize);
        uint8_t partial[actualSize];
        [payload getBytes:&partial range:NSMakeRange(bytesWritten, actualSize)];
        
        [packetData appendBytes:partial length:actualSize];
        [helloBlePackets addObject:packetData];
        
        bytesWritten += actualSize;
    }
    
    return helloBlePackets;
}

/**
 * Send a message to the initialized Sense through the main service.
 * @param command: the command to send
 * @param timeout: time in seconds before operation fails with timeout error
 * @param success: the success callback when command was sent
 * @param failure: the failure callback called when command failed
 */
- (void)sendMessage:(SENSenseMessage*)message
            timeout:(NSTimeInterval)timeout
             update:(SENSenseUpdateBlock)update
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    __block LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        return [self failWithBlock:failure andCode:SENSenseManagerErrorCodeNoDeviceSpecified];
    }
    
    DDLogVerbose(@"sending message of type %u", [message type]);
    
    __weak typeof(self) weakSelf = self;
    [self characteristics:^(id response, NSError *error) {
        if (error != nil) {
            if (failure) failure (error);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;

        LGCharacteristic* writer = [response valueForKey:kSENSenseCharacteristicInputId];
        LGCharacteristic* reader = [response valueForKey:kSENSenseCharacteristicResponseId];
        if (writer == nil || reader == nil) {
            return [strongSelf failWithBlock:failure
                                   errorCode:SENSenseManagerErrorCodeUnexpectedResponse
                                 description:@"could not discover characteristics"];
        }
        
        NSArray* packets = [strongSelf blePackets:message];
        
        if ([packets count] > 0) {
            DDLogVerbose(@"# of packets being sent %ld", (long)[packets count]);
            __block NSMutableArray* allPackets = nil;
            __block NSNumber* totalPackets = nil;
            __block typeof(reader) blockReader = reader;
            
            NSString* cbKey = [self cacheMessageCallbacks:update
                                                  success:success
                                             failureBlock:failure
                                               subscriber:blockReader
                                           forMessageType:[message type]];
            
            [strongSelf scheduleMessageTimeOut:timeout withKey:cbKey];
            
            [reader setNotifyValue:YES completion:^(NSError *error) {
                if (error != nil) {
                    if (failure) failure (error);
                    return;
                }
                [strongSelf sendPackets:packets
                                   from:0
                          throughWriter:writer
                                success:nil
                                failure:^(NSError *error) {
                                    DDLogVerbose(@"message failed to send unsuccessfully with error %@, unsubscribing", error);
                                    [strongSelf fireFailureMsgCbWithCbKey:cbKey andError:error];
                                }];
            } onUpdate:^(NSData *data, NSError *error) {
                [strongSelf handleResponseUpdate:data
                                           error:error
                                  forMessageType:[message type]
                                      allPackets:&allPackets
                                    totalPackets:&totalPackets
                                         success:^(id response) {
                                             SENSenseUpdateBlock updateBlock = [strongSelf messageUpdateCallbacks][cbKey];
                                             // if there's no update block or there is one and block tells us to finish
                                             if (!updateBlock || (updateBlock && updateBlock(response))) {
                                                 DDLogVerbose(@"message response received, unsubscribing");
                                                 [strongSelf fireSuccessMsgCbWithCbKey:cbKey andResponse:response];
                                             } else {
                                                 DDLogVerbose(@"partial message response received, waiting for next set");
                                                 // cannot nil out the allPackets array b/c that will deallocate the instance
                                                 // in the block and messages will be sent to a deallocated instance
                                                 [allPackets removeAllObjects];
                                                 totalPackets = @(1);
                                             }
                                         } failure:^(NSError *error) {
                                             DDLogVerbose(@"handling message response encountered error %@, unsubscribing", error);
                                             [strongSelf fireFailureMsgCbWithCbKey:cbKey andError:error];
                                         }];
            }];
        } else {
            DDLogWarn(@"# of packets from message is 0");
            [strongSelf failWithBlock:failure andCode:SENSenseManagerErrorCodeInvalidCommand];
        }
        
    }];
}

- (void)unsubscribeWith:(LGCharacteristic*)subscriber andCall:(void(^)(id result))callback withResult:(id)result {
    if ([self isConnected] && subscriber) {
        // YES, this looks ugly, but if device is disconnected right during setNotifyValue:completion,
        // the completion block is never called back and thus caller will just hang.  Therefore,
        // if unsuscribing is taking longer than X seconds, just make the callback
        __block BOOL called = NO;
        __block void(^cb)(id result) = callback;
        
        void(^call)(id result) = ^(id result) {
            if (!called) {
                called = YES;
                DDLogVerbose(@"making callback");
                cb(result);
            }
        };
        
        [subscriber setNotifyValue:NO completion:^(__unused NSError *subscriptionError) {
            DDLogVerbose(@"unsubscribed");
            call(result);
        }];
        
        NSTimeInterval delayInSeconds = kSENSenseUnsubscribeTimeout;
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            call(result);
        });
    } else {
        DDLogVerbose(@"making callback b/c Sense is not connected or subscriber is not defined");
        callback (result);
    }
}

- (NSString*)cacheMessageCallbacks:(SENSenseUpdateBlock)updateBlock
                           success:(SENSenseSuccessBlock)successBlock
                      failureBlock:(SENSenseFailureBlock)failureBlock
                        subscriber:(LGCharacteristic*)subscriber
                    forMessageType:(SENSenseMessageType)type {
    
    NSString* key = [[NSUUID UUID] UUIDString];
    
    [[self messageTypeForCallbacks] setValue:@(type) forKey:key];
    
    if (updateBlock) {
        [[self messageUpdateCallbacks] setValue:[updateBlock copy] forKey:key];
    }
    
    __weak typeof(self) weakSelf = self;
    if (successBlock) {
        __block SENSenseSuccessBlock sBlock = successBlock;
        [[self messageSuccessCallbacks] setValue:[^(id response) {
            [weakSelf unsubscribeWith:subscriber andCall:sBlock withResult:response];
        } copy] forKey:key];
    }
    
    if (failureBlock) {
        __block SENSenseFailureBlock fBlock = failureBlock;
        [[self messageFailureCallbacks] setValue:[^(NSError* error) {
            [weakSelf unsubscribeWith:subscriber andCall:fBlock withResult:error];
        } copy] forKey:key];
    }
    
    return key;
}

- (void)clearAllMessageCallbacks {
    DDLogVerbose(@"clearing all message call backs");
    for (NSTimer* timer in [[self messageTimeoutTimers] allValues]) {
        [timer invalidate];
    }
    [[self messageTimeoutTimers] removeAllObjects];
    [[self messageFailureCallbacks] removeAllObjects];
    [[self messageSuccessCallbacks] removeAllObjects];
    [[self messageUpdateCallbacks] removeAllObjects];
    [[self messageTypeForCallbacks] removeAllObjects];
}

- (void)clearMessageCallbacksForKey:(NSString*)key {
    if (key != nil) {
        [[self messageFailureCallbacks] removeObjectForKey:key];
        [[self messageSuccessCallbacks] removeObjectForKey:key];
        [[self messageUpdateCallbacks] removeObjectForKey:key];
        [[self messageTypeForCallbacks] removeObjectForKey:key];
    }
}

- (void)fireSuccessMsgCbWithCbKey:(NSString*)cbKey andResponse:(id)response {
    [self cancelMessageTimeOutWithCbKey:cbKey];
    if (cbKey != nil) {
        SENSenseSuccessBlock callback = [[self messageSuccessCallbacks] valueForKey:cbKey];
        if (callback) {
            DDLogVerbose(@"firing success callback");
            callback (response);
        }
        [self clearMessageCallbacksForKey:cbKey];
    }
}

- (void)fireFailureMsgCbWithCbKey:(NSString*)cbKey andError:(NSError*)error {
    [self cancelMessageTimeOutWithCbKey:cbKey];
    if (cbKey != nil) {
        SENSenseFailureBlock callback = [[self messageFailureCallbacks] valueForKey:cbKey];
        if (callback) {
            DDLogVerbose(@"firing failure callback");
            callback (error);
        }
        [self clearMessageCallbacksForKey:cbKey];
    }
}

/**
 * Send all packets, recursively, starting from the specified index in the array.
 * If an error was encountered, recusion will stop and failure block will be called
 * right away.
 *
 * @param packets: the packets to send
 * @param from: index of the packet to send in this iteration
 * @param type: the type of the sense message
 * @param writer: the input characteristic
 * @param reader: the output characteristic
 * @param success: the block to call when all packets have been sent
 * @param failure: the block to call if any error was encountered along the way
 */
- (void)sendPackets:(NSArray*)packets
               from:(NSInteger)index
      throughWriter:(LGCharacteristic*)writer
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    if (![self isConnected]) {
        [self failWithBlock:failure andCode:SENSenseManagerErrorCodeConnectionFailed];
        return;
    }
    
    if (index < [packets count]) {
        NSData* data = packets[index];
        __weak typeof(self) weakSelf = self;
        [writer writeValue:data completion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            if (error != nil) {
                if (failure) failure (error);
                return;
            }
            
            if (strongSelf) {
                [strongSelf sendPackets:packets
                                   from:index+1
                          throughWriter:writer
                                success:success
                                failure:failure];
            }
            
        }];
    } else {
        if (success) success (nil);
    }
}

#pragma mark - (Private) Reading Response

- (BOOL)response:(SENSenseMessage*)response matchesRequestType:(SENSenseMessageType)type {
    SENSenseMessageType responseType = [response type];
    BOOL matches = YES;
    if (type == SENSenseMessageTypeStartWifiscan) {
        matches = responseType == SENSenseMessageTypeStartWifiscan
                    || responseType == SENSenseMessageTypeStopWifiscan;
    } else if (type == SENSenseMessageTypeSetWifiEndpoint) {
        matches = responseType == SENSenseMessageTypeSetWifiEndpoint
                    || responseType == SENSenseMessageTypeConnectionState;
    } else {
        matches = type == responseType;
    }
    return matches;
}

/**
 * Handle response from Sense until it's done sending data back.  Since response
 * will likely be split in to multiple packets, we need to append all data as they
 * arrive until all packets are received.
 *
 * @param data:         the data from 1 update of a response
 * @param error:        any error that may have come from the response
 * @param type:         the type of the message this response is meant for
 * @param allPackets:   the address to the storage holding all data responses
 * @param totalPackets: the address to an object that holds the value of the
 *                      total packets determined from the first update/packet
 * @param success:      the block to invoke when all updates completed successfully
 * @param failure:      the block to invoke when any update reported an error or
 *                      if the full response is not what was expected for the type
 */
- (void)handleResponseUpdate:(NSData*)data
                       error:(NSError*)error
              forMessageType:(SENSenseMessageType)type
                  allPackets:(NSMutableArray**)allPackets
                totalPackets:(NSNumber**)totalPackets
                     success:(SENSenseSuccessBlock)success
                     failure:(SENSenseFailureBlock)failure {
    
    uint8_t packet[[data length]];
    [data getBytes:&packet length:kSENSensePacketSize];
    if (sizeof(packet) >= 2 && error == nil) {
        uint8_t seq = packet[0];
        if (seq == 0) {
            *totalPackets = @(packet[1]);
            *allPackets = [NSMutableArray arrayWithCapacity:[*totalPackets intValue]];
        }
        
        [*allPackets addObject:data];
        
        if ([*totalPackets intValue] == 1 || [*totalPackets intValue] - 1 == seq) {
            NSError* parseError = nil;
            SENSenseMessage* responseMsg = [self messageFromBlePackets:*allPackets error:&parseError];
            if (parseError || [responseMsg hasError]) {
                NSInteger code
                    = parseError != nil
                    ? [parseError code]
                    : SENSenseManagerErrorCodeUnexpectedResponse;
                NSString* desc = [NSString stringWithFormat:@"response error from command %ld", (long)type];
                [self failWithBlock:failure errorCode:code description:desc];
            } else if (![self response:responseMsg matchesRequestType:type]) {
                DDLogWarn(@"ble response %u does not match request %u", [responseMsg type], type);
                NSString* desc = [NSString stringWithFormat:@"response %ld not expected for command %ld",
                                  (long)[responseMsg type], (long)type];
                [self failWithBlock:nil errorCode:SENSenseManagerErrorCodeOutOfOrderResponse description:desc];
            } else {
                // jimmy 3/15/2015: firmware updated message version to pivot
                // on how certain messages are handled so for us to send them
                // the correct version, we need to see what it sends back first
                // and use that message going forwared.  We should remove this
                // once we are sure all users have the latest firmware version.
                [self setMessageVersion:[responseMsg version]];
                if (success) success (responseMsg);
            }
        } // else, wait for next update
    } else {
        [self failWithBlock:failure
                  errorCode:SENSenseManagerErrorCodeUnexpectedResponse
                description:@"invalid response size"];
    }
}

/**
 * Parse the data back in to a SENSenseMessage protobuf object, following the
 * HELLO BLE PACKET FORMAT.
 * @param packets: all hello ble format packets returned from Sense
 * @param error:   a pointer to an error object that will be set if one encountered.
 * @return         a SENSenseMessage
 */
- (SENSenseMessage*)messageFromBlePackets:(NSArray*)packets error:(NSError**)error {
    SENSenseMessage* response = nil;
    NSString* errorDesc = nil;
    SENSenseManagerErrorCode errCode = SENSenseManagerErrorCodeNone;
    NSMutableData* actualPayload = [NSMutableData data];
    
    int index = 0;
    for (NSData* packetData in packets) {
        int offset = index == 0 ? 2 : 1;
        long packetLength = [packetData length] - offset;
        uint8_t payloadPacket[packetLength];
        long length = sizeof(payloadPacket);
        [packetData getBytes:&payloadPacket range:NSMakeRange(offset, packetLength)];
        [actualPayload appendBytes:payloadPacket length:length];
        index++;
    }
    
    @try {
        response = [SENSenseMessage parseFromData:actualPayload];
        if ([response hasError]) {
            errCode = [self errorCodeFrom:[response error]];
            errorDesc = @"error returned in ble response";
            DDLogVerbose(@"ble response has an error with device code %ld", (long)errCode);
        }
    } @catch (NSException *exception) {
        DDLogWarn(@"parsing ble protobuf message encountered exception %@", exception);
        errCode = SENSenseManagerErrorCodeUnexpectedResponse;
        errorDesc = [exception description];
    }
    
    if (errCode != SENSenseManagerErrorCodeNone && error != NULL) {
        *error = [self errorWithCode:errCode description:errorDesc fromUnderlyingError:nil];
    }
    return response;
}

#pragma mark - Local state

/**
 * Save the currently managed Sense's peripheral UUID for faster access.  The
 * device ID is also required to be saved because that is currently stored in
 * the peripheral's advertisement data, which is not provided upon retrieving
 * peripherals by UUID.
 */
- (void)saveSenseUUID {
    NSString* senseUUID = [[[self sense] peripheral] UUIDString];
    NSString* deviceId  = [[self sense] deviceId];
    if (senseUUID && deviceId) {
        DDLogVerbose(@"saving sense uuid %@", senseUUID);
        SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
        [preferences setUserPreference:senseUUID forKey:SENSensePeripheralUUIDKey];
        [preferences setUserPreference:[[self sense] deviceId] forKey:senseUUID];
    }
}

- (void)forgetConnectedSenseUUID {
    SENLocalPreferences* preferences = [SENLocalPreferences sharedPreferences];
    NSString* uuid = [preferences userPreferenceForKey:SENSensePeripheralUUIDKey];
    if (uuid) {
        [preferences setUserPreference:nil forKey:uuid];
        [preferences setUserPreference:nil forKey:SENSensePeripheralUUIDKey];
    }
}

#pragma mark - (Private) Timeout

- (void)scheduleMessageTimeOut:(NSTimeInterval)timeOutInSecs withKey:(NSString*)key {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:timeOutInSecs
                                                      target:self
                                                    selector:@selector(timedOut:)
                                                    userInfo:key
                                                     repeats:NO];
    [[self messageTimeoutTimers] setValue:timer forKey:key];
}

- (void)cancelMessageTimeOutWithCbKey:(NSString*)cbKey {
    NSTimer* timer = [[self messageTimeoutTimers] objectForKey:cbKey];
    DDLogVerbose(@"cancelling time out timer %@", timer);
    [timer invalidate];
    [[self messageTimeoutTimers] removeObjectForKey:cbKey];
}

- (void)timedOut:(NSTimer*)timer {
    NSString* cbKey = [timer userInfo];
    DDLogVerbose(@"Sense operation timed out");
    if (cbKey != nil) {
        [self cancelMessageTimeOutWithCbKey:cbKey];
        
        SENSenseFailureBlock failureCb = [[self messageFailureCallbacks] valueForKey:cbKey];
        if (failureCb) {
            NSNumber* messageType = [[self messageTypeForCallbacks] objectForKey:cbKey];
            NSString* errDesc = [NSString stringWithFormat:@"ble message timed out for type %ld",
                                 [messageType longValue]];
            
            DDLogVerbose(@"%@", errDesc);
            
            failureCb ( [self errorWithCode:SENSenseManagerErrorCodeTimeout
                                description:errDesc
                        fromUnderlyingError:nil]);
        } else {
            DDLogVerbose(@"failure block not defined for time out");
        }
        
        [self clearMessageCallbacksForKey:cbKey];
    }
}

#pragma mark - Connection Updates

- (BOOL)shouldStopUpdatesFromResponse:(SENSenseMessage*)response
                       forMessageType:(SENSenseMessageType)type
                               status:(SENSenseWiFiStatus**)status {
    
    SENSenseWiFiStatus* update = nil;
    
    BOOL stop = NO;
    BOOL stopWiFiScan = [response type] == SENSenseMessageTypeStopWifiscan && type == SENSenseMessageTypeStartWifiscan;
    BOOL updatingConnectionState = [response type] == SENSenseMessageTypeConnectionState;
    BOOL oldFwOrNoUpdates = [response type] == type && type != SENSenseMessageTypeStartWifiscan;
    BOOL hasError = [response type] == SENSenseMessageTypeError || [response hasError];
    
    if (stopWiFiScan) {
        stop = YES;
        DDLogVerbose(@"stopping wifi scan");
    } else if (updatingConnectionState) {
        update = [[SENSenseWiFiStatus alloc] initWithMessage:response];
        stop = [update isConnected] || [update encounteredError];
        DDLogVerbose(@"got connection update %@, stop ? %@", update, stop ? @"y" : @"n");
    } else if (oldFwOrNoUpdates) {
        stop = YES;
        DDLogVerbose(@"old fw or message without updates");
    } else if (hasError) {
        stop = YES;
        DDLogVerbose(@"stopping updates due to hitting an error");
    }
    
    if (status != NULL && update) {
        *status = update;
    }
    
    return stop;
}

#pragma mark - Pairing

/**
 * Pairing with Sense requires a simple subscription to the output characteristic,
 * which will force authorization from the device wanting to pair
 *
 * @param success: the block to invoke when pairing completed successfully
 * @param failure: the block to invoke when an error was encountered
 */
- (void)pair:(SENSenseSuccessBlock)success
     failure:(SENSenseFailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    DDLogVerbose(@"attempting to pair with Sense");
    [self characteristicsFor:[NSSet setWithObject:kSENSenseCharacteristicResponseId]
                  completion:^(id response, NSError *error) {
                      __strong typeof(weakSelf) strongSelf = weakSelf;
                      if (!strongSelf) return;
                      
                      NSDictionary* readWrite = response;
                      __weak LGCharacteristic* reader = [readWrite valueForKey:kSENSenseCharacteristicResponseId];
                      
                      if (reader == nil) {
                          return [strongSelf failWithBlock:failure
                                                 errorCode:SENSenseManagerErrorCodeUnexpectedResponse
                                               description:@"could not discover response characteristic when pairing"];
                      }
                      
                      NSString* cbKey = [strongSelf cacheMessageCallbacks:nil
                                                                  success:success
                                                             failureBlock:failure
                                                               subscriber:reader
                                                           forMessageType:100]; // no message type for pairing
                      
                      [strongSelf scheduleMessageTimeOut:kSENSenseDefaultTimeout withKey:cbKey];
                      
                      [reader setNotifyValue:YES completion:^(NSError *error) {
                          if (error != nil) {
                              DDLogVerbose(@"failed to pair with Sense with error %@", error);
                              [strongSelf fireFailureMsgCbWithCbKey:cbKey andError:error];
                          } else {
                              DDLogVerbose(@"Sense paired successfully");
                              [strongSelf fireSuccessMsgCbWithCbKey:cbKey andResponse:nil];
                          }
                      }];
                  }];
}

- (void)enablePairingMode:(BOOL)enable
                  success:(SENSenseSuccessBlock)success
                  failure:(SENSenseFailureBlock)failure {
    DDLogVerbose(@"%@ pairing mode on Sense", enable?@"enabling":@"disabling");
    SENSenseMessageType type = enable ? SENSenseMessageTypeSwitchToPairingMode : SENSenseMessageTypeSwitchToNormalMode;
    [self sendMessage:[[self messageBuilderWithType:type] build]
              timeout:kSENSenseDefaultTimeout
               update:nil
              success:success
              failure:failure];
}

- (void)removeOtherPairedDevices:(SENSenseSuccessBlock)success
                         failure:(SENSenseFailureBlock)failure {
    DDLogVerbose(@"removing paired devices from Sense");
    SENSenseMessageType type = SENSenseMessageTypeEreasePairedPhone;
    [self sendMessage:[[self messageBuilderWithType:type] build]
              timeout:kSENSenseDefaultTimeout
               update:nil
              success:success
              failure:failure];
}

- (void)linkAccount:(NSString*)accountAccessToken
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    DDLogVerbose(@"linking account %@... through Sense", accountAccessToken?[accountAccessToken substringToIndex:3]:@"");
    SENSenseMessageType type = SENSenseMessageTypePairSense;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setAccountId:accountAccessToken];
    [self sendMessage:[builder build]
              timeout:kSENSenseLinkAccountTimeout
               update:nil
              success:success
              failure:failure];
}

- (void)pairWithPill:(NSString*)accountAccessToken
             success:(SENSenseSuccessBlock)success
             failure:(SENSenseFailureBlock)failure {
    DDLogVerbose(@"pairing with pill for account %@... through Sense", accountAccessToken?[accountAccessToken substringToIndex:3]:@"");
    SENSenseMessageType type = SENSenseMessageTypePairPill;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setAccountId:accountAccessToken];
    [self sendMessage:[builder build]
              timeout:kSENSensePillPairTimeout
               update:nil
              success:success
              failure:failure];
}

#pragma mark - Wifi

+ (BOOL)isWepKeyValid:(NSString*)key {
    NSUInteger len = [key length];
    BOOL valid = len > 0 && len % 2 == 0;
    
    if (valid) {
        NSCharacterSet* hexCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet];
        valid = [[key uppercaseString] rangeOfCharacterFromSet:hexCharacters].location == NSNotFound;
    }
    
    return valid;
}

/**
 * Convert the wep network key (generated from the passphrase) to a base 16 bytes,
 * which is the only way the firmware will work with WEP security.  If the network
 * key contains a 0 in the middle of the value, it will also
 */
- (NSData*)dataValueForWepNetworkKey:(NSString*)networkKey error:(NSError**)error {
    DDLogVerbose(@"formatting password for wifi with wep security");
    
    NSUInteger len = [networkKey length];
    
    if (![[self class] isWepKeyValid:networkKey]) {
        if (error != NULL) {
            NSString* errorMsg = @"invalid wep network key";
            DDLogVerbose(@"%@", errorMsg);
            *error = [self errorWithCode:SENSenseManagerErrorCodeInvalidWEPKey
                             description:errorMsg
                     fromUnderlyingError:nil];
        }
        return nil;
    }
    
    const char* chars = [networkKey cStringUsingEncoding:NSUTF8StringEncoding];
    NSMutableData* mutableData = [NSMutableData dataWithCapacity:len/2];
    
    int i = 0;
    char bytes[3] = {'\0', '\0', '\0'};
    unsigned long convertedLong;
    while (i < len) {
        bytes[0] = chars[i++];
        bytes[1] = chars[i++];
        convertedLong = strtol(bytes, NULL, 16);
        [mutableData appendBytes:&convertedLong length:1];
    }
    
    return mutableData;
}

- (NSData*)dataValueForWiFiPassword:(NSString*)password
                   withSecurityType:(SENWifiEndpointSecurityType)type
                    formattingError:(NSError**)error {
    switch (type) {
        case SENWifiEndpointSecurityTypeOpen:
            return nil;
        case SENWifiEndpointSecurityTypeWep: {
            if ([self messageVersion] == SENSenseProtobufVersionPVT) {
                return [self dataValueForWepNetworkKey:password error:error];
            } // else, let it go through to default like all other types
        }
        default:
            return [password dataUsingEncoding:NSUTF8StringEncoding];
    }
}

- (void)setWiFi:(NSString*)ssid
       password:(NSString*)password
   securityType:(SENWifiEndpointSecurityType)securityType
         update:(SENSenseWiFiStateUpdateBlock)update
        success:(SENSenseSuccessBlock)success
        failure:(SENSenseFailureBlock)failure {
    
    DDLogVerbose(@"setting wifi on Sense with ssid %@", ssid);
    NSError* passwordError = nil;
    NSData* passwordData = [self dataValueForWiFiPassword:password
                                         withSecurityType:securityType
                                          formattingError:&passwordError];
    
    if (passwordError != nil) {
        if (failure) {
            failure (passwordError);
        }
        return;
    }
    
    SENSenseMessageType type = SENSenseMessageTypeSetWifiEndpoint;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [builder setSecurityType:securityType];
    [builder setWifiSsid:ssid];
    [builder setWifiPassword:passwordData];
    
    __weak typeof(self) weakSelf = self;
    [self sendMessage:[builder build]
              timeout:kSENSenseSetWifiTimeout
               update:^BOOL(SENSenseMessage* response) {
                   __strong typeof(weakSelf) strongSelf = weakSelf;
                   SENSenseWiFiStatus* status = nil;
                   BOOL stop = [strongSelf shouldStopUpdatesFromResponse:response
                                                          forMessageType:type
                                                                  status:&status];
                   if (update) {
                       update (status);
                   }
                   return stop;
               }
              success:success
              failure:failure];
}

- (void)scanForWifiNetworksInCountry:(NSString*)countryCode
                             success:(SENSenseSuccessBlock)success
                             failure:(SENSenseFailureBlock)failure {
    
    DDLogVerbose(@"scanning for wifi networks Sense can see");
    SENSenseMessageType type = SENSenseMessageTypeStartWifiscan;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    
    if (countryCode) {
        [builder setCountryCode:countryCode];
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSMutableArray* wifis = [NSMutableArray array];
    [self sendMessage:[builder build]
              timeout:kSENSenseScanWifiTimeout
               update:^BOOL(SENSenseMessage* updateResponse) {
                   __strong typeof(weakSelf) strongSelf = weakSelf;
                   if ([updateResponse wifisDetected]) {
                       [[updateResponse wifisDetected] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                           DDLogVerbose(@"found wifi %@", [((SENWifiEndpoint*)obj) ssid]);
                           if ([obj isKindOfClass:[SENWifiEndpoint class]]) {
                               SENWifiEndpoint* endpoint = obj;
                               // Sense may return hidden networks, with no SSID or ssid
                               // that is an empty string
                               if ([endpoint hasSsid] && [[endpoint ssid] length] > 0) {
                                   [wifis addObject:obj];
                               } else {
                                   DDLogVerbose(@"skipping network with no ssid");
                               }
                           }
                       }];
                   }
                   return [strongSelf shouldStopUpdatesFromResponse:updateResponse
                                                     forMessageType:type
                                                             status:nil];
               }
              success:^(SENSenseMessage* response) {
                  [[response wifisDetected] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                      DDLogVerbose(@"found wifi %@", [((SENWifiEndpoint*)obj) ssid]);
                      [wifis addObject:obj];
                  }];
                  [wifis sortUsingComparator:^NSComparisonResult(SENWifiEndpoint* wifi1, SENWifiEndpoint* wifi2) {
                      NSComparisonResult result = NSOrderedSame;
                      if ([wifi1 rssi] < [wifi2 rssi]) {
                          result = NSOrderedDescending;
                      } else if ([wifi1 rssi] > [wifi2 rssi]) {
                          result = NSOrderedAscending;
                      }
                      return result;
                  }];
                  if (success) success (wifis);
              }
              failure:failure];
}

- (void)scanForWifiNetworks:(SENSenseSuccessBlock)success
                    failure:(SENSenseFailureBlock)failure {
    
    [self scanForWifiNetworksInCountry:nil success:success failure:failure];
    
}

- (void)getConfiguredWiFi:(void(^)(NSString* ssid, SENSenseWiFiStatus* status))success
                  failure:(SENSenseFailureBlock)failure {
    
    if (!success) {
        if (failure) failure ([self errorWithCode:SENSenseManagerErrorCodeInvalidArgument
                                      description:@"no callback set when asking for configured wifi"
                              fromUnderlyingError:nil]);
        return;
    }
    
    DDLogVerbose(@"retrieving configured wifi on Sense");
    SENSenseMessageType type = SENSenseMessageTypeGetWifiEndpoint;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [self sendMessage:[builder build]
              timeout:kSENSenseDefaultTimeout
               update:nil
              success:^(SENSenseMessage* response) {
                  SENSenseWiFiStatus* status = [[SENSenseWiFiStatus alloc] initWithMessage:response];
                  DDLogVerbose(@"wifi %@ is in state %@", [response wifiSsid], status);
                  success ([response wifiSsid], status);
              }
              failure:failure];
}

#pragma mark - Factory Reset

- (void)resetToFactoryState:(SENSenseSuccessBlock)success
                    failure:(SENSenseFailureBlock)failure {
    
    DDLogVerbose(@"resetting Sense to factory state");
    SENSenseMessageType type = SENSenseMessageTypeFactoryReset;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    
    __weak typeof(self) weakSelf = self;
    [self sendMessage:[builder build]
              timeout:kSENSenseDefaultTimeout
               update:nil
              success:^(id response) {
                  [weakSelf forgetConnectedSenseUUID];
                  if (success) {
                      success (response);
                  }
              }
              failure:failure];
}

#pragma mark - Signal Strength / RSSI

- (void)currentRSSI:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    DDLogVerbose(@"getting current Sense rssi value");
    __weak typeof(self) weakSelf = self;
    [self connectThen:^(NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            if (failure) failure (error);
        } else if (strongSelf) {
            [strongSelf readPeripheralRSSI:success failure:failure];
        }
    }];
}

- (void)readPeripheralRSSI:(SENSenseSuccessBlock)success
                   failure:(SENSenseFailureBlock)failure {
    [[[self sense] peripheral] readRSSIValueCompletion:^(NSNumber *RSSI, NSError *error) {
        if (error) {
            if (failure) failure (error);
        } else if (success) {
            DDLogVerbose(@"Sense's rssi value is %ld", [RSSI longValue]);
            success (RSSI);
        }
    }];
}

#pragma mark - LED

- (SENSenseMessageType)commandForLEDState:(SENSenseLEDState)state {
    SENSenseMessageType type = SENSenseMessageTypeLedOff;
    switch (state) {
        case SENSenseLEDStatePair:
            type = SENSenseMessageTypeLedTrippy;
            break;
        case SENSenseLEDStateActivity:
            type = SENSenseMessageTypeLedBusy;
            break;
        case SENSenseLEDStateSuccess:
            type = SENSenseMessageTypeLedSuccess;
            break;
        case SENSenseLEDStateOff:
        default:
            type = SENSenseMessageTypeLedOff;
            break;
    }
    return type;
}

- (void)setLED:(SENSenseLEDState)state
    completion:(SENSenseCompletionBlock)completion {
    DDLogVerbose(@"setting LED to state %ld", (long)state);
    SENSenseMessageType type = [self commandForLEDState:state];
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    
    [self sendMessage:[builder build]
              timeout:kSENSenseLedTimeout
               update:nil
              success:^(id response) {
                  if (completion) completion (response, nil);
              } failure:^(NSError *error) {
                  if (completion) completion (nil, error);
              }];
}

#pragma mark - Data

- (void)forceDataUpload:(SENSenseCompletionBlock)completion {
    DDLogVerbose(@"forcing data upload");
    SENSenseMessageType type = SENSenseMessageTypePushData;
    SENSenseMessageBuilder* builder = [self messageBuilderWithType:type];
    [self sendMessage:[builder build]
              timeout:kSENSenseDefaultTimeout
               update:nil
              success:^(id response) {
                  if (completion) completion (response, nil);
              } failure:^(NSError *error) {
                  if (completion) completion (nil, error);
              }];
}

#pragma mark - Connections

- (void)disconnectFromSense {
    DDLogVerbose(@"manually disconnecting from Sense");
    if  ([self isConnected]) {
        __weak typeof(self) weakSelf = self;
        [[[self sense] peripheral] disconnectWithCompletion:^(NSError *error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (error == nil) {
                DDLogVerbose(@"disconnected from Sense");
            }
            [strongSelf clearAllMessageCallbacks];
            [strongSelf setValid:NO];
        }];
    }
}

- (void)listenForUnexpectedDisconnects {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    if ([self disconnectNotifyObserver] != nil) {
        [center removeObserver:[self disconnectNotifyObserver]];
    }
    
    __weak typeof(self) weakSelf = self;
    self.disconnectNotifyObserver =
    [center addObserverForName:kLGPeripheralDidDisconnect
                        object:nil
                         queue:[NSOperationQueue mainQueue]
                    usingBlock:^(NSNotification *note) {
                        __strong typeof(weakSelf) strongSelf = weakSelf;
                        
                        DDLogVerbose(@"Sense disconnected unexpectedly");
                        // if peripheral is disconnected, it is removed from
                        // scannedPeripherals in LGCentralManager, which causes
                        // the reference to SENSense's peripheral to not be
                        // recognized.  This is actually not a logic problem
                        // from the library, but also the behavior in CoreBluetooth
                        [strongSelf setValid:NO];
                        [strongSelf clearAllMessageCallbacks];
                        
                        id errorObject = [[note userInfo] valueForKey:@"error"];
                        if ([errorObject isKindOfClass:[NSError class]]) {
                            DDLogVerbose(@"error from disconnect: %@", errorObject);
                        }
                        
                        NSArray* observerIds = [[[strongSelf disconnectObservers] allKeys] mutableCopy];
                        for (NSString* observerId in observerIds) {
                            SENSenseFailureBlock block = [[strongSelf disconnectObservers] valueForKey:observerId];
                            if (block) {
                                block ([strongSelf errorWithCode:SENSenseManagerErrorCodeUnexpectedDisconnect
                                                     description:@"unexpectedly disconnected from Sense"
                                             fromUnderlyingError:nil]);
                            }
                        }
                    }];
}

- (NSString*)observeUnexpectedDisconnect:(SENSenseFailureBlock)block {
    if ([self disconnectObservers] == nil) {
        [self setDisconnectObservers:[NSMutableDictionary dictionary]];
    }
    NSString* observerId = [[NSUUID UUID] UUIDString];
    [[self disconnectObservers] setValue:[block copy] forKey:observerId];
    return observerId;
}

- (void)removeUnexpectedDisconnectObserver:(NSString*)observerId {
    if (observerId != nil) {
        [[self disconnectObservers] removeObjectForKey:observerId];
    }
}

#pragma mark - Cleanup

- (void)dealloc {
    for (NSTimer* timer in [_messageTimeoutTimers allValues]) {
        [timer invalidate];
    }
    
    if ([self isConnected]) {
        [[_sense peripheral] disconnectWithCompletion:nil];
    }
    
    if (_disconnectNotifyObserver) {
        [[NSNotificationCenter defaultCenter] removeObserver:_disconnectNotifyObserver];
    }
}

@end
