//
//  SENSenseManager.m
//  Pods
//
//  Created by Jimmy Lu on 8/22/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <CoreBluetooth/CoreBluetooth.h>
#import <LGBluetooth/LGBluetooth.h>

#import "LGCentralManager.h"
#import "LGPeripheral.h"

#import "SENSenseManager.h"
#import "SENSense+Protected.h"
#import "SENSenseMessage.pb.h"

static CGFloat const kSENSenseDefaultTimeout = 5;

static NSString* const kSENSenseErrorDomain = @"is.hello.ble";
static NSString* const kSENSenseServiceID = @"0000FEE1-1212-EFDE-1523-785FEABCD123";
static NSString* const kSENSenseCharacteristicInputId = @"BEEB";
static NSString* const kSENSenseCharacteristicResponseId = @"B00B";
static NSInteger const kSENSensePacketSize = 20;
static NSInteger const kSENSenseMessageVersion = 0;

@interface SENSenseManager()

@property (nonatomic, strong, readwrite) SENSense* sense;

@end

@implementation SENSenseManager

+ (BOOL)scanForSense:(void(^)(NSArray* senses))completion {
    return [self scanForSenseWithTimeout:kSENSenseDefaultTimeout
                              completion:completion];
}

+ (BOOL)scanForSenseWithTimeout:(NSTimeInterval)timeout
                     completion:(void(^)(NSArray* senses))completion {
    LGCentralManager* btManager = [LGCentralManager sharedInstance];
    if (![btManager isCentralReady]) return NO;
    
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
                                             [senses addObject:sense];
                                             
                                             // uncomment the blow code to talk to Pang :)
//                                             if ([[device name] hasSuffix:@"2D"]) {
//                                                 sense = [[SENSense alloc] initWithPeripheral:device];
//                                                 [senses addObject:sense];
//                                             }
                                         }
                                     }
                                     if (completion) completion(senses);
                                 }];
    return YES;
}

+ (void)stopScan {
    [[LGCentralManager sharedInstance] stopScanForPeripherals];
}

- (instancetype)initWithSense:(SENSense*)sense {
    self = [super init];
    if (self) {
        [self setSense:sense];
    }
    return self;
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
    if (!completion) return; // even if we do stuff, what would it be for?
    if ([characteristicIds count] == 0) {
        completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                             code:SENSenseManagerErrorCodeInvalidArgument
                                         userInfo:nil]);
        return;
    }
    
    LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        completion (nil, [NSError errorWithDomain:kSENSenseErrorDomain
                                             code:SENSenseManagerErrorCodeNoDeviceSpecified
                                         userInfo:nil]);
        return;
    }
    
    [peripheral connectWithTimeout:kSENSenseDefaultTimeout completion:^(NSError *error) {
        if (error != nil) {
            completion (nil, error);
        }
        CBUUID* serviceId = [CBUUID UUIDWithString:kSENSenseServiceID];
        [peripheral discoverServices:@[serviceId] completion:^(NSArray *services, NSError *error) {
            if (error != nil || [services count] != 1) {
                completion (nil, error?error:[NSError errorWithDomain:kSENSenseErrorDomain
                                                                 code:SENSenseManagerErrorCodeUnexpectedResponse
                                                             userInfo:nil]);
                return;
            }
            LGService* lgService = [services firstObject];
            [lgService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                if (error != nil) {
                    completion (nil, error);
                    return;
                }
                NSMutableDictionary* abilities = [NSMutableDictionary dictionaryWithCapacity:2];
                NSString* uuid = nil;
                for (LGCharacteristic* characteristic in characteristics) {
                    uuid = [[characteristic UUIDString] uppercaseString];
                    if ([characteristicIds containsObject:uuid]) {
                        [abilities setValue:characteristic forKey:uuid];
                    }
                }
                completion (abilities, nil);
            }];
        }];
    }];
}

- (void)characteristics:(SENSenseCompletionBlock)completion {
    [self characteristicsFor:[NSMutableSet setWithObjects:kSENSenseCharacteristicInputId,
                                                          kSENSenseCharacteristicResponseId,
                                                          nil]
                  completion:completion];
}

