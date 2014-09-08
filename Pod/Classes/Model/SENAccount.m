//
//  SENAccount.m
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENAccount.h"

@interface SENAccount()

@property (nonatomic, copy, readwrite) NSString* accountId;
@property (nonatomic, copy, readwrite) NSNumber* lastModified;

@end

@implementation SENAccount

- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSNumber*)isoLastModDate {
    self = [super init];
    if (self) {
        [self setAccountId:accountId];
        [self setLastModified:isoLastModDate];
    }
    return self;
}

- (void)setBirthMonth:(NSInteger)month day:(NSInteger)day andYear:(NSInteger)year {
    NSDateComponents* components = [[NSDateComponents alloc] init];
    [components setDay:day];
    [components setMonth:month];
    [components setYear:year];
    [components setCalendar:[NSCalendar currentCalendar]];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [self setBirthdate:[formatter stringFromDate:[components date]]];
}

@end
