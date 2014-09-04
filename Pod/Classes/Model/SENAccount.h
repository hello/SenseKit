//
//  SENAccount.h
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SENAccountGender) {
    SENAccountGenderOther,
    SENAccountGenderMale,
    SENAccountGenderFemale
};

@interface SENAccount : NSObject

@property (nonatomic, copy, readonly)    NSString* accountId;

/**
 * @property lastModified
 * 
 * The date of which this account was last modified.  Required
 * when making additional updates after account creation
 */
@property (nonatomic, copy, readonly)    NSString* lastModified;

/**
 * @property name
 *
 * The name of the user that this account belongs to
 */
@property (nonatomic, copy, readwrite)   NSString* name;

/**
 * @property name
 *
 * The email address that the user wants to use.  Email address is
 * used for authentication as well.
 */
@property (nonatomic, copy, readwrite)   NSString* email;

/**
 * @property gender
 *
 * The gender of the user.  Defaults to SENAccountOther
 */
@property (nonatomic, assign, readwrite) SENAccountGender gender;

/**
 * @property weight
 *
 * The weight
 */
@property (nonatomic, strong, readwrite) NSNumber* weight; // in kg
@property (nonatomic, strong, readwrite) NSNumber* height; // in cm
@property (nonatomic, copy, readwrite)   NSString* birthdate;

- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSString*)isoLastModDate;

@end