- (void)failWithBlock:(SENSenseFailureBlock)failure andCode:(SENSenseManagerErrorCode)code {
    if (failure) {
        failure ([NSError errorWithDomain:kSENSenseErrorDomain
                                     code:code
                                 userInfo:nil]);
    }
}

#pragma mark - (Private) Sending Data

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
    
    for (uint8_t packetNumber = 1; packetNumber <= numberOfPackets; packetNumber++) {
        packetData = [NSMutableData data];
        NSInteger payloadSize = additionalPacketSize; // first byte should always be a sequence number
        
        if ([helloBlePackets count] == 0) {
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
 * @param success: the success callback when command was sent
 * @param failure: the failure callback called when command failed
 */
- (void)sendMessage:(SENSenseMessage*)message
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    __block LGPeripheral* peripheral = [[self sense] peripheral];
    if (peripheral == nil) {
        return [self failWithBlock:failure andCode:SENSenseManagerErrorCodeNoDeviceSpecified];
    }
    
    __weak typeof(self) weakSelf = self;
    [self characteristics:^(id response, NSError *error) {
        if (error != nil) {
            if (failure) failure (error);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;

        NSDictionary* readWrite = response;
        LGCharacteristic* writer = [readWrite valueForKey:kSENSenseCharacteristicInputId];
        LGCharacteristic* reader = [readWrite valueForKey:kSENSenseCharacteristicResponseId];
        // according to the Pang, every command will send a response back with the same
        // packet that was sent to the device as confirmation
        if (writer == nil || reader == nil) {
            return [strongSelf failWithBlock:failure
                                     andCode:SENSenseManagerErrorCodeUnexpectedResponse];
        }
        
        NSArray* packets = [strongSelf blePackets:message];
        
        if ([packets count] > 0) {
            [strongSelf sendPackets:packets
                               from:0
                             ofType:[message type]
                      throughWriter:writer
                         withReader:reader
                            success:^(id response) {
                                if (success) success (nil); // do not need to forward response
                            }
                            failure:failure];
        } else {
            [strongSelf failWithBlock:failure
                              andCode:SENSenseManagerErrorCodeInvalidCommand];
        }

    }];
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
             ofType:(SENSenseMessageType)type
      throughWriter:(LGCharacteristic*)writer
         withReader:(LGCharacteristic*)reader
            success:(SENSenseSuccessBlock)success
            failure:(SENSenseFailureBlock)failure {
    
    if (index < [packets count]) {
        NSData* data = packets[index];
        __weak typeof(self) weakSelf = self;
        [writer writeValue:data completion:^(NSError *error) {
            if (error != nil) {
                if (failure) failure (error);
                return;
            }
            
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf sendPackets:packets
                                   from:index+1
                                 ofType:type
                          throughWriter:writer
                             withReader:reader
                                success:success
                                failure:failure];
            }

        }];
    } else {
        __weak typeof(self) weakSelf = self;
        [self readResponseWith:reader success:^(id response) {
            SENSenseMessage* senseResponse = response;
            // it is successful IFF type of response is the same as message type
            if (senseResponse != nil && [senseResponse type] == type) {
                if (success) success(nil);
            } else {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    [strongSelf failWithBlock:failure
                                      andCode:SENSenseManagerErrorCodeUnexpectedResponse];
                }
            }
        } failure:failure];
    }
}

#pragma mark - (Private) Reading Response

- (SENSenseManagerErrorCode)errorCodeFrom:(ErrorType)senseErrorType {
    SENSenseManagerErrorCode code = SENSenseManagerErrorCodeNone;
    switch (senseErrorType) {
        case ErrorTypeTimeOut:
            code = SENSenseManagerErrorCodeTimeout;
            break;
        case ErrorTypeDeviceAlreadyPaired:
            code = SENSenseManagerErrorCodeDeviceAlreadyPaired;
            break;
        default:
            code = SENSenseManagerErrorCodeUnexpectedResponse;
            break;
    }
    return code;
}

/**
 * Parse the data back in to a SENSenseMessage protobuf object, following the
 * HELLO BLE PACKET FORMAT.
 * @param data: the raw data returned from the device
 * @param error: a pointer to an error object that will be set if one encountered.
 * @return a SENSenseMessage
 */
