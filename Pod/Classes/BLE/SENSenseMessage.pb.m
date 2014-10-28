// Generated by the protocol buffer compiler.  DO NOT EDIT!

#import "SENSenseMessage.pb.h"
// @@protoc_insertion_point(imports)

@implementation SensenseMessageRoot
static PBExtensionRegistry* extensionRegistry = nil;
+ (PBExtensionRegistry*) extensionRegistry {
  return extensionRegistry;
}

+ (void) initialize {
  if (self == [SensenseMessageRoot class]) {
    PBMutableExtensionRegistry* registry = [PBMutableExtensionRegistry registry];
    [self registerAllExtensions:registry];
    extensionRegistry = registry;
  }
}
+ (void) registerAllExtensions:(PBMutableExtensionRegistry*) registry {
}
@end

BOOL ErrorTypeIsValidValue(ErrorType value) {
  switch (value) {
    case ErrorTypeTimeOut:
    case ErrorTypeNetworkError:
    case ErrorTypeDeviceAlreadyPaired:
    case ErrorTypeInternalDataError:
    case ErrorTypeDeviceDatabaseFull:
    case ErrorTypeDeviceNoMemory:
    case ErrorTypeInternalOperationFailed:
    case ErrorTypeNoEndpointInRange:
    case ErrorTypeWlanConnectionError:
    case ErrorTypeFailToObtainIp:
      return YES;
    default:
      return NO;
  }
}
@interface SENWifiEndpoint ()
@property (strong) NSString* ssid;
@property (strong) NSData* bssid;
@property long rssi;
@property SENWifiEndpointSecurityType security;
@end

@implementation SENWifiEndpoint

