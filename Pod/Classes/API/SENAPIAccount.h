
#import <Foundation/Foundation.h>
#import "SENAPIClient.h"

typedef NS_ENUM(NSUInteger, SENAPIAccountGender) {
    SENAPIAccountGenderFemale,
    SENAPIAccountGenderMale,
    SENAPIAccountGenderOther,
};

@class SENAccount;

@interface SENAPIAccount : NSObject

/**
 *  Create a new account via the Sense API. Does not require authentication.
 *
 *  @param name            full name of the new user
 *  @param emailAddress    email address
 *  @param password        password
 *  @param completionBlock block invoked when asynchonous call completes
 */
+ (void)createAccountWithName:(NSString*)name
                 emailAddress:(NSString*)emailAddress
                     password:(NSString*)password
                   completion:(SENAPIDataBlock)completionBlock;

/**
 *  Update the demographic information of the current user. Requires authentication.
 *
 *  @deprecated use updateAccount:completionBlock instead
 *
 *  @param age                 age in years
 *  @param gender              gender
 *  @param heightInCentimeters height in centimeters
 *  @param weight              weight in kilograms
 *  @param completionBlock     block invoked when asynchonous call completes
 */
+ (void)updateUserAccountWithAge:(NSNumber*)age
                          gender:(SENAPIAccountGender)gender
                          height:(NSNumber*)heightInCentimeters
                          weight:(NSNumber*)weightInKilograms
                      completion:(SENAPIDataBlock)completionBlock;

/**
 * Override the existing account information for the associated user.
 * 
 * Requires authentication.
 *
 * @param account    existing account for the user
 * @param completion block invoked when asynchronous call completes
 */
+ (void)updateAccount:(SENAccount*)account
      completionBlock:(SENAPIDataBlock)completion;

@end
