
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SENAPIAccount.h"
#import "SENAccount.h"

NSString* const SENAPIAccountPropertyName = @"name";
NSString* const SENAPIAccountPropertyEmailAddress = @"email";
NSString* const SENAPIAccountPropertyPassword = @"password";
NSString* const SENAPIAccountPropertyHeight = @"height";
NSString* const SENAPIAccountPropertyWeight = @"weight";
NSString* const SENAPIAccountPropertyAge = @"age";
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
NSString* const SENAPIAccountEndpoint = @"account";

@implementation SENAPIAccount

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
    params[SENAPIAccountPropertyTimezone] = @([[NSTimeZone localTimeZone] secondsFromGMT] * 1000);

    NSString* URLPath = [NSString stringWithFormat:@"%@?sig=%@", SENAPIAccountEndpoint, @"xxx"];

    [[SENAPIClient HTTPSessionManager] POST:URLPath parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        SENAccount* account = nil;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            account = [self accountFromResponse:responseObject];
        }
        completionBlock(account, task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completionBlock(nil, error);
    }];
}

+ (void)updateUserAccountWithAge:(NSNumber*)age
                          gender:(SENAPIAccountGender)gender
                          height:(NSNumber*)heightInCentimeters
                          weight:(NSNumber*)weightInKilograms
                      completion:(SENAPIDataBlock)completionBlock {
    NSMutableDictionary* params = [[NSMutableDictionary alloc] initWithCapacity:4];
    params[SENAPIAccountPropertyGender] = [self formattedGenderForValue:gender];
    if (age)
        params[SENAPIAccountPropertyAge] = age;
    if (heightInCentimeters)
        params[SENAPIAccountPropertyHeight] = heightInCentimeters;
    if (weightInKilograms)
        params[SENAPIAccountPropertyWeight] = weightInKilograms;

    [[SENAPIClient HTTPSessionManager] PUT:SENAPIAccountEndpoint parameters:params success:^(NSURLSessionDataTask* task, id responseObject) {
        completionBlock(responseObject, task.error);
    } failure:^(NSURLSessionDataTask* task, NSError* error) {
        completionBlock(nil, error);
    }];
}

+ (void)updateAccount:(SENAccount*)account completionBlock:(SENAPIDataBlock)completion {
    [[SENAPIClient HTTPSessionManager] PUT:SENAPIAccountEndpoint
                                parameters:[self dictionaryValue:account]
                                   success:^(NSURLSessionDataTask* task, id responseObject) {
                                       completion(responseObject, task.error);
                                   }
                                   failure:^(NSURLSessionDataTask* task, NSError* error) {
                                       completion(nil, error);
                                   }];
}

#pragma mark - Helpers

+ (NSString*)formattedGenderForValue:(SENAPIAccountGender)gender
{
    switch (gender) {
    case SENAPIAccountGenderFemale:
        return @"FEMALE";

    case SENAPIAccountGenderMale:
        return @"MALE";

    case SENAPIAccountGenderOther:
    default:
        return @"OTHER";
    }
}

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
+ (NSDictionary*)dictionaryValue:(SENAccount*)account {
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
    return params;
}

/**
 * Convenience method to ensure an object is of a certain type.
 * @param object: object to check
 * @param clazz: the class the object should be
 * @return object if is of class.  nil otherwise
 */
+ (id)object:(id)object mustBe:(Class)clazz {
    return [object isKindOfClass:clazz]?object:nil;
}

/**
 * Convert the response object, which should be a NSDictionary, into A SENAccount
 * object, ensuring proper typing of values
 * @param responseObject: the response object
 * @return SENAccount representation of the response
 */
+ (SENAccount*)accountFromResponse:(id)responseObject {
    SENAccount* account = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        // calling object:mustBe: for each object so that NSNull (or wrong type)
        // will never be set inside the account object.  The reason is because
        // setting the value in the object is fine, even if property is different
        // then what is passed but when you try to operate on the value, expecting
        // that's the correct class, it will crash at runtime.
        NSString* accountId = [self object:responseObject[SENAPIAccountPropertyId] mustBe:[NSString class]];
        NSNumber* lastModified = [self object:responseObject[SENAPIAccountPropertyLastModified] mustBe:[NSNumber class]];
        NSString* name = [self object:responseObject[SENAPIAccountPropertyName] mustBe:[NSString class]];
        NSString* gender = [self object:responseObject[SENAPIAccountPropertyGender] mustBe:[NSString class]];
        NSNumber* weight = [self object:responseObject[SENAPIAccountPropertyWeight] mustBe:[NSNumber class]];
        NSNumber* height = [self object:responseObject[SENAPIAccountPropertyHeight] mustBe:[NSNumber class]];
        NSString* email = [self object:responseObject[SENAPIAccountPropertyEmailAddress] mustBe:[NSString class]];
        NSString* birthdate = [self object:responseObject[SENAPIAccountPropertyBirthdate] mustBe:[NSString class]];
        NSNumber* latitude = [self object:responseObject mustBe:[NSNumber class]];
        NSNumber* longitude = [self object:responseObject mustBe:[NSNumber class]];
        
        account = [[SENAccount alloc] initWithAccountId:accountId lastModified:lastModified];
        [account setName:name];
        [account setGender:[self genderFromString:gender]];
        [account setWeight:weight];
        [account setHeight:height];
        [account setEmail:email];
        [account setBirthdate:birthdate];
        [account setLatitude:latitude];
        [account setLongitude:longitude];
    }
    return account;
}

@end
