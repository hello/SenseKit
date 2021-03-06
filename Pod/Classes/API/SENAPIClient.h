
#import <Foundation/Foundation.h>

typedef void (^SENAPIDataBlock)(id data, NSError* error);
typedef void (^SENAPIErrorBlock)(NSError* error);
typedef void (^SENAPIProgressBlock)(NSProgress* progress);

/**
 *  Notification sent when Sense API is changed to reachable
 */
extern NSString* const SENAPIReachableNotification;

/**
 *  Notification sent when Sense API is changed to unreachable
 */
extern NSString* const SENAPIUnreachableNotification;

@interface SENAPIClient : NSObject

/**
 *  The base URL for the suripu app service
 */
+ (NSURL*)baseURL;

/**
 *  Updates the base URL for the suripu app service
 *  @returns YES if the base path was successfully changed
 */
+ (BOOL)setBaseURLFromPath:(NSString*)baseURLPath;

/**
 *  Updates the base URL for the suripu app service to the default URL
 */
+ (void)resetToDefaultBaseURL;

/**
 *  Returns YES if base URL is reachable
 */
+ (BOOL)isAPIReachable;

///-------------------------------
/// @name HTTP Requests Formatting
///-------------------------------

/**
 *  Default header values sent with each request
 *
 *  @return headers
 */
+ (NSDictionary*)defaultHTTPHeaderValues;

/**
 *  Set a header to be sent with every request
 *
 *  @param value     value to set
 *  @param fieldName name of the header field
 */
+ (void)setValue:(id)value forHTTPHeaderField:(NSString*)fieldName;

///---------------------------
/// @name Making HTTP Requests
///---------------------------

/**
 *  Convenience helper for making a POST request
 *
 *  @param URLString       url to connect
 *  @param parameters      parameters to send
 *  @param completionBlock block invoked at completion
 */
+ (void)POST:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completionBlock;

/**
 *  Convenience helper for making a PUT request
 *
 *  @param URLString       url to connect
 *  @param parameters      parameters to send
 *  @param completionBlock block invoked at completion
 */
+ (void)PUT:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completionBlock;

/**
 *  Convenience helper for making a GET request
 *
 *  @param URLString       url to connect
 *  @param parameters      parameters to send
 *  @param completionBlock block invoked at completion
 */
+ (void)GET:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completionBlock;

/**
 *  Convenience helper for making a PATCH request
 *
 *  @param URLString       url to connect
 *  @param parameters      parameters to send
 *  @param completionBlock block invoked at completion
 */
+ (void)PATCH:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completionBlock;

/**
 *  Convenience helper for making a DELETE request
 *
 *  @param URLString       url to connect
 *  @param parameters      parameters to send
 *  @param completionBlock block invoked at completion
 */
+ (void)DELETE:(NSString *)URLString parameters:(id)parameters completion:(SENAPIDataBlock)completionBlock;

/**
 *  Convenience helper to upload a file
 *
 *  @param data: the data of the file
 *  @param name: the name of the file
 *  @param fileName: the file name for the file
 *  @param mimeType: the content-type of the file
 *  @param progress: progress callback, if required
 *  @param completion: block to call upon completion
 */
+ (void)UPLOAD:(NSData*)data
          name:(NSString*)name
      fileName:(NSString*)fileName
      mimeType:(NSString*)mimeType
         toURL:(NSString*)urlString
    parameters:(id)parameters
      progress:(SENAPIProgressBlock)progress
    completion:(SENAPIDataBlock)completion;

@end