- (BOOL) hasSsid {
  return !!hasSsid_;
}
- (void) setHasSsid:(BOOL) value_ {
  hasSsid_ = !!value_;
}
@synthesize ssid;
- (BOOL) hasBssid {
  return !!hasBssid_;
}
- (void) setHasBssid:(BOOL) value_ {
  hasBssid_ = !!value_;
}
@synthesize bssid;
- (BOOL) hasRssi {
  return !!hasRssi_;
}
- (void) setHasRssi:(BOOL) value_ {
  hasRssi_ = !!value_;
}
@synthesize rssi;
- (BOOL) hasSecurity {
  return !!hasSecurity_;
}
- (void) setHasSecurity:(BOOL) value_ {
  hasSecurity_ = !!value_;
}
@synthesize security;
- (void) dealloc {
  self.ssid = nil;
  self.bssid = nil;
}
- (id) init {
  if ((self = [super init])) {
    self.ssid = @"";
    self.bssid = [NSData data];
    self.rssi = 0;
    self.security = SENWifiEndpointSecurityTypeOpen;
  }
  return self;
}
static SENWifiEndpoint* defaultSENWifiEndpointInstance = nil;
+ (void) initialize {
  if (self == [SENWifiEndpoint class]) {
    defaultSENWifiEndpointInstance = [[SENWifiEndpoint alloc] init];
  }
}
+ (SENWifiEndpoint*) defaultInstance {
  return defaultSENWifiEndpointInstance;
}
- (SENWifiEndpoint*) defaultInstance {
  return defaultSENWifiEndpointInstance;
}
- (BOOL) isInitialized {
  if (!self.hasSsid) {
    return NO;
  }
  if (!self.hasRssi) {
    return NO;
  }
  if (!self.hasSecurity) {
    return NO;
  }
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasSsid) {
    [output writeString:1 value:self.ssid];
  }
  if (self.hasBssid) {
    [output writeData:2 value:self.bssid];
  }
  if (self.hasRssi) {
    [output writeInt32:4 value:self.rssi];
  }
  if (self.hasSecurity) {
    [output writeEnum:5 value:self.security];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (long) serializedSize {
  long size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasSsid) {
    size_ += computeStringSize(1, self.ssid);
  }
  if (self.hasBssid) {
    size_ += computeDataSize(2, self.bssid);
  }
  if (self.hasRssi) {
    size_ += computeInt32Size(4, self.rssi);
  }
  if (self.hasSecurity) {
    size_ += computeEnumSize(5, self.security);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (SENWifiEndpoint*) parseFromData:(NSData*) data {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromData:data] build];
}
+ (SENWifiEndpoint*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (SENWifiEndpoint*) parseFromInputStream:(NSInputStream*) input {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromInputStream:input] build];
}
+ (SENWifiEndpoint*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (SENWifiEndpoint*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromCodedInputStream:input] build];
}
+ (SENWifiEndpoint*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENWifiEndpoint*)[[[SENWifiEndpoint builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (SENWifiEndpointBuilder*) builder {
  return [[SENWifiEndpointBuilder alloc] init];
}
+ (SENWifiEndpointBuilder*) builderWithPrototype:(SENWifiEndpoint*) prototype {
  return [[SENWifiEndpoint builder] mergeFrom:prototype];
}
- (SENWifiEndpointBuilder*) builder {
  return [SENWifiEndpoint builder];
}
- (SENWifiEndpointBuilder*) toBuilder {
  return [SENWifiEndpoint builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasSsid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"ssid", self.ssid];
  }
  if (self.hasBssid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"bssid", self.bssid];
  }
  if (self.hasRssi) {
    [output appendFormat:@"%@%@: %@\n", indent, @"rssi", [NSNumber numberWithInteger:self.rssi]];
  }
  if (self.hasSecurity) {
    [output appendFormat:@"%@%@: %d\n", indent, @"security", self.security];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[SENWifiEndpoint class]]) {
    return NO;
  }
  SENWifiEndpoint *otherMessage = other;
  return
      self.hasSsid == otherMessage.hasSsid &&
      (!self.hasSsid || [self.ssid isEqual:otherMessage.ssid]) &&
      self.hasBssid == otherMessage.hasBssid &&
      (!self.hasBssid || [self.bssid isEqual:otherMessage.bssid]) &&
      self.hasRssi == otherMessage.hasRssi &&
      (!self.hasRssi || self.rssi == otherMessage.rssi) &&
      self.hasSecurity == otherMessage.hasSecurity &&
      (!self.hasSecurity || self.security == otherMessage.security) &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  if (self.hasSsid) {
    hashCode = hashCode * 31 + [self.ssid hash];
  }
  if (self.hasBssid) {
    hashCode = hashCode * 31 + [self.bssid hash];
  }
  if (self.hasRssi) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.rssi] hash];
  }
  if (self.hasSecurity) {
    hashCode = hashCode * 31 + self.security;
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

BOOL SENWifiEndpointSecurityTypeIsValidValue(SENWifiEndpointSecurityType value) {
  switch (value) {
    case SENWifiEndpointSecurityTypeOpen:
    case SENWifiEndpointSecurityTypeWep:
    case SENWifiEndpointSecurityTypeWpa:
    case SENWifiEndpointSecurityTypeWpa2:
      return YES;
    default:
      return NO;
  }
}
@interface SENWifiEndpointBuilder()
@property (strong) SENWifiEndpoint* result;
@end

@implementation SENWifiEndpointBuilder
@synthesize result;
- (void) dealloc {
  self.result = nil;
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[SENWifiEndpoint alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (SENWifiEndpointBuilder*) clear {
  self.result = [[SENWifiEndpoint alloc] init];
  return self;
}
- (SENWifiEndpointBuilder*) clone {
  return [SENWifiEndpoint builderWithPrototype:result];
}
- (SENWifiEndpoint*) defaultInstance {
  return [SENWifiEndpoint defaultInstance];
}
- (SENWifiEndpoint*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (SENWifiEndpoint*) buildPartial {
  SENWifiEndpoint* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (SENWifiEndpointBuilder*) mergeFrom:(SENWifiEndpoint*) other {
  if (other == [SENWifiEndpoint defaultInstance]) {
    return self;
  }
  if (other.hasSsid) {
    [self setSsid:other.ssid];
  }
  if (other.hasBssid) {
    [self setBssid:other.bssid];
  }
  if (other.hasRssi) {
    [self setRssi:other.rssi];
  }
  if (other.hasSecurity) {
    [self setSecurity:other.security];
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (SENWifiEndpointBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (SENWifiEndpointBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    NSInteger tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 10: {
        [self setSsid:[input readString]];
        break;
      }
      case 18: {
        [self setBssid:[input readData]];
        break;
      }
      case 32: {
        [self setRssi:[input readInt32]];
        break;
      }
      case 40: {
        SENWifiEndpointSecurityType value = (SENWifiEndpointSecurityType)[input readEnum];
        if (SENWifiEndpointSecurityTypeIsValidValue(value)) {
          [self setSecurity:value];
        } else {
          [unknownFields mergeVarintField:5 value:value];
        }
        break;
      }
    }
  }
}
- (BOOL) hasSsid {
  return result.hasSsid;
}
- (NSString*) ssid {
  return result.ssid;
}
- (SENWifiEndpointBuilder*) setSsid:(NSString*) value {
  result.hasSsid = YES;
  result.ssid = value;
  return self;
}
- (SENWifiEndpointBuilder*) clearSsid {
  result.hasSsid = NO;
  result.ssid = @"";
  return self;
}
- (BOOL) hasBssid {
  return result.hasBssid;
}
- (NSData*) bssid {
  return result.bssid;
}
- (SENWifiEndpointBuilder*) setBssid:(NSData*) value {
  result.hasBssid = YES;
  result.bssid = value;
  return self;
}
- (SENWifiEndpointBuilder*) clearBssid {
  result.hasBssid = NO;
  result.bssid = [NSData data];
  return self;
}
- (BOOL) hasRssi {
  return result.hasRssi;
}
- (long) rssi {
  return result.rssi;
}
- (SENWifiEndpointBuilder*) setRssi:(long) value {
  result.hasRssi = YES;
  result.rssi = value;
  return self;
}
- (SENWifiEndpointBuilder*) clearRssi {
  result.hasRssi = NO;
  result.rssi = 0;
  return self;
}
- (BOOL) hasSecurity {
  return result.hasSecurity;
}
- (SENWifiEndpointSecurityType) security {
  return result.security;
}
- (SENWifiEndpointBuilder*) setSecurity:(SENWifiEndpointSecurityType) value {
  result.hasSecurity = YES;
  result.security = value;
  return self;
}
- (SENWifiEndpointBuilder*) clearSecurity {
  result.hasSecurity = NO;
  result.security = SENWifiEndpointSecurityTypeOpen;
  return self;
}
@end

@interface SENSenseMessage ()
@property long version;
@property SENSenseMessageType type;
@property (strong) NSString* deviceId;
@property (strong) NSString* accountId;
@property ErrorType error;
@property (strong) NSString* wifiName;
@property (strong) NSString* wifiSsid;
@property (strong) NSString* wifiPassword;
@property long batteryLevel;
@property long uptime;
@property long motionData;
@property (strong) NSData* motionDataEncrypted;
@property long firmwareVersion;
@property (strong) PBAppendableArray * wifisDetectedArray;
@end

@implementation SENSenseMessage

- (BOOL) hasVersion {
  return !!hasVersion_;
}
- (void) setHasVersion:(BOOL) value_ {
  hasVersion_ = !!value_;
}
@synthesize version;
- (BOOL) hasType {
  return !!hasType_;
}
- (void) setHasType:(BOOL) value_ {
  hasType_ = !!value_;
}
@synthesize type;
- (BOOL) hasDeviceId {
  return !!hasDeviceId_;
}
- (void) setHasDeviceId:(BOOL) value_ {
  hasDeviceId_ = !!value_;
}
@synthesize deviceId;
- (BOOL) hasAccountId {
  return !!hasAccountId_;
}
- (void) setHasAccountId:(BOOL) value_ {
  hasAccountId_ = !!value_;
}
@synthesize accountId;
- (BOOL) hasError {
  return !!hasError_;
}
- (void) setHasError:(BOOL) value_ {
  hasError_ = !!value_;
}
@synthesize error;
- (BOOL) hasWifiName {
  return !!hasWifiName_;
}
- (void) setHasWifiName:(BOOL) value_ {
  hasWifiName_ = !!value_;
}
@synthesize wifiName;
- (BOOL) hasWifiSsid {
  return !!hasWifiSsid_;
}
- (void) setHasWifiSsid:(BOOL) value_ {
  hasWifiSsid_ = !!value_;
}
@synthesize wifiSsid;
- (BOOL) hasWifiPassword {
  return !!hasWifiPassword_;
}
- (void) setHasWifiPassword:(BOOL) value_ {
  hasWifiPassword_ = !!value_;
}
@synthesize wifiPassword;
- (BOOL) hasBatteryLevel {
  return !!hasBatteryLevel_;
}
- (void) setHasBatteryLevel:(BOOL) value_ {
  hasBatteryLevel_ = !!value_;
}
@synthesize batteryLevel;
- (BOOL) hasUptime {
  return !!hasUptime_;
}
- (void) setHasUptime:(BOOL) value_ {
  hasUptime_ = !!value_;
}
@synthesize uptime;
- (BOOL) hasMotionData {
  return !!hasMotionData_;
}
- (void) setHasMotionData:(BOOL) value_ {
  hasMotionData_ = !!value_;
}
@synthesize motionData;
- (BOOL) hasMotionDataEncrypted {
  return !!hasMotionDataEncrypted_;
}
- (void) setHasMotionDataEncrypted:(BOOL) value_ {
  hasMotionDataEncrypted_ = !!value_;
}
@synthesize motionDataEncrypted;
- (BOOL) hasFirmwareVersion {
  return !!hasFirmwareVersion_;
}
- (void) setHasFirmwareVersion:(BOOL) value_ {
  hasFirmwareVersion_ = !!value_;
}
@synthesize firmwareVersion;
@synthesize wifisDetectedArray;
@dynamic wifisDetected;
- (void) dealloc {
  self.deviceId = nil;
  self.accountId = nil;
  self.wifiName = nil;
  self.wifiSsid = nil;
  self.wifiPassword = nil;
  self.motionDataEncrypted = nil;
  self.wifisDetectedArray = nil;
}
- (id) init {
  if ((self = [super init])) {
    self.version = 0;
    self.type = SENSenseMessageTypeSetTime;
    self.deviceId = @"";
    self.accountId = @"";
    self.error = ErrorTypeTimeOut;
    self.wifiName = @"";
    self.wifiSsid = @"";
    self.wifiPassword = @"";
    self.batteryLevel = 0;
    self.uptime = 0;
    self.motionData = 0;
    self.motionDataEncrypted = [NSData data];
    self.firmwareVersion = 0;
  }
  return self;
}
static SENSenseMessage* defaultSENSenseMessageInstance = nil;
+ (void) initialize {
  if (self == [SENSenseMessage class]) {
    defaultSENSenseMessageInstance = [[SENSenseMessage alloc] init];
  }
}
+ (SENSenseMessage*) defaultInstance {
  return defaultSENSenseMessageInstance;
}
- (SENSenseMessage*) defaultInstance {
  return defaultSENSenseMessageInstance;
}
- (PBArray *)wifisDetected {
  return wifisDetectedArray;
}
- (SENWifiEndpoint*)wifisDetectedAtIndex:(NSUInteger)index {
  return [wifisDetectedArray objectAtIndex:index];
}
- (BOOL) isInitialized {
  if (!self.hasVersion) {
    return NO;
  }
  if (!self.hasType) {
    return NO;
  }
  for (SENWifiEndpoint* element in self.wifisDetected) {
    if (!element.isInitialized) {
      return NO;
    }
  }
  return YES;
}
- (void) writeToCodedOutputStream:(PBCodedOutputStream*) output {
  if (self.hasVersion) {
    [output writeInt32:1 value:self.version];
  }
  if (self.hasType) {
    [output writeEnum:2 value:self.type];
  }
  if (self.hasDeviceId) {
    [output writeString:3 value:self.deviceId];
  }
  if (self.hasAccountId) {
    [output writeString:4 value:self.accountId];
  }
  if (self.hasError) {
    [output writeEnum:5 value:self.error];
  }
  if (self.hasWifiName) {
    [output writeString:6 value:self.wifiName];
  }
  if (self.hasWifiSsid) {
    [output writeString:7 value:self.wifiSsid];
  }
  if (self.hasWifiPassword) {
    [output writeString:8 value:self.wifiPassword];
  }
  if (self.hasBatteryLevel) {
    [output writeInt32:9 value:self.batteryLevel];
  }
  if (self.hasUptime) {
    [output writeInt32:10 value:self.uptime];
  }
  if (self.hasMotionData) {
    [output writeInt32:11 value:self.motionData];
  }
  if (self.hasMotionDataEncrypted) {
    [output writeData:12 value:self.motionDataEncrypted];
  }
  if (self.hasFirmwareVersion) {
    [output writeInt32:13 value:self.firmwareVersion];
  }
  for (SENWifiEndpoint *element in self.wifisDetectedArray) {
    [output writeMessage:14 value:element];
  }
  [self.unknownFields writeToCodedOutputStream:output];
}
- (long) serializedSize {
  long size_ = memoizedSerializedSize;
  if (size_ != -1) {
    return size_;
  }

  size_ = 0;
  if (self.hasVersion) {
    size_ += computeInt32Size(1, self.version);
  }
  if (self.hasType) {
    size_ += computeEnumSize(2, self.type);
  }
  if (self.hasDeviceId) {
    size_ += computeStringSize(3, self.deviceId);
  }
  if (self.hasAccountId) {
    size_ += computeStringSize(4, self.accountId);
  }
  if (self.hasError) {
    size_ += computeEnumSize(5, self.error);
  }
  if (self.hasWifiName) {
    size_ += computeStringSize(6, self.wifiName);
  }
  if (self.hasWifiSsid) {
    size_ += computeStringSize(7, self.wifiSsid);
  }
  if (self.hasWifiPassword) {
    size_ += computeStringSize(8, self.wifiPassword);
  }
  if (self.hasBatteryLevel) {
    size_ += computeInt32Size(9, self.batteryLevel);
  }
  if (self.hasUptime) {
    size_ += computeInt32Size(10, self.uptime);
  }
  if (self.hasMotionData) {
    size_ += computeInt32Size(11, self.motionData);
  }
  if (self.hasMotionDataEncrypted) {
    size_ += computeDataSize(12, self.motionDataEncrypted);
  }
  if (self.hasFirmwareVersion) {
    size_ += computeInt32Size(13, self.firmwareVersion);
  }
  for (SENWifiEndpoint *element in self.wifisDetectedArray) {
    size_ += computeMessageSize(14, element);
  }
  size_ += self.unknownFields.serializedSize;
  memoizedSerializedSize = size_;
  return size_;
}
+ (SENSenseMessage*) parseFromData:(NSData*) data {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromData:data] build];
}
+ (SENSenseMessage*) parseFromData:(NSData*) data extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromData:data extensionRegistry:extensionRegistry] build];
}
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromInputStream:input] build];
}
+ (SENSenseMessage*) parseFromInputStream:(NSInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromCodedInputStream:input] build];
}
+ (SENSenseMessage*) parseFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  return (SENSenseMessage*)[[[SENSenseMessage builder] mergeFromCodedInputStream:input extensionRegistry:extensionRegistry] build];
}
+ (SENSenseMessageBuilder*) builder {
  return [[SENSenseMessageBuilder alloc] init];
}
+ (SENSenseMessageBuilder*) builderWithPrototype:(SENSenseMessage*) prototype {
  return [[SENSenseMessage builder] mergeFrom:prototype];
}
- (SENSenseMessageBuilder*) builder {
  return [SENSenseMessage builder];
}
- (SENSenseMessageBuilder*) toBuilder {
  return [SENSenseMessage builderWithPrototype:self];
}
- (void) writeDescriptionTo:(NSMutableString*) output withIndent:(NSString*) indent {
  if (self.hasVersion) {
    [output appendFormat:@"%@%@: %@\n", indent, @"version", [NSNumber numberWithInteger:self.version]];
  }
  if (self.hasType) {
    [output appendFormat:@"%@%@: %d\n", indent, @"type", self.type];
  }
  if (self.hasDeviceId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"deviceId", self.deviceId];
  }
  if (self.hasAccountId) {
    [output appendFormat:@"%@%@: %@\n", indent, @"accountId", self.accountId];
  }
  if (self.hasError) {
    [output appendFormat:@"%@%@: %d\n", indent, @"error", self.error];
  }
  if (self.hasWifiName) {
    [output appendFormat:@"%@%@: %@\n", indent, @"wifiName", self.wifiName];
  }
  if (self.hasWifiSsid) {
    [output appendFormat:@"%@%@: %@\n", indent, @"wifiSsid", self.wifiSsid];
  }
  if (self.hasWifiPassword) {
    [output appendFormat:@"%@%@: %@\n", indent, @"wifiPassword", self.wifiPassword];
  }
  if (self.hasBatteryLevel) {
    [output appendFormat:@"%@%@: %@\n", indent, @"batteryLevel", [NSNumber numberWithInteger:self.batteryLevel]];
  }
  if (self.hasUptime) {
    [output appendFormat:@"%@%@: %@\n", indent, @"uptime", [NSNumber numberWithInteger:self.uptime]];
  }
  if (self.hasMotionData) {
    [output appendFormat:@"%@%@: %@\n", indent, @"motionData", [NSNumber numberWithInteger:self.motionData]];
  }
  if (self.hasMotionDataEncrypted) {
    [output appendFormat:@"%@%@: %@\n", indent, @"motionDataEncrypted", self.motionDataEncrypted];
  }
  if (self.hasFirmwareVersion) {
    [output appendFormat:@"%@%@: %@\n", indent, @"firmwareVersion", [NSNumber numberWithInteger:self.firmwareVersion]];
  }
  for (SENWifiEndpoint* element in self.wifisDetectedArray) {
    [output appendFormat:@"%@%@ {\n", indent, @"wifisDetected"];
    [element writeDescriptionTo:output
                     withIndent:[NSString stringWithFormat:@"%@  ", indent]];
    [output appendFormat:@"%@}\n", indent];
  }
  [self.unknownFields writeDescriptionTo:output withIndent:indent];
}
- (BOOL) isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[SENSenseMessage class]]) {
    return NO;
  }
  SENSenseMessage *otherMessage = other;
  return
      self.hasVersion == otherMessage.hasVersion &&
      (!self.hasVersion || self.version == otherMessage.version) &&
      self.hasType == otherMessage.hasType &&
      (!self.hasType || self.type == otherMessage.type) &&
      self.hasDeviceId == otherMessage.hasDeviceId &&
      (!self.hasDeviceId || [self.deviceId isEqual:otherMessage.deviceId]) &&
      self.hasAccountId == otherMessage.hasAccountId &&
      (!self.hasAccountId || [self.accountId isEqual:otherMessage.accountId]) &&
      self.hasError == otherMessage.hasError &&
      (!self.hasError || self.error == otherMessage.error) &&
      self.hasWifiName == otherMessage.hasWifiName &&
      (!self.hasWifiName || [self.wifiName isEqual:otherMessage.wifiName]) &&
      self.hasWifiSsid == otherMessage.hasWifiSsid &&
      (!self.hasWifiSsid || [self.wifiSsid isEqual:otherMessage.wifiSsid]) &&
      self.hasWifiPassword == otherMessage.hasWifiPassword &&
      (!self.hasWifiPassword || [self.wifiPassword isEqual:otherMessage.wifiPassword]) &&
      self.hasBatteryLevel == otherMessage.hasBatteryLevel &&
      (!self.hasBatteryLevel || self.batteryLevel == otherMessage.batteryLevel) &&
      self.hasUptime == otherMessage.hasUptime &&
      (!self.hasUptime || self.uptime == otherMessage.uptime) &&
      self.hasMotionData == otherMessage.hasMotionData &&
      (!self.hasMotionData || self.motionData == otherMessage.motionData) &&
      self.hasMotionDataEncrypted == otherMessage.hasMotionDataEncrypted &&
      (!self.hasMotionDataEncrypted || [self.motionDataEncrypted isEqual:otherMessage.motionDataEncrypted]) &&
      self.hasFirmwareVersion == otherMessage.hasFirmwareVersion &&
      (!self.hasFirmwareVersion || self.firmwareVersion == otherMessage.firmwareVersion) &&
      [self.wifisDetectedArray isEqualToArray:otherMessage.wifisDetectedArray] &&
      (self.unknownFields == otherMessage.unknownFields || (self.unknownFields != nil && [self.unknownFields isEqual:otherMessage.unknownFields]));
}
- (NSUInteger) hash {
  NSUInteger hashCode = 7;
  if (self.hasVersion) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.version] hash];
  }
  if (self.hasType) {
    hashCode = hashCode * 31 + self.type;
  }
  if (self.hasDeviceId) {
    hashCode = hashCode * 31 + [self.deviceId hash];
  }
  if (self.hasAccountId) {
    hashCode = hashCode * 31 + [self.accountId hash];
  }
  if (self.hasError) {
    hashCode = hashCode * 31 + self.error;
  }
  if (self.hasWifiName) {
    hashCode = hashCode * 31 + [self.wifiName hash];
  }
  if (self.hasWifiSsid) {
    hashCode = hashCode * 31 + [self.wifiSsid hash];
  }
  if (self.hasWifiPassword) {
    hashCode = hashCode * 31 + [self.wifiPassword hash];
  }
  if (self.hasBatteryLevel) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.batteryLevel] hash];
  }
  if (self.hasUptime) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.uptime] hash];
  }
  if (self.hasMotionData) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.motionData] hash];
  }
  if (self.hasMotionDataEncrypted) {
    hashCode = hashCode * 31 + [self.motionDataEncrypted hash];
  }
  if (self.hasFirmwareVersion) {
    hashCode = hashCode * 31 + [[NSNumber numberWithInteger:self.firmwareVersion] hash];
  }
  for (SENWifiEndpoint* element in self.wifisDetectedArray) {
    hashCode = hashCode * 31 + [element hash];
  }
  hashCode = hashCode * 31 + [self.unknownFields hash];
  return hashCode;
}
@end

