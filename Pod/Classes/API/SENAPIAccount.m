
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"
#import "Model.h"

NSString* const kSENAccountNotificationAccountCreated = @"SENAccountCreated";

NSString* const SENAPIAccountEndpoint = @"v1/account";
NSString* const SENAPIAccountErrorDomain = @"is.hello.account";

NSString* const SENAPIAccountPropertyName = @"name";
NSString* const SENAPIAccountPropertyEmailAddress = @"email";
NSString* const SENAPIAccountPropertyPassword = @"password";
NSString* const SENAPIAccountPropertyHeight = @"height";
NSString* const SENAPIAccountPropertyWeight = @"weight";
NSString* const SENAPIAccountPropertyTimezone = @"tz";
NSString* const SENAPIAccountPropertySignature = @"sig";
NSString* const SENAPIAccountPropertyId = @"id";
NSString* const SENAPIAccountPropertyLastModified = @"last_modified";
NSString* const SENAPIAccountPropertyBirthdate = @"dob";
NSString* const SENAPIAccountPropertyGender = @"gender";
NSString* const SENAPIAccountPropertyValueGenderOther = @"OTHER";
NSString* const SENAPIAccountPropertyValueGenderMale = @"MALE";
NSString* const SENAPIAccountPropertyValueGenderFemale = @"FEMALE";
NSString* const SENAPIAccountPropertyValueLatitude = @"lat";
NSString* const SENAPIAccountPropertyValueLongitude = @"lon";
NSString* const SENAPIAccountPropertyValueCreated = @"created";
NSString* const SENAPIAccountPropertyCurrentPassword = @"current_password";
NSString* const SENAPIAccountPropertyNewPassword = @"new_password";

NSString* const SENAPIAccountErrorResponseMessageKey= @"message";
NSString* const SENAPIAccountErrorMessagePasswordTooShort = @"PASSWORD_TOO_SHORT";
NSString* const SENAPIAccountErrorMessagePasswordInsecure= @"PASSWORD_INSECURE";
NSString* const SENAPIAccountErrorMessageNameTooLong = @"NAME_TOO_LONG";
NSString* const SENAPIAccountErrorMessageNameTooShort = @"NAME_TOO_SHORT";
NSString* const SENAPIAccountErrorMessageEmailInvalid = @"EMAIL_INVALID";

@implementation SENAPIAccount

+ (NSNumber*)currentTimezoneInMillis {
    return @([[NSTimeZone localTimeZone] secondsFromGMT] * 1000);
}

+ (void)createAccountWithName:(NSString*)name
                 emailAddress:(NSString*)emailAddress
                     password:(NSString*)password
                   completion:(SENAPIDataBlock)completionBlock {
    
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:5];

    if (password)
        params[SENAPIAccountPropertyPassword] = password;
    if (emailAddress)
        params[SENAPIAccountPropertyEmailAddress] = emailAddress;
    if (name)
        params[SENAPIAccountPropertyName] = name;
    params[SENAPIAccountPropertyTimezone] = [self currentTimezoneInMillis];

    NSString* URLPath = [NSString stringWithFormat:@"%@?sig=%@", SENAPIAccountEndpoint, @"xxx"];

    [SENAPIClient POST:URLPath parameters:params completion:^(id responseObject, NSError *error) {
        SENAccount* account = nil;
        if (error == nil && [responseObject isKindOfClass:[NSDictionary class]]) {
            account = [self accountFromResponse:responseObject];
            if (account != nil) {
                NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
                [center postNotificationName:kSENAccountNotificationAccountCreated
                                      object:nil];
            }
        }
        completionBlock(account, error);
    }];
}

+ (void)updateAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    NSMutableDictionary* accountDict = [self dictionaryValue:account];
    accountDict[SENAPIAccountPropertyTimezone] = [self currentTimezoneInMillis];
    
    [SENAPIClient PUT:SENAPIAccountEndpoint parameters:accountDict completion:^(id data, NSError *error) {
        SENAccount* account = nil;
        if (error == nil && [data isKindOfClass:[NSDictionary class]]) {
            account = [self accountFromResponse:data];
        }
        if (completion) completion (account, error);
    }];
}

