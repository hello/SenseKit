//
//  SENAccount.m
//  Pods
//
//  Created by Jimmy Lu on 9/3/14.
//  Copyright (c) 2014 Hello Inc. All rights reserved.
//

#import "SENAccount.h"

@interface SENAccount()

@property (nonatomic, copy, readwrite)   NSString* accountId;
@property (nonatomic, copy, readwrite)   NSString* lastModified;

@end

@implementation SENAccount

- (instancetype)initWithAccountId:(NSString*)accountId
                     lastModified:(NSString*)isoLastModDate {
    self = [super init];
    if (self) {
        [self setAccountId:accountId];
        [self setLastModified:isoLastModDate];
    }
    return self;
}

@end