BOOL SENSenseMessageTypeIsValidValue(SENSenseMessageType value) {
  switch (value) {
    case SENSenseMessageTypeSetTime:
    case SENSenseMessageTypeGetTime:
    case SENSenseMessageTypeSetWifiEndpoint:
    case SENSenseMessageTypeGetWifiEndpoint:
    case SENSenseMessageTypeSetAlarms:
    case SENSenseMessageTypeGetAlarms:
    case SENSenseMessageTypeSwitchToPairingMode:
    case SENSenseMessageTypeSwitchToNormalMode:
    case SENSenseMessageTypeStartWifiscan:
    case SENSenseMessageTypeStopWifiscan:
    case SENSenseMessageTypeGetDeviceId:
    case SENSenseMessageTypeEreasePairedPhone:
    case SENSenseMessageTypePairPill:
    case SENSenseMessageTypeError:
    case SENSenseMessageTypePairSense:
    case SENSenseMessageTypeUnpairPill:
    case SENSenseMessageTypeDfuBegin:
    case SENSenseMessageTypePillData:
    case SENSenseMessageTypePillHeartbeat:
    case SENSenseMessageTypePillDfuBegin:
    case SENSenseMessageTypeFactoryReset:
      return YES;
    default:
      return NO;
  }
}
@interface SENSenseMessageBuilder()
@property (strong) SENSenseMessage* result;
@end

