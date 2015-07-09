//
//  SENAPITimelineSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 6/23/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPITimeline.h>
#import <SenseKit/SENTimeline.h>

@interface SENAPITimeline()

+ (NSString*)timelinePathForDate:(NSDate*)date;

@end

SPEC_BEGIN(SENAPITimelineSpec)

describe(@"SENAPITimeline", ^{
    
    describe(@"timelinePathForDate:", ^{
        
        __block NSDate* date = nil;
        __block NSString* gregorianDatePath = nil;
        
        beforeEach(^{
            date = [NSDate date];
            
            NSCalendar* calendar =
                [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            
            NSCalendarUnit flags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
            NSDateComponents* components = [calendar components:flags fromDate:date];
            gregorianDatePath = [NSString stringWithFormat:@"%ld-%ld-%ld",
                                 (long)[components year],
                                 (long)[components month],
                                 (long)[components day]];
        });
        
        afterEach(^{
            gregorianDatePath = nil;
            date = nil;
        });
        
        context(@"buddhist calendar is set", ^{
    
            beforeEach(^{
                NSCalendar* buddhist = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierBuddhist];
                [NSCalendar stub:@selector(currentCalendar) andReturn:buddhist];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:buddhist];
            });
            
            afterEach(^{
                [NSCalendar clearStubs];
            });
            
            it(@"should return gregorian date in path", ^{
                NSString* path = [SENAPITimeline timelinePathForDate:date];
                NSArray* parts = [path pathComponents];
                [[[parts lastObject] should] equal:gregorianDatePath];
            });
            
        });
        
        context(@"japanese calendar is set", ^{
            
            beforeEach(^{
                NSCalendar* japanese = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
                [NSCalendar stub:@selector(currentCalendar) andReturn:japanese];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:japanese];
            });
            
            afterEach(^{
                [NSCalendar clearStubs];
            });
            
            it(@"should return gregorian date in path", ^{
                NSString* path = [SENAPITimeline timelinePathForDate:date];
                NSArray* parts = [path pathComponents];
                [[[parts lastObject] should] equal:gregorianDatePath];
            });
            
        });
        
    });
    
    describe(@"providing timeline feedback", ^{
        
        __block NSDictionary* requestParams = nil;
        __block BOOL callbackInvoked = NO;
        __block NSNumber* timestamp = nil;
        __block SENTimelineSegment* segment = nil;
        __block NSDate* nightOfSleep = nil;
        
        beforeEach(^{
            [[LSNocilla sharedInstance] start];
            
            NSDateFormatter* dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            nightOfSleep = [dateFormatter dateFromString:@"2011-06-13"];
            
            NSDateFormatter* segmentFormatter = [NSDateFormatter new];
            segmentFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
            segmentFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:-25200];
            
            timestamp = @([[segmentFormatter dateFromString:@"2011-06-13 22:03"] timeIntervalSince1970] * 1000);
            NSDictionary* sleepSegmentDict = @{@"timestamp" : timestamp,
                                               @"timezone_offset": @(-25200000),
                                               @"event_type":@"IN_BED",
                                               @"duration": @1};
            segment = [[SENTimelineSegment alloc] initWithDictionary:sleepSegmentDict];
            
        });
        
        afterEach(^{
            [[LSNocilla sharedInstance] stop];
        });
        
        describe(@"amendSleepEvent:withHour:andMinutes:completion", ^{
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PATCH:parameters:completion:) withBlock:^id(NSArray *params) {
                    requestParams = params[1];
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
            });
            
            afterEach(^{
                requestParams = nil;
            });
            
            context(@"sleep segment is passed as an argument", ^{
                
                beforeEach(^{
                    [SENAPITimeline amendSleepEvent:segment
                                     forDateOfSleep:nightOfSleep
                                           withHour:@1
                                         andMinutes:@22
                                         completion:^(id data, NSError *error) {
                                             callbackInvoked = YES;
                                         }];
                    
                });
                
                it(@"invokes the completion block", ^{
                    [[@(callbackInvoked) should] beYes];
                });
                
                it(@"sends the accurate time", ^{
                    [[requestParams[@"new_event_time"] should] equal:@"01:22"];
                });
                
            });
            
            context(@"sleep segment is not passed in", ^{
                
                it(@"invokes the completion block with an error", ^{
                    
                    __block NSError* apiError = nil;
                    [SENAPITimeline amendSleepEvent:nil
                                     forDateOfSleep:nightOfSleep
                                           withHour:@1
                                         andMinutes:@22
                                         completion:^(id data, NSError *error) {
                                             apiError = error;
                                         }];
                    
                    [[apiError shouldNot] beNil];
                });
                
            });
            
        });
        
        describe(@"verifySleepEvent:completion", ^{
            
            beforeEach(^{
                [SENAPIClient stub:@selector(PUT:parameters:completion:) withBlock:^id(NSArray *params) {
                    requestParams = params[1];
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
            });
            
            afterEach(^{
                requestParams = nil;
            });
            
            context(@"sleep segment is not passed in", ^{
                
                it(@"invokes the completion block with an error", ^{
                    
                    __block NSError* apiError = nil;
                    [SENAPITimeline verifySleepEvent:nil
                                      forDateOfSleep:nightOfSleep
                                          completion:^(id data, NSError *error) {
                                              apiError = error;
                                          }];
                    
                    [[apiError shouldNot] beNil];
                });
                
            });
            
            context(@"sleep segment is passed in", ^{
                
                beforeEach(^{
                    [SENAPITimeline verifySleepEvent:segment
                                      forDateOfSleep:nightOfSleep
                                          completion:^(id data, NSError *error) {
                                              callbackInvoked = YES;
                                          }];
                });
                
                it(@"invokes the completion block", ^{
                    [[@(callbackInvoked) should] beYes];
                });
                
            });
            
        });
        
        describe(@"removeSleepEvent:completion", ^{
            
            beforeEach(^{
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    requestParams = params[1];
                    SENAPIDataBlock block = [params lastObject];
                    block(nil, nil);
                    return nil;
                }];
            });
            
            afterEach(^{
                requestParams = nil;
            });
            
            context(@"sleep segment is not passed in", ^{
                
                it(@"invokes the completion block with an error", ^{
                    
                    __block NSError* apiError = nil;
                    [SENAPITimeline removeSleepEvent:nil
                                      forDateOfSleep:nightOfSleep
                                          completion:^(id data, NSError *error) {
                                              apiError = error;
                                          }];
                    
                    [[apiError shouldNot] beNil];
                });
                
            });
            
            context(@"sleep segment is passed in", ^{
                
                beforeEach(^{
                    [SENAPITimeline removeSleepEvent:segment
                                      forDateOfSleep:nightOfSleep
                                          completion:^(id data, NSError *error) {
                                              callbackInvoked = YES;
                                          }];
                });
                
                it(@"invokes the completion block", ^{
                    [[@(callbackInvoked) should] beYes];
                });
                
            });
            
        });
        
    });
    
});

SPEC_END