+ (void)getAccount:(SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIAccountEndpoint
           parameters:nil
           completion:^(id data, NSError *error) {
               SENAccount* account = nil;
               if ([data isKindOfClass:[NSDictionary class]]) {
                   account = [self accountFromResponse:data];
               }
               completion(account, error);
           }];
}

+ (void)changePassword:(NSString*)currentPassword
         toNewPassword:(NSString*)password
       completionBlock:(SENAPIDataBlock)completion {
    if ([currentPassword length] == 0 || [password length] == 0) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIAccountErrorDomain
                                                 code:SENAPIAccountErrorInvalidArgument
                                             userInfo:nil]);
        }
        return;
    }
    NSDictionary* body = @{SENAPIAccountPropertyCurrentPassword : currentPassword,
                           SENAPIAccountPropertyNewPassword : password};
    NSString* path = [SENAPIAccountEndpoint stringByAppendingPathComponent:@"password"];
    [SENAPIClient POST:path parameters:body completion:completion];
}

+ (void)changeEmailInAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    if (account == nil || [[account email] length] == 0) {
        if (completion) {
            completion (nil, [NSError errorWithDomain:SENAPIAccountErrorDomain
                                                 code:SENAPIAccountErrorInvalidArgument
                                             userInfo:nil]);
        }
        return;
    }
    
    NSDictionary* body = [self dictionaryValue:account];
    NSString* path = [SENAPIAccountEndpoint stringByAppendingPathComponent:@"email"];
    [SENAPIClient POST:path parameters:body completion:completion];
}

+ (SENAPIAccountError)errorForAPIResponseError:(NSError*)error {
    NSData* errorData = error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    SENAPIAccountError errorType = SENAPIAccountErrorUnknown;

    if (errorData != nil) {
        id errorResponse = [NSJSONSerialization JSONObjectWithData:errorData options:NSJSONReadingMutableContainers error:nil];
        if ([errorResponse isKindOfClass:[NSDictionary class]]) {
            NSString* responseMessage = errorResponse[SENAPIAccountErrorResponseMessageKey];
            if ([responseMessage isEqualToString:SENAPIAccountErrorMessagePasswordTooShort]) {
                errorType = SENAPIAccountErrorPasswordTooShort;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessagePasswordInsecure]) {
                errorType = SENAPIAccountErrorPasswordInsecure;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageNameTooLong]) {
                errorType = SENAPIAccountErrorNameTooLong;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageNameTooShort]) {
                errorType = SENAPIAccountErrorNameTooShort;
            } else if ([responseMessage isEqualToString:SENAPIAccountErrorMessageEmailInvalid]) {
                errorType = SENAPIAccountErrorEmailInvalid;
            }
        }
    }
    
    return errorType;
}

#pragma mark - Helpers

+ (NSString*)stringValueOfGender:(SENAccountGender)gender {
    NSString* value;
    switch (gender) {
        case SENAccountGenderFemale:
            value = SENAPIAccountPropertyValueGenderFemale;
            break;
        case SENAccountGenderMale:
            value = SENAPIAccountPropertyValueGenderMale;
            break;
        default:
            value = SENAPIAccountPropertyValueGenderOther;
            break;
    }
    return value;
}

+ (SENAccountGender)genderFromString:(NSString*)genderString {
    SENAccountGender gender = SENAccountGenderOther;
    if ([[genderString uppercaseString] isEqualToString:SENAPIAccountPropertyValueGenderFemale]) {
        gender = SENAccountGenderFemale;
    } else if ([[genderString uppercaseString] isEqualToString:SENAPIAccountPropertyValueGenderMale]) {
        gender = SENAccountGenderMale;
    }
    return gender;
}