@implementation SENSenseMessageBuilder
@synthesize result;
- (void) dealloc {
  self.result = nil;
}
- (id) init {
  if ((self = [super init])) {
    self.result = [[SENSenseMessage alloc] init];
  }
  return self;
}
- (PBGeneratedMessage*) internalGetResult {
  return result;
}
- (SENSenseMessageBuilder*) clear {
  self.result = [[SENSenseMessage alloc] init];
  return self;
}
- (SENSenseMessageBuilder*) clone {
  return [SENSenseMessage builderWithPrototype:result];
}
- (SENSenseMessage*) defaultInstance {
  return [SENSenseMessage defaultInstance];
}
- (SENSenseMessage*) build {
  [self checkInitialized];
  return [self buildPartial];
}
- (SENSenseMessage*) buildPartial {
  SENSenseMessage* returnMe = result;
  self.result = nil;
  return returnMe;
}
- (SENSenseMessageBuilder*) mergeFrom:(SENSenseMessage*) other {
  if (other == [SENSenseMessage defaultInstance]) {
    return self;
  }
  if (other.hasVersion) {
    [self setVersion:other.version];
  }
  if (other.hasType) {
    [self setType:other.type];
  }
  if (other.hasDeviceId) {
    [self setDeviceId:other.deviceId];
  }
  if (other.hasAccountId) {
    [self setAccountId:other.accountId];
  }
  if (other.hasError) {
    [self setError:other.error];
  }
  if (other.hasWifiName) {
    [self setWifiName:other.wifiName];
  }
  if (other.hasWifiSsid) {
    [self setWifiSsid:other.wifiSsid];
  }
  if (other.hasWifiPassword) {
    [self setWifiPassword:other.wifiPassword];
  }
  if (other.hasBatteryLevel) {
    [self setBatteryLevel:other.batteryLevel];
  }
  if (other.hasUptime) {
    [self setUptime:other.uptime];
  }
  if (other.hasMotionData) {
    [self setMotionData:other.motionData];
  }
  if (other.hasMotionDataEncrypted) {
    [self setMotionDataEncrypted:other.motionDataEncrypted];
  }
  if (other.hasFirmwareVersion) {
    [self setFirmwareVersion:other.firmwareVersion];
  }
  if (other.wifisDetectedArray.count > 0) {
    if (result.wifisDetectedArray == nil) {
      result.wifisDetectedArray = [other.wifisDetectedArray copy];
    } else {
      [result.wifisDetectedArray appendArray:other.wifisDetectedArray];
    }
  }
  [self mergeUnknownFields:other.unknownFields];
  return self;
}
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input {
  return [self mergeFromCodedInputStream:input extensionRegistry:[PBExtensionRegistry emptyRegistry]];
}
- (SENSenseMessageBuilder*) mergeFromCodedInputStream:(PBCodedInputStream*) input extensionRegistry:(PBExtensionRegistry*) extensionRegistry {
  PBUnknownFieldSetBuilder* unknownFields = [PBUnknownFieldSet builderWithUnknownFields:self.unknownFields];
  while (YES) {
    NSInteger tag = [input readTag];
    switch (tag) {
      case 0:
        [self setUnknownFields:[unknownFields build]];
        return self;
      default: {
        if (![self parseUnknownField:input unknownFields:unknownFields extensionRegistry:extensionRegistry tag:tag]) {
          [self setUnknownFields:[unknownFields build]];
          return self;
        }
        break;
      }
      case 8: {
        [self setVersion:[input readInt32]];
        break;
      }
      case 16: {
        SENSenseMessageType value = (SENSenseMessageType)[input readEnum];
        if (SENSenseMessageTypeIsValidValue(value)) {
          [self setType:value];
        } else {
          [unknownFields mergeVarintField:2 value:value];
        }
        break;
      }
      case 26: {
        [self setDeviceId:[input readString]];
        break;
      }
      case 34: {
        [self setAccountId:[input readString]];
        break;
      }
      case 40: {
        ErrorType value = (ErrorType)[input readEnum];
        if (ErrorTypeIsValidValue(value)) {
          [self setError:value];
        } else {
          [unknownFields mergeVarintField:5 value:value];
        }
        break;
      }
      case 50: {
        [self setWifiName:[input readString]];
        break;
      }
      case 58: {
        [self setWifiSsid:[input readString]];
        break;
      }
      case 66: {
        [self setWifiPassword:[input readString]];
        break;
      }
      case 72: {
        [self setBatteryLevel:[input readInt32]];
        break;
      }
      case 80: {
        [self setUptime:[input readInt32]];
        break;
      }
      case 88: {
        [self setMotionData:[input readInt32]];
        break;
      }
      case 98: {
        [self setMotionDataEncrypted:[input readData]];
        break;
      }
      case 104: {
        [self setFirmwareVersion:[input readInt32]];
        break;
      }
      case 114: {
        SENWifiEndpointBuilder* subBuilder = [SENWifiEndpoint builder];
        [input readMessage:subBuilder extensionRegistry:extensionRegistry];
        [self addWifisDetected:[subBuilder buildPartial]];
        break;
      }
    }
  }
}
- (BOOL) hasVersion {
  return result.hasVersion;
}
- (long) version {
  return result.version;
}
- (SENSenseMessageBuilder*) setVersion:(long) value {
  result.hasVersion = YES;
  result.version = value;
  return self;
}
- (SENSenseMessageBuilder*) clearVersion {
  result.hasVersion = NO;
  result.version = 0;
  return self;
}
- (BOOL) hasType {
  return result.hasType;
}
- (SENSenseMessageType) type {
  return result.type;
}
- (SENSenseMessageBuilder*) setType:(SENSenseMessageType) value {
  result.hasType = YES;
  result.type = value;
  return self;
}
- (SENSenseMessageBuilder*) clearType {
  result.hasType = NO;
  result.type = SENSenseMessageTypeSetTime;
  return self;
}
- (BOOL) hasDeviceId {
  return result.hasDeviceId;
}
- (NSString*) deviceId {
  return result.deviceId;
}
- (SENSenseMessageBuilder*) setDeviceId:(NSString*) value {
  result.hasDeviceId = YES;
  result.deviceId = value;
  return self;
}
- (SENSenseMessageBuilder*) clearDeviceId {
  result.hasDeviceId = NO;
  result.deviceId = @"";
  return self;
}
- (BOOL) hasAccountId {
  return result.hasAccountId;
}
- (NSString*) accountId {
  return result.accountId;
}
- (SENSenseMessageBuilder*) setAccountId:(NSString*) value {
  result.hasAccountId = YES;
  result.accountId = value;
  return self;
}
- (SENSenseMessageBuilder*) clearAccountId {
  result.hasAccountId = NO;
  result.accountId = @"";
  return self;
}
- (BOOL) hasError {
  return result.hasError;
}
- (ErrorType) error {
  return result.error;
}
- (SENSenseMessageBuilder*) setError:(ErrorType) value {
  result.hasError = YES;
  result.error = value;
  return self;
}
- (SENSenseMessageBuilder*) clearError {
  result.hasError = NO;
  result.error = ErrorTypeTimeOut;
  return self;
}
- (BOOL) hasWifiName {
  return result.hasWifiName;
}
- (NSString*) wifiName {
  return result.wifiName;
}
- (SENSenseMessageBuilder*) setWifiName:(NSString*) value {
  result.hasWifiName = YES;
  result.wifiName = value;
  return self;
}
- (SENSenseMessageBuilder*) clearWifiName {
  result.hasWifiName = NO;
  result.wifiName = @"";
  return self;
}
- (BOOL) hasWifiSsid {
  return result.hasWifiSsid;
}
- (NSString*) wifiSsid {
  return result.wifiSsid;
}
- (SENSenseMessageBuilder*) setWifiSsid:(NSString*) value {
  result.hasWifiSsid = YES;
  result.wifiSsid = value;
  return self;
}
- (SENSenseMessageBuilder*) clearWifiSsid {
  result.hasWifiSsid = NO;
  result.wifiSsid = @"";
  return self;
}
- (BOOL) hasWifiPassword {
  return result.hasWifiPassword;
}
- (NSString*) wifiPassword {
  return result.wifiPassword;
}
- (SENSenseMessageBuilder*) setWifiPassword:(NSString*) value {
  result.hasWifiPassword = YES;
  result.wifiPassword = value;
  return self;
}
- (SENSenseMessageBuilder*) clearWifiPassword {
  result.hasWifiPassword = NO;
  result.wifiPassword = @"";
  return self;
}
- (BOOL) hasBatteryLevel {
  return result.hasBatteryLevel;
}
- (long) batteryLevel {
  return result.batteryLevel;
}
- (SENSenseMessageBuilder*) setBatteryLevel:(long) value {
  result.hasBatteryLevel = YES;
  result.batteryLevel = value;
  return self;
}
- (SENSenseMessageBuilder*) clearBatteryLevel {
  result.hasBatteryLevel = NO;
  result.batteryLevel = 0;
  return self;
}
- (BOOL) hasUptime {
  return result.hasUptime;
}
- (long) uptime {
  return result.uptime;
}
- (SENSenseMessageBuilder*) setUptime:(long) value {
  result.hasUptime = YES;
  result.uptime = value;
  return self;
}
- (SENSenseMessageBuilder*) clearUptime {
  result.hasUptime = NO;
  result.uptime = 0;
  return self;
}
- (BOOL) hasMotionData {
  return result.hasMotionData;
}
- (long) motionData {
  return result.motionData;
}
- (SENSenseMessageBuilder*) setMotionData:(long) value {
  result.hasMotionData = YES;
  result.motionData = value;
  return self;
}
- (SENSenseMessageBuilder*) clearMotionData {
  result.hasMotionData = NO;
  result.motionData = 0;
  return self;
}
- (BOOL) hasMotionDataEncrypted {
  return result.hasMotionDataEncrypted;
}
- (NSData*) motionDataEncrypted {
  return result.motionDataEncrypted;
}
- (SENSenseMessageBuilder*) setMotionDataEncrypted:(NSData*) value {
  result.hasMotionDataEncrypted = YES;
  result.motionDataEncrypted = value;
  return self;
}
- (SENSenseMessageBuilder*) clearMotionDataEncrypted {
  result.hasMotionDataEncrypted = NO;
  result.motionDataEncrypted = [NSData data];
  return self;
}
- (BOOL) hasFirmwareVersion {
  return result.hasFirmwareVersion;
}
- (long) firmwareVersion {
  return result.firmwareVersion;
}
- (SENSenseMessageBuilder*) setFirmwareVersion:(long) value {
  result.hasFirmwareVersion = YES;
  result.firmwareVersion = value;
  return self;
}
- (SENSenseMessageBuilder*) clearFirmwareVersion {
  result.hasFirmwareVersion = NO;
  result.firmwareVersion = 0;
  return self;
}
- (PBAppendableArray *)wifisDetected {
  return result.wifisDetectedArray;
}
- (SENWifiEndpoint*)wifisDetectedAtIndex:(NSUInteger)index {
  return [result wifisDetectedAtIndex:index];
}
- (SENSenseMessageBuilder *)addWifisDetected:(SENWifiEndpoint*)value {
  if (result.wifisDetectedArray == nil) {
    result.wifisDetectedArray = [PBAppendableArray arrayWithValueType:PBArrayValueTypeObject];
  }
  [result.wifisDetectedArray addObject:value];
  return self;
}
- (SENSenseMessageBuilder *)setWifisDetectedArray:(NSArray *)array {
  result.wifisDetectedArray = [PBAppendableArray arrayWithArray:array valueType:PBArrayValueTypeObject];
  return self;
}
- (SENSenseMessageBuilder *)setWifisDetectedValues:(const SENWifiEndpoint* __strong *)values count:(NSUInteger)count {
  result.wifisDetectedArray = [PBAppendableArray arrayWithValues:values count:count valueType:PBArrayValueTypeObject];
  return self;
}
- (SENSenseMessageBuilder *)clearWifisDetected {
  result.wifisDetectedArray = nil;
  return self;
}
@end


// @@protoc_insertion_point(global_scope)
