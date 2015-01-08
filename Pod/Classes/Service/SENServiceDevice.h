//
//  SENServiceDevice.h
//  Pods
//
//  Created by Jimmy Lu on 12/29/14.
//
//

#import "SENService.h"
#import "SENSenseManager.h"

@class SENDevice;
@class SENSenseManager;

extern NSString* const SENServiceDeviceNotificationFactorySettingsRestored;
extern NSString* const SENServiceDeviceNotificationWarning;
extern NSString* const SENServiceDeviceErrorDomain;

typedef NS_ENUM(NSUInteger, SENServiceDeviceState) {
    SENServiceDeviceStateUnknown = 0,
    SENServiceDeviceStateNormal = 1,
    SENServiceDeviceStateSenseNotPaired = 2,
    SENServiceDeviceStateSenseNoData = 3,
    SENServiceDeviceStateNotConnectedToWiFi = 4,
    SENServiceDeviceStatePillNotPaired = 5,
    SENServiceDeviceStatePillLowBattery = 6
};

typedef NS_ENUM(NSInteger, SENServiceDeviceError) {
    SENServiceDeviceErrorSenseUnavailable = -1,
    SENServiceDeviceErrorBLEUnavailable = -2,
    SENServiceDeviceErrorInProgress = -3,
    SENServiceDeviceErrorSenseNotPaired = -4,
    SENServiceDeviceErrorPillNotPaired = -5,
    SENServiceDeviceErrorUnpairPillFromSense = -6,
    SENServiceDeviceErrorUnlinkPillFromAccount = -7,
    SENServiceDeviceErrorUnlinkSenseFromAccount = -8
};

typedef void(^SENServiceDeviceCompletionBlock)(NSError* error);

@interface SENServiceDevice : SENService

/**
 * @property pillInfo: the device information for the Sleep Pill
 */
@property (nonatomic, strong, readonly) SENDevice* pillInfo;

/**
 * @property pillInfo: the device information for the Sense
 */
@property (nonatomic, strong, readonly) SENDevice* senseInfo;

/**
 * @property systemState: the state of the current Sense system
 */
@property (nonatomic, assign, readonly) SENServiceDeviceState deviceState;

/**
 * @property monitorDeviceStates: 
 * 
 * @discussion
 * YES to be notified of device warning / states, NO otherwise
 */
@property (nonatomic, assign) BOOL monitorDeviceStates;

/**
 * @property senseManager: the manager for the paired Sense that was found.  You
 *                         should only use this outside of the center if it's a
 *                         one off operation that does not require any interaction
 *                         with the API.
 *
 * @see loadDeviceInfo:
 * @see scanForPairedSense:
 */
@property (nonatomic, strong, readonly) SENSenseManager* senseManager;

/**
 * @property loadingInfo: flag that indicates whether or not device information
 *                        is still being loaded
 */
@property (nonatomic, assign, readonly, getter=isLoadingInfo) BOOL loadingInfo;

/**
 * @property infoLoaded: flag that indicates whether or not device information
 *                       has been loaded
 *
 * @discussion
 * If this flag returns YES and pillInfo or senseInfo is nil, then that signifies
 * that such device has not yet been paired
 *
 * @see @property pillInfo
 * @see @property senseInfo
 */
@property (nonatomic, assign, readonly, getter=isInfoLoaded) BOOL infoLoaded;

+ (instancetype)sharedService;

/**
 * @method clearCache:
 *
 * @discussion
 * Clear the cache of device information and state of the center.  You should
 * only do this if switching users or resetting back to factory.
 */
- (void)clearCache;

/**
 * @method loadDeviceInfo
 *
 * @discussion
 * Load device information, populating both pillInfo and senseInfo on successful
 * completion.
 *
 * @param completion: the block to invoke when complete
 *
 * @see @property pillInfo
 * @see @property senseInfo
 */
