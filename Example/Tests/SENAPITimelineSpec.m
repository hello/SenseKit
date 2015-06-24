//
//  SENAPITimelineSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 6/23/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAPITimeline.h>

@interface SENAPITimeline()

+ (NSString*)timelinePathForDate:(NSDate*)date;

@end

SPEC_BEGIN(SENAPITimelineSpec)

describe(@"SENAPITimeline", ^{
    
    describe(@"timelinePathForDate:", ^{
        
        __block NSDate* date = nil;
        __block NSString* gregorianDatePath = nil;
        
        beforeAll(^{
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
        
        context(@"buddhist calendar is set", ^{
    
            beforeAll(^{
                NSCalendar* buddhist = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierBuddhist];
                [NSCalendar stub:@selector(currentCalendar) andReturn:buddhist];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:buddhist];
            });
            
            it(@"should return gregorian date in path", ^{
                NSString* path = [SENAPITimeline timelinePathForDate:date];
                NSArray* parts = [path pathComponents];
                [[[parts lastObject] should] equal:gregorianDatePath];
            });
            
        });
        
        context(@"japanese calendar is set", ^{
            
            beforeAll(^{
                NSCalendar* buddhist = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
                [NSCalendar stub:@selector(currentCalendar) andReturn:buddhist];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:buddhist];
            });
            
            it(@"should return gregorian date in path", ^{
                NSString* path = [SENAPITimeline timelinePathForDate:date];
                NSArray* parts = [path pathComponents];
                [[[parts lastObject] should] equal:gregorianDatePath];
            });
            
        });
        
    });
    
});

SPEC_END
