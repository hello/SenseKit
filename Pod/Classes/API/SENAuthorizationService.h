
#import <Foundation/Foundation.h>

/**
 *  Notification sent when a user is authorized
 */
extern NSString* const SENAuthorizationServiceDidAuthorizeNotification;

/**
 *  Notification sent when a user is deauthorized
 */
extern NSString* const SENAuthorizationServiceDidDeauthorizeNotification;

/**
 * Notification sent when a user is reauthorized
 */
extern NSString* const SENAuthorizationServiceDidReauthorizeNotification;

@interface SENAuthorizationService : NSObject

/**
 *  Sends a request for a new access token, saving the returned credentials to the keychain.
 *  Future requests have the access token in the response set as the authorization header.
 *
 *  @param username the username of the entity to authorize
 *  @param password the password for the given username
 *  @param block    a block invoked after the authentication attempt is completed
 */
+ (void)authorizeWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(NSError* error))block;

/**
 * Reauthorizes the currently signed in user using the new password so that the
 * authorization token reflects the change.  Future requests will use the updated
 * token.
 *
 *  @param username the username of the entity to authorize
 *  @param password the password for the given username
 *  @param block    a block invoked after the authentication attempt is completed
 */
+ (void)reauthorizeUser:(NSString*)username password:(NSString*)password callback:(void(^)(NSError* error))block;

/**
 *  Load any cached credentials for use in API requests
 */
+ (void)authorizeRequestsFromKeychain;

/**
 *  Optimistically deauthorize future requests and remove the active credentials
 *  from the keychain.
 */
+ (void)deauthorize;

/**
 *  Deauthorize requests and sign out from the account.  If an error is encountered,
 *  The operation will be cancelled
 *
 *  @param completion: the callback to call when operation completes
 */
+ (void)deauthorize:(void(^)(NSError* error))completion;

/**
 *  Check whether there are cached credentials in the keychain
 */
+ (BOOL)isAuthorized;

/**
 *  Checks whether an error indicates an invalid API access token
 *
 *  @param error error to check
 *
 *  @return YES if the error indicates the token is deauthorized
 */
+ (BOOL)isAuthorizationError:(NSError*)error;

/**
 *  Checks whether a request has an authorization
 *
 *  @param request request to check
 *
 *  @return YES if the request has an authorization header set
 */
+ (BOOL)isAuthorizedRequest:(NSURLRequest*)request;

/**
 *  Authorize a request with the stored token, if available.  If user is not
 *  currently signed in, nil is returned
 *
 *  @param request: the request to authorize for current user
 *  @return authorized request, or nil if not signed in
 */
+ (NSURLRequest*)authorizeRequest:(NSURLRequest*)request;

/**
 * @return authenticated account id or nil
 */
+ (NSString*)accountIdOfAuthorizedUser;

/**
 * The access token of the authorized user, if authorized
 * @return the access token or nil if not authorized
 */
+ (NSString*)accessToken;

/**
 *  Update the client app ID
 *
 *  @param clientID the new client ID
 */
+ (void)setClientAppID:(NSString*)clientID;

@end