- (SENSenseMessage*)parseData:(NSData*)data error:(NSError**)error {
    SENSenseMessage* response = nil;
    SENSenseManagerErrorCode errCode = SENSenseManagerErrorCodeNone;
    
    uint8_t firstPacket[kSENSensePacketSize];
    [data getBytes:&firstPacket length:kSENSensePacketSize];
    
    if (firstPacket[0] == 0) {
        // check to see number of packets
        uint8_t packets = firstPacket[1];
        NSMutableData* actualPayload = [NSMutableData data];
        NSInteger length = [data length];
        int actualPayloadBytesRead = 0, offset, location = 0, payloadLength;
        
        for (uint8_t seq = 0; seq < packets ; seq++) {
            offset = seq == 0 ? 2 : 1;
            location = actualPayloadBytesRead + offset + location;
            payloadLength = kSENSensePacketSize - offset;
            
            uint8_t payloadPacket[MIN(payloadLength, length-location)];
            size_t payloadPacketSize = sizeof(payloadPacket);
            [data getBytes:payloadPacket range:NSMakeRange(location, payloadPacketSize)];
            
            [actualPayload appendBytes:payloadPacket length:payloadPacketSize];
            actualPayloadBytesRead += payloadPacketSize;
        }
        @try {
            response = [SENSenseMessage parseFromData:actualPayload];
            if ([response hasError]) {
                errCode = [self errorCodeFrom:[response error]];
            }
        }
        @catch (NSException *exception) {
            errCode = SENSenseManagerErrorCodeUnexpectedResponse;
        }
    } else {
        errCode = SENSenseManagerErrorCodeUnexpectedResponse;
    }
    
    if (errCode != SENSenseManagerErrorCodeNone && error != NULL) {
        *error = [NSError errorWithDomain:kSENSenseErrorDomain
                                     code:SENSenseManagerErrorCodeUnexpectedResponse
                                 userInfo:nil];
    }
    return response;
}

/**
 * Read the response from the characteristic specified.
 * @param reader: the response characteristic
 * @param success: the block to call when everything was read correctly
 * @param failure: the block to call if an error was encountered
 */
- (void)readResponseWith:(LGCharacteristic*)reader
                 success:(SENSenseSuccessBlock)success
                 failure:(SENSenseFailureBlock)failure {
    __weak typeof(self) weakSelf = self;
    [reader readValueWithBlock:^(NSData *data, NSError *error) {
        if (error != nil) {
            if (failure) failure (error);
            return;
        }
        
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) return;
        
        NSError* parseError = nil;
        SENSenseMessage* response = [strongSelf parseData:data error:&parseError];
        
        if (parseError != nil) {
            if (failure) failure (parseError);
        } else {
            if (success) success (response);
        }
    }];
}

#pragma mark - Pairing

- (void)enablePairingMode:(BOOL)enable
                  success:(SENSenseSuccessBlock)success
                  failure:(SENSenseFailureBlock)failure {
    SENSenseMessageType type
        = enable
        ? SENSenseMessageTypeSwitchToPairingMode
        : SENSenseMessageTypeSwitchToNormalMode;
    
    SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
    [builder setType:type];
    [builder setVersion:kSENSenseMessageVersion];
    [self sendMessage:[builder build] success:success failure:failure];
}

- (void)removeOtherPairedDevices:(SENSenseSuccessBlock)success
                         failure:(SENSenseFailureBlock)failure {
    SENSenseMessageBuilder* builder = [[SENSenseMessageBuilder alloc] init];
    [builder setType:SENSenseMessageTypeEreasePairedPhone];
    [builder setVersion:kSENSenseMessageVersion];
    [self sendMessage:[builder build] success:success failure:failure];
}

#pragma mark - Time

- (void)setTime:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getTime:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

#pragma mark - Wifi

- (void)setWifiEndPoint:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getWifiEndPoint:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)scanForWifi:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)stopWifiScan:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

#pragma mark - Alarms

- (void)setAlarms:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

- (void)getAlarms:(SENSenseCompletionBlock)completion {
    // TODO (jimmy): Firmware not yet implemented
}

@end
