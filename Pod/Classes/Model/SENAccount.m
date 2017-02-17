//
//  SENAccount.m
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENAccount.h"
#import "Model.h"

NSString* const SENAccountPropertyValueGenderOther = @"OTHER";
NSString* const SENAccountPropertyValueGenderMale = @"MALE";
NSString* const SENAccountPropertyValueGenderFemale = @"FEMALE";

SENAccountGender SENAccountGenderFromString(NSString* gender) {
    if ([[gender uppercaseString] isEqualToString:SENAccountPropertyValueGenderFemale])
        return SENAccountGenderFemale;
    else if ([[gender uppercaseString] isEqualToString:SENAccountPropertyValueGenderMale])
        return SENAccountGenderMale;
    return SENAccountGenderOther;
}

@interface SENAccount()

@property (nonatomic, copy, readwrite) NSString* accountId;
@property (nonatomic, copy, readwrite) NSNumber* lastModified;
@property (nonatomic, strong) NSDate* dobDate;

@end

@implementation SENAccount

NSString* const SENAccountPropertyFName = @"firstname";
NSString* const SENAccountPropertyLName = @"lastname";
NSString* const SENAccountPropertyTimeZone = @"time_zone";
NSString* const SENAccountPropertyEmailAddress = @"email";
NSString* const SENAccountPropertyPassword = @"password";
NSString* const SENAccountPropertyHeight = @"height";
NSString* const SENAccountPropertyWeight = @"weight";
NSString* const SENAccountPropertyId = @"id";
NSString* const SENAccountPropertyLastModified = @"last_modified";
NSString* const SENAccountPropertyBirthdate = @"dob";
NSString* const SENAccountPropertyGender = @"gender";
NSString* const SENAccountPropertyGenderCustom = @"gender_other";
NSString* const SENAccountPropertyValueLatitude = @"lat";
NSString* const SENAccountPropertyValueLongitude = @"long";
NSString* const SENAccountPropertyCreated = @"created";
NSString* const SENAccountPropertyProfilePhoto = @"profile_photo";

- (instancetype)initWithDictionary:(NSDictionary *)data {
    if (![data isKindOfClass:[NSDictionary class]])
        return nil;
    if (self = [super init]) {
        _accountId = SENObjectOfClass(data[SENAccountPropertyId], [NSString class]);
        _lastModified = SENObjectOfClass(data[SENAccountPropertyLastModified], [NSNumber class]);
        _lastName = SENObjectOfClass(data[SENAccountPropertyLName], [NSString class]);
        _firstName = SENObjectOfClass(data[SENAccountPropertyFName], [NSString class]);
        _gender = SENAccountGenderFromString(SENObjectOfClass(data[SENAccountPropertyGender], [NSString class]));
        _weight = SENObjectOfClass(data[SENAccountPropertyWeight], [NSNumber class]);
        _height = SENObjectOfClass(data[SENAccountPropertyHeight], [NSNumber class]);
        _email = SENObjectOfClass(data[SENAccountPropertyEmailAddress], [NSString class]);
        _birthdate = SENObjectOfClass(data[SENAccountPropertyBirthdate], [NSString class]);
        _latitude = SENObjectOfClass(data[SENAccountPropertyValueLatitude], [NSNumber class]);
        _longitude = SENObjectOfClass(data[SENAccountPropertyValueLongitude], [NSNumber class]);
        _timeZone = SENObjectOfClass(data[SENAccountPropertyTimeZone], [NSString class]);
        _customGender = SENObjectOfClass(data[SENAccountPropertyGenderCustom], [NSString class]);

        NSNumber *createdAt = SENObjectOfClass(data[SENAccountPropertyCreated], [NSNumber class]);
        if (createdAt) {
            _createdAt = SENDateFromNumber(createdAt);
        }
        
        NSDictionary* photoObj = SENObjectOfClass(data[SENAccountPropertyProfilePhoto], [NSDictionary class]);
        if (photoObj) {
            _photo = [[SENRemoteImage alloc] initWithDictionary:photoObj];
        }
    }
    return self;
}

- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSNumber*)isoLastModDate {
    self = [super init];
    if (self) {
        [self setAccountId:accountId];
        [self setLastModified:isoLastModDate];
    }
    return self;
}

- (NSString*)timeZone {
    if (!_timeZone) {
        _timeZone = [[[NSTimeZone localTimeZone] name] copy];
    }
    return _timeZone;
}

- (void)setBirthdate:(NSString *)birthdate {
    _birthdate = birthdate;
    [self setDobDate:nil];
}

- (NSString*)genderStringValue {
    switch ([self gender]) {
        case SENAccountGenderFemale:
            return SENAccountPropertyValueGenderFemale;
        case SENAccountGenderMale:
            return SENAccountPropertyValueGenderMale;
        default:
            return SENAccountPropertyValueGenderOther;
    }
}

- (NSDictionary *)dictionaryValue {
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    [params setValue:self.firstName forKey:SENAccountPropertyFName];
    [params setValue:self.lastName forKey:SENAccountPropertyLName];
    [params setValue:self.email forKey:SENAccountPropertyEmailAddress];
    [params setValue:self.weight forKey:SENAccountPropertyWeight];
    [params setValue:self.height forKey:SENAccountPropertyHeight];
    [params setValue:[self genderStringValue] forKey:SENAccountPropertyGender];
    [params setValue:self.birthdate forKey:SENAccountPropertyBirthdate];
    [params setValue:self.lastModified forKey:SENAccountPropertyLastModified];
    [params setValue:self.latitude forKey:SENAccountPropertyValueLatitude];
    [params setValue:self.longitude forKey:SENAccountPropertyValueLongitude];
    [params setValue:self.timeZone forKey:SENAccountPropertyTimeZone];
    [params setValue:self.customGender forKey:SENAccountPropertyGenderCustom];
    
    if (self.createdAt) {
        [params setValue:SENDateMillisecondsSince1970(self.createdAt) forKey:SENAccountPropertyCreated];
    }
    // purposely ignore the photo as it should not be sent back up to the server
    return params;
}

- (void)setBirthMonth:(NSInteger)month day:(NSInteger)day andYear:(NSInteger)year {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    [components setCalendar:[NSCalendar autoupdatingCurrentCalendar]];
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    [self setBirthdate:[formatter stringFromDate:[components date]]];
}

- (void)setBirthdateInMillis:(NSNumber*)birthdateInMillis {
    if (birthdateInMillis == nil) return;
    NSString* const SENAccountDateTimeZone = @"GMT";
    NSDateFormatter* formatter = [self isoDateFormatter];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:SENAccountDateTimeZone]];
    [self setBirthdate:[formatter stringFromDate:SENDateFromNumber(birthdateInMillis)]];
}

- (NSDateFormatter*)isoDateFormatter {
    NSString* const SENAccountDoBFormat = @"yyyy-MM-dd";
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:SENAccountDoBFormat];
    });
    return formatter;
}

- (NSString*)localizedBirthdateWithStyle:(NSDateFormatterStyle)style {
    if ([self dobDate] == nil) {
        NSDateFormatter* fromFormatter = [self isoDateFormatter];
        [self setDobDate:[fromFormatter dateFromString:[self birthdate]]];
    }
    return [NSDateFormatter localizedStringFromDate:[self dobDate]
                                          dateStyle:style
                                          timeStyle:NSDateFormatterNoStyle];
}

- (NSDateComponents*)birthdateComponents {
    if ([self birthdate] == nil) return nil;
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateFormatter* formatter = [self isoDateFormatter];
    [formatter setCalendar:calendar];
    
    NSDateComponents* components =
        [calendar components:NSCalendarUnitMonth
                             |NSCalendarUnitDay
                             |NSCalendarUnitYear
                    fromDate:[formatter dateFromString:[self birthdate]]];
    
    return components;
}

- (NSString*)fullName {
    NSString* firstName = [self firstName] ?: @"";
    NSString* lastName = [self lastName] ?: @"";
    return [NSString stringWithFormat:@"%@ %@", firstName, lastName];
}

@end