- (void)loadDeviceInfo:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method scanForPairedSense
 *
 * @discussion
 * scan for Sense that is paired / linked to the user's account.  If device info
 * has not been loaded, it will attempt to request that information before starting
 * the scan.
 *
 * @param completion: the block to invoke when complete
 *
 * @see @property senseInfo
 * @see @method stopSenseOperations
 */
- (void)scanForPairedSense:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method putSenseIntoPairingMode
 *
 * @discussion
 * Put sense in to pairing mode.  If sense is already in pairing mode, this operation
 * will essentially do nothing but connect to Sense itself.
 *
 * @param completion: the block to invoke when complete
 *
 * @see @method stopSenseOperations
 */
- (void)putSenseIntoPairingMode:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method currentSenseRSSI
 *
 * @discussion
 * Grab the current RSSI value from Sense, if Sense is currently available and
 * close enough for the operation to succeed.
 *
 * @param completion: the completion block to invoke when done
 *
 *  * @see @method stopSenseOperations
 */
- (void)currentSenseRSSI:(void(^)(NSNumber* rssi, NSError* error))completion;

/**
 * @method stopScanning
 *
 * @discussion
 * If Sense is currently scanning, it will stop scanning for devices
 */
- (void)stopScanning;

/*
 * @method pairedSenseAvailable
 *
 * @discussion
 * Determine if a paired / linked Sense is currently available for use.  This suggests
 * that the device has been found / scanned and currently ready to take on operations
 *
 * @return YES if available, NO if never scanned for or simply not available.
 */
- (BOOL)pairedSenseAvailable;

/**
 * @method unpairSleepPill
 *
 * @discussion
 * Unpair the sleep pill that is currently linked to the signed in user's account,
 * identified by pillInfo.  If a Sleep Pill is not currently linked, completion
 * block will be immediately called with an error.
 *
 * @property completion: the block to invoke when done
 * @see @property pillInfo
 */
- (void)unpairSleepPill:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method unlinkSenseFromACcount:
 *
 * @discussion
 * Unlink / unpair the Sense, if one is paired, from the currently signed in
 * account.  After doing so, the service will remove any sense device information
 * as well as disconnect / remove SenseManager upon successful unlinking
 *
 * @param completion: the block to invoke when this is done
 */
- (void)unlinkSenseFromAccount:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method restoreFactorySettings:
 *
 * @discussion
 * Restore factory settings for the Sense system, which includes Sense as well
 * as the Sleep Pill.  This will do the following:
 *
 *     1. remove bond between this device and Sense
 *     2. clear WiFi credentials set, which will disconnect Sense from network
 *     3. Unpair / unlink Sleep Pill, if paired, from user's account
 *     4. Unpair / unlink Sense from user's account
 *
 * Upon completion, if no error is encountered, a notification with the name:
 * kHEMDeviceNotificationFactorySettingsRestored will be posted.  Act accordingly
 *
 * Please note that if Sense is not currently cached, this will assume Sense has
 * already been reset, disconnected and cleared.  Be sure to only call this method
 * once Sense is cached / scanned.
 *
 * User will still need to go in to Settings App to "Forget This Device".
 *
 * @property completion: the block to invoke when done
 */
- (void)restoreFactorySettings:(SENServiceDeviceCompletionBlock)completion;

/**
 * @method getConfiguredWiFi
 *
 * @discussion
 * This is just a wrapper around SENSenseManager's getConfiguredWifi method,
 * but will ensure a paired sense is detected before proceeding
 */
- (void)getConfiguredWiFi:(void(^)(NSString* ssid,
                                   SENWiFiConnectionState state,
                                   NSError* error))completion;

/**
 * @method: setLEDState:completion
 *
 * @discussion
 * Set the LED state of the currently paired Sense.
 *
 * @param state:      state of the LED on Sense to set
 * @param completion: the block to invoke when done
 */
- (void)setLEDState:(SENSenseLEDState)state completion:(SENServiceDeviceCompletionBlock)completion;

@end