// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "ProtocolBuffers.h"

// @@protoc_insertion_point(imports)

@class BatchedPillData;
@class BatchedPillDataBuilder;
@class PillData;
@class PillDataBuilder;
@class SENSenseMessage;
@class SENSenseMessageBuilder;
@class SENWifiEndpoint;
@class SENWifiEndpointBuilder;
#ifndef __has_feature
  #define __has_feature(x) 0 // Compatibility with non-clang compilers.
#endif // __has_feature

#ifndef NS_RETURNS_NOT_RETAINED
  #if __has_feature(attribute_ns_returns_not_retained)
    #define NS_RETURNS_NOT_RETAINED __attribute__((ns_returns_not_retained))
  #else
    #define NS_RETURNS_NOT_RETAINED
  #endif
#endif

typedef enum {
  ErrorTypeTimeOut = 0,
  ErrorTypeNetworkError = 1,
  ErrorTypeDeviceAlreadyPaired = 2,
  ErrorTypeInternalDataError = 3,
  ErrorTypeDeviceDatabaseFull = 4,
  ErrorTypeDeviceNoMemory = 5,
  ErrorTypeInternalOperationFailed = 6,
  ErrorTypeNoEndpointInRange = 7,
  ErrorTypeWlanConnectionError = 8,
  ErrorTypeFailToObtainIp = 9,
} ErrorType;

BOOL ErrorTypeIsValidValue(ErrorType value);

typedef enum {
  WiFiStateNoWlanConnected = 0,
  WiFiStateWlanConnecting = 1,
  WiFiStateWlanConnected = 2,
  WiFiStateIpObtained = 3,
} WiFiState;

BOOL WiFiStateIsValidValue(WiFiState value);

typedef enum {
  SENWifiEndpointSecurityTypeOpen = 0,
  SENWifiEndpointSecurityTypeWep = 1,
  SENWifiEndpointSecurityTypeWpa = 2,
  SENWifiEndpointSecurityTypeWpa2 = 3,
} SENWifiEndpointSecurityType;

BOOL SENWifiEndpointSecurityTypeIsValidValue(SENWifiEndpointSecurityType value);

typedef enum {
  SENSenseMessageTypeSetTime = 0,
  SENSenseMessageTypeGetTime = 1,
  SENSenseMessageTypeSetWifiEndpoint = 2,
  SENSenseMessageTypeGetWifiEndpoint = 3,
  SENSenseMessageTypeSetAlarms = 4,
  SENSenseMessageTypeGetAlarms = 5,
  SENSenseMessageTypeSwitchToPairingMode = 6,
  SENSenseMessageTypeSwitchToNormalMode = 7,
  SENSenseMessageTypeStartWifiscan = 8,
  SENSenseMessageTypeStopWifiscan = 9,
  SENSenseMessageTypeGetDeviceId = 10,
  SENSenseMessageTypeEreasePairedPhone = 11,
  SENSenseMessageTypePairPill = 12,
  SENSenseMessageTypeError = 13,
  SENSenseMessageTypePairSense = 14,
  SENSenseMessageTypeUnpairPill = 15,
  SENSenseMessageTypeDfuBegin = 16,
  SENSenseMessageTypePillData = 17,
  SENSenseMessageTypePillHeartbeat = 18,
  SENSenseMessageTypePillDfuBegin = 19,
  SENSenseMessageTypeFactoryReset = 20,
  SENSenseMessageTypeLedBusy = 25,
  SENSenseMessageTypeLedTrippy = 26,
  SENSenseMessageTypeLedOff = 27,
  SENSenseMessageTypeScanWifi = 28,
  SENSenseMessageTypeGetNextWifiAp = 29,
  SENSenseMessageTypeLedSuccess = 30,
  SENSenseMessageTypePushData = 31,
} SENSenseMessageType;

BOOL SENSenseMessageTypeIsValidValue(SENSenseMessageType value);