/**
 * Convert the account object in to a dictionary that can be used as the parameter
 * value in updating the account.  Note that not all properties should be passed
 * back through the API such as the account Id and password.  The password should
 * be updated by itself.
 *
 * only values that are non-nil will be set.
 *
 * @param account: the account object to convert to a dictionary.
 * @return         a dictionary containing non-nil values from the account object.
 */
+ (NSMutableDictionary*)dictionaryValue:(SENAccount*)account {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:[account name] forKey:SENAPIAccountPropertyName];
    [params setValue:[account email] forKey:SENAPIAccountPropertyEmailAddress];
    [params setValue:[account weight] forKey:SENAPIAccountPropertyWeight];
    [params setValue:[account height] forKey:SENAPIAccountPropertyHeight];
    [params setValue:[self stringValueOfGender:[account gender]] forKey:SENAPIAccountPropertyGender];
    [params setValue:[account birthdate] forKey:SENAPIAccountPropertyBirthdate];
    [params setValue:[account lastModified] forKey:SENAPIAccountPropertyLastModified];
    [params setValue:[account latitude] forKey:SENAPIAccountPropertyValueLatitude];
    [params setValue:[account longitude] forKey:SENAPIAccountPropertyValueLongitude];
    [params setValue:[account createdAt] forKey:SENAPIAccountPropertyValueCreated];
    return params;
}

/**
 * Convert the response object, which should be a NSDictionary, into A SENAccount
 * object, ensuring proper typing of values
 * @param responseObject: the response object
 * @return SENAccount representation of the response
 */
+ (SENAccount*)accountFromResponse:(id)responseObject {
    if (![responseObject respondsToSelector:@selector(objectForKeyedSubscript:)])
        return nil;
    // calling object:mustBe: for each object so that NSNull (or wrong type)
    // will never be set inside the account object.  The reason is because
    // setting the value in the object is fine, even if property is different
    // then what is passed but when you try to operate on the value, expecting
    // that's the correct class, it will crash at runtime.
    NSString* accountId = SENObjectOfClass(responseObject[SENAPIAccountPropertyId], [NSString class]);
    NSNumber* lastModified = SENObjectOfClass(responseObject[SENAPIAccountPropertyLastModified], [NSNumber class]);
    NSNumber* createdAt = SENObjectOfClass(responseObject[SENAPIAccountPropertyLastModified], [NSNumber class]);
    NSString* name = SENObjectOfClass(responseObject[SENAPIAccountPropertyName], [NSString class]);
    NSString* gender = SENObjectOfClass(responseObject[SENAPIAccountPropertyGender], [NSString class]);
    NSNumber* weight = SENObjectOfClass(responseObject[SENAPIAccountPropertyWeight], [NSNumber class]);
    NSNumber* height = SENObjectOfClass(responseObject[SENAPIAccountPropertyHeight], [NSNumber class]);
    NSString* email = SENObjectOfClass(responseObject[SENAPIAccountPropertyEmailAddress], [NSString class]);
    NSString* birthdate = SENObjectOfClass(responseObject[SENAPIAccountPropertyBirthdate], [NSString class]);
    NSNumber* latitude = SENObjectOfClass(responseObject[SENAPIAccountPropertyValueLatitude], [NSNumber class]);
    NSNumber* longitude = SENObjectOfClass(responseObject[SENAPIAccountPropertyValueLongitude], [NSNumber class]);
    
    SENAccount* account = [[SENAccount alloc] initWithAccountId:accountId lastModified:lastModified];
    [account setName:name];
    [account setGender:[self genderFromString:gender]];
    [account setWeight:weight];
    [account setHeight:height];
    [account setEmail:email];
    [account setLatitude:latitude];
    [account setLongitude:longitude];
    [account setBirthdate:birthdate];
    [account setCreatedAt:[NSDate dateWithTimeIntervalSince1970:[createdAt unsignedIntegerValue]]];
    return account;
}

@end
