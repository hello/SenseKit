//
//  SENAPIAppStats.m
//  Pods
//
//  Created by Jimmy Lu on 10/2/15.
//
//

#import "SENAPIAppStats.h"
#import "SENAppStats.h"
#import "SENAppUnreadStats.h"

static NSString* const SENAPIAppStatusEndpoint = @"v1/app/stats";
static NSString* const SENAPIAppStatusUnreadPath = @"unread";

@implementation SENAPIAppStats

+ (void)stats:(nonnull SENAPIDataBlock)completion {
    [SENAPIClient GET:SENAPIAppStatusEndpoint parameters:nil completion:^(id data, NSError *error) {
        SENAppStats* stats = nil;
        if (!error) {
            stats = [[SENAppStats alloc] initWithDictionary:data];
        }
        completion (stats, error);
    }];
}

+ (void)updateStats:(nonnull SENAppStats*)stats completion:(nonnull SENAPIDataBlock)completion {
    NSDictionary* params = [stats dictionaryValue];
    [SENAPIClient PATCH:SENAPIAppStatusEndpoint parameters:params completion:completion];
}

+ (void)unread:(nonnull SENAPIDataBlock)completion {
    NSString* path = [SENAPIAppStatusEndpoint stringByAppendingPathComponent:SENAPIAppStatusUnreadPath];
    [SENAPIClient GET:path parameters:nil completion:^(id data, NSError *error) {
        SENAppUnreadStats* unreadStats = nil;
        if (!error) {
            unreadStats = [[SENAppUnreadStats alloc] initWithDictionary:data];
        }
        completion (unreadStats, error);
    }];
}

@end