@interface SensenseMessageRoot : NSObject {
}
+ (PBExtensionRegistry*) extensionRegistry;
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry;
@end

@interface SENWifiEndpoint : PBGeneratedMessage {
@private
  BOOL hasRssi_:1;
  BOOL hasSsid_:1;
  BOOL hasBssid_:1;
  BOOL hasSecurity_:1;
  long rssi;
  NSString* ssid;
  NSData* bssid;
  SENWifiEndpointSecurityType security;
}
- (BOOL) hasSsid;
- (BOOL) hasBssid;
- (BOOL) hasRssi;
- (BOOL) hasSecurity;
@property (readonly, strong) NSString* ssid;
@property (readonly, strong) NSData* bssid;
@property (readonly) long rssi;
@property (readonly) SENWifiEndpointSecurityType security;

+ (SENWifiEndpoint*) defaultInstance;
- (SENWifiEndpoint*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SENWifiEndpointBuilder*) builder;
+ (SENWifiEndpointBuilder*) builder;
+ (SENWifiEndpointBuilder*) builderWithPrototype:(SENWifiEndpoint*) prototype;
- (SENWifiEndpointBuilder*) toBuilder;

+ (SENWifiEndpoint*) parseFromData:(NSData*) data;
+ (SENWifiEndpoint*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENWifiEndpoint*) parseFromInputStream:(NSInputStream*) input;
+ (SENWifiEndpoint*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENWifiEndpoint*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SENWifiEndpoint*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SENWifiEndpointBuilder : PBGeneratedMessageBuilder {
@private
  SENWifiEndpoint* result;
}

- (SENWifiEndpoint*) defaultInstance;

- (SENWifiEndpointBuilder*) clear;
- (SENWifiEndpointBuilder*) clone;

- (SENWifiEndpoint*) build;
- (SENWifiEndpoint*) buildPartial;

- (SENWifiEndpointBuilder*) mergeFrom:(SENWifiEndpoint*) other;
- (SENWifiEndpointBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SENWifiEndpointBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasSsid;
- (NSString*) ssid;
- (SENWifiEndpointBuilder*) setSsid:(NSString*) value;
- (SENWifiEndpointBuilder*) clearSsid;

- (BOOL) hasBssid;
- (NSData*) bssid;
- (SENWifiEndpointBuilder*) setBssid:(NSData*) value;
- (SENWifiEndpointBuilder*) clearBssid;

- (BOOL) hasRssi;
- (long) rssi;
- (SENWifiEndpointBuilder*) setRssi:(long) value;
- (SENWifiEndpointBuilder*) clearRssi;

- (BOOL) hasSecurity;
- (SENWifiEndpointSecurityType) security;
- (SENWifiEndpointBuilder*) setSecurity:(SENWifiEndpointSecurityType) value;
- (SENWifiEndpointBuilder*) clearSecurity;
@end

@interface PillData : PBGeneratedMessage {
@private
  BOOL hasBatteryLevel_:1;
  BOOL hasUptime_:1;
  BOOL hasFirmwareVersion_:1;
  BOOL hasDeviceId_:1;
  BOOL hasMotionDataEntrypted_:1;
  long batteryLevel;
  long uptime;
  long firmwareVersion;
  NSString* deviceId;
  NSData* motionDataEntrypted;
}
- (BOOL) hasDeviceId;
- (BOOL) hasBatteryLevel;
- (BOOL) hasUptime;
- (BOOL) hasMotionDataEntrypted;
- (BOOL) hasFirmwareVersion;
@property (readonly, strong) NSString* deviceId;
@property (readonly) long batteryLevel;
@property (readonly) long uptime;
@property (readonly, strong) NSData* motionDataEntrypted;
@property (readonly) long firmwareVersion;

+ (PillData*) defaultInstance;
- (PillData*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (PillDataBuilder*) builder;
+ (PillDataBuilder*) builder;
+ (PillDataBuilder*) builderWithPrototype:(PillData*) prototype;
- (PillDataBuilder*) toBuilder;

+ (PillData*) parseFromData:(NSData*) data;
+ (PillData*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PillData*) parseFromInputStream:(NSInputStream*) input;
+ (PillData*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (PillData*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (PillData*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface PillDataBuilder : PBGeneratedMessageBuilder {
@private
  PillData* result;
}

- (PillData*) defaultInstance;

- (PillDataBuilder*) clear;
- (PillDataBuilder*) clone;

- (PillData*) build;
- (PillData*) buildPartial;

- (PillDataBuilder*) mergeFrom:(PillData*) other;
- (PillDataBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (PillDataBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasDeviceId;
- (NSString*) deviceId;
- (PillDataBuilder*) setDeviceId:(NSString*) value;
- (PillDataBuilder*) clearDeviceId;

- (BOOL) hasBatteryLevel;
- (long) batteryLevel;
- (PillDataBuilder*) setBatteryLevel:(long) value;
- (PillDataBuilder*) clearBatteryLevel;

- (BOOL) hasUptime;
- (long) uptime;
- (PillDataBuilder*) setUptime:(long) value;
- (PillDataBuilder*) clearUptime;

- (BOOL) hasMotionDataEntrypted;
- (NSData*) motionDataEntrypted;
- (PillDataBuilder*) setMotionDataEntrypted:(NSData*) value;
- (PillDataBuilder*) clearMotionDataEntrypted;

- (BOOL) hasFirmwareVersion;
- (long) firmwareVersion;
- (PillDataBuilder*) setFirmwareVersion:(long) value;
- (PillDataBuilder*) clearFirmwareVersion;
@end

@interface BatchedPillData : PBGeneratedMessage {
@private
  BOOL hasDeviceId_:1;
  NSString* deviceId;
  PBAppendableArray * pillsArray;
}
- (BOOL) hasDeviceId;
@property (readonly, strong) PBArray * pills;
@property (readonly, strong) NSString* deviceId;
- (PillData*)pillsAtIndex:(NSUInteger)index;

+ (BatchedPillData*) defaultInstance;
- (BatchedPillData*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (BatchedPillDataBuilder*) builder;
+ (BatchedPillDataBuilder*) builder;
+ (BatchedPillDataBuilder*) builderWithPrototype:(BatchedPillData*) prototype;
- (BatchedPillDataBuilder*) toBuilder;

+ (BatchedPillData*) parseFromData:(NSData*) data;
+ (BatchedPillData*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BatchedPillData*) parseFromInputStream:(NSInputStream*) input;
+ (BatchedPillData*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (BatchedPillData*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (BatchedPillData*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface BatchedPillDataBuilder : PBGeneratedMessageBuilder {
@private
  BatchedPillData* result;
}

- (BatchedPillData*) defaultInstance;

- (BatchedPillDataBuilder*) clear;
- (BatchedPillDataBuilder*) clone;

- (BatchedPillData*) build;
- (BatchedPillData*) buildPartial;

- (BatchedPillDataBuilder*) mergeFrom:(BatchedPillData*) other;
- (BatchedPillDataBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (BatchedPillDataBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (PBAppendableArray *)pills;
- (PillData*)pillsAtIndex:(NSUInteger)index;
- (BatchedPillDataBuilder *)addPills:(PillData*)value;
- (BatchedPillDataBuilder *)setPillsArray:(NSArray *)array;
- (BatchedPillDataBuilder *)setPillsValues:(const PillData* __strong *)values count:(NSUInteger)count;
- (BatchedPillDataBuilder *)clearPills;

- (BOOL) hasDeviceId;
- (NSString*) deviceId;
- (BatchedPillDataBuilder*) setDeviceId:(NSString*) value;
- (BatchedPillDataBuilder*) clearDeviceId;
@end

@interface SENSenseMessage : PBGeneratedMessage {
@private
  BOOL hasVersion_:1;
  BOOL hasBatteryLevel_:1;
  BOOL hasUptime_:1;
  BOOL hasMotionData_:1;
  BOOL hasFirmwareVersion_:1;
  BOOL hasDeviceId_:1;
  BOOL hasAccountId_:1;
  BOOL hasWifiName_:1;
  BOOL hasWifiSsid_:1;
  BOOL hasWifiPassword_:1;
  BOOL hasPillData_:1;
  BOOL hasMotionDataEncrypted_:1;
  BOOL hasType_:1;
  BOOL hasError_:1;
  BOOL hasSecurityType_:1;
  BOOL hasWifiState_:1;
  long version;
  long batteryLevel;
  long uptime;
  long motionData;
  long firmwareVersion;
  NSString* deviceId;
  NSString* accountId;
  NSString* wifiName;
  NSString* wifiSsid;
  NSString* wifiPassword;
  PillData* pillData;
  NSData* motionDataEncrypted;
  SENSenseMessageType type;
  ErrorType error;
  SENWifiEndpointSecurityType securityType;
  WiFiState wifiState;
  PBAppendableArray * wifisDetectedArray;
}
- (BOOL) hasVersion;
- (BOOL) hasType;
- (BOOL) hasDeviceId;
- (BOOL) hasAccountId;
- (BOOL) hasError;
- (BOOL) hasWifiName;
- (BOOL) hasWifiSsid;
- (BOOL) hasWifiPassword;
- (BOOL) hasBatteryLevel;
- (BOOL) hasUptime;
- (BOOL) hasMotionData;
- (BOOL) hasMotionDataEncrypted;
- (BOOL) hasFirmwareVersion;
- (BOOL) hasSecurityType;
- (BOOL) hasPillData;
- (BOOL) hasWifiState;
@property (readonly) long version;
@property (readonly) SENSenseMessageType type;
@property (readonly, strong) NSString* deviceId;
@property (readonly, strong) NSString* accountId;
@property (readonly) ErrorType error;
@property (readonly, strong) NSString* wifiName;
@property (readonly, strong) NSString* wifiSsid;
@property (readonly, strong) NSString* wifiPassword;
@property (readonly) long batteryLevel;
@property (readonly) long uptime;
@property (readonly) long motionData;
@property (readonly, strong) NSData* motionDataEncrypted;
@property (readonly) long firmwareVersion;
@property (readonly, strong) PBArray * wifisDetected;
@property (readonly) SENWifiEndpointSecurityType securityType;
@property (readonly, strong) PillData* pillData;
@property (readonly) WiFiState wifiState;
- (SENWifiEndpoint*)wifisDetectedAtIndex:(NSUInteger)index;

+ (SENSenseMessage*) defaultInstance;
- (SENSenseMessage*) defaultInstance;

- (BOOL) isInitialized;
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output;
- (SENSenseMessageBuilder*) builder;
+ (SENSenseMessageBuilder*) builder;
+ (SENSenseMessageBuilder*) builderWithPrototype:(SENSenseMessage*) prototype;
- (SENSenseMessageBuilder*) toBuilder;

+ (SENSenseMessage*) parseFromData:(NSData*) data;
+ (SENSenseMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input;
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input;
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;
@end

@interface SENSenseMessageBuilder : PBGeneratedMessageBuilder {
@private
  SENSenseMessage* result;
}

- (SENSenseMessage*) defaultInstance;

- (SENSenseMessageBuilder*) clear;
- (SENSenseMessageBuilder*) clone;

- (SENSenseMessage*) build;
- (SENSenseMessage*) buildPartial;

- (SENSenseMessageBuilder*) mergeFrom:(SENSenseMessage*) other;
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input;
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry;

- (BOOL) hasVersion;
- (long) version;
- (SENSenseMessageBuilder*) setVersion:(long) value;
- (SENSenseMessageBuilder*) clearVersion;

- (BOOL) hasType;
- (SENSenseMessageType) type;
- (SENSenseMessageBuilder*) setType:(SENSenseMessageType) value;
- (SENSenseMessageBuilder*) clearType;

- (BOOL) hasDeviceId;
- (NSString*) deviceId;
- (SENSenseMessageBuilder*) setDeviceId:(NSString*) value;
- (SENSenseMessageBuilder*) clearDeviceId;

- (BOOL) hasAccountId;
- (NSString*) accountId;
- (SENSenseMessageBuilder*) setAccountId:(NSString*) value;
- (SENSenseMessageBuilder*) clearAccountId;

- (BOOL) hasError;
- (ErrorType) error;
- (SENSenseMessageBuilder*) setError:(ErrorType) value;
- (SENSenseMessageBuilder*) clearError;

- (BOOL) hasWifiName;
- (NSString*) wifiName;
- (SENSenseMessageBuilder*) setWifiName:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiName;

- (BOOL) hasWifiSsid;
- (NSString*) wifiSsid;
- (SENSenseMessageBuilder*) setWifiSsid:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiSsid;

- (BOOL) hasWifiPassword;
- (NSString*) wifiPassword;
- (SENSenseMessageBuilder*) setWifiPassword:(NSString*) value;
- (SENSenseMessageBuilder*) clearWifiPassword;

- (BOOL) hasBatteryLevel;
- (long) batteryLevel;
- (SENSenseMessageBuilder*) setBatteryLevel:(long) value;
- (SENSenseMessageBuilder*) clearBatteryLevel;

- (BOOL) hasUptime;
- (long) uptime;
- (SENSenseMessageBuilder*) setUptime:(long) value;
- (SENSenseMessageBuilder*) clearUptime;

- (BOOL) hasMotionData;
- (long) motionData;
- (SENSenseMessageBuilder*) setMotionData:(long) value;
- (SENSenseMessageBuilder*) clearMotionData;

- (BOOL) hasMotionDataEncrypted;
- (NSData*) motionDataEncrypted;
- (SENSenseMessageBuilder*) setMotionDataEncrypted:(NSData*) value;
- (SENSenseMessageBuilder*) clearMotionDataEncrypted;

- (BOOL) hasFirmwareVersion;
- (long) firmwareVersion;
- (SENSenseMessageBuilder*) setFirmwareVersion:(long) value;
- (SENSenseMessageBuilder*) clearFirmwareVersion;

- (PBAppendableArray *)wifisDetected;
- (SENWifiEndpoint*)wifisDetectedAtIndex:(NSUInteger)index;
- (SENSenseMessageBuilder *)addWifisDetected:(SENWifiEndpoint*)value;
- (SENSenseMessageBuilder *)setWifisDetectedArray:(NSArray *)array;
- (SENSenseMessageBuilder *)setWifisDetectedValues:(const SENWifiEndpoint* __strong *)values count:(NSUInteger)count;
- (SENSenseMessageBuilder *)clearWifisDetected;

- (BOOL) hasSecurityType;
- (SENWifiEndpointSecurityType) securityType;
- (SENSenseMessageBuilder*) setSecurityType:(SENWifiEndpointSecurityType) value;
- (SENSenseMessageBuilder*) clearSecurityType;

- (BOOL) hasPillData;
- (PillData*) pillData;
- (SENSenseMessageBuilder*) setPillData:(PillData*) value;
- (SENSenseMessageBuilder*) setPillDataBuilder:(PillDataBuilder*) builderForValue;
- (SENSenseMessageBuilder*) mergePillData:(PillData*) value;
- (SENSenseMessageBuilder*) clearPillData;

- (BOOL) hasWifiState;
- (WiFiState) wifiState;
- (SENSenseMessageBuilder*) setWifiState:(WiFiState) value;
- (SENSenseMessageBuilder*) clearWifiState;
@end


// @@protoc_insertion_point(global_scope)
