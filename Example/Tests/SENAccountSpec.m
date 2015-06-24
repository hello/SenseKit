//
//  SENAccountSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 6/23/15.
//  Copyright (c) 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAccount.h>

SPEC_BEGIN(SENAccountSpec)

describe(@"SENAccount", ^{
    
    __block NSCalendar* gregorian = nil;
    
    beforeAll(^{
        gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    });
    
    describe(@"+setBirthMonth:day:andYear:", ^{
        
        __block long year = 0;
        __block long month = 0;
        __block long day = 0;
        __block NSString* isoDate = nil;
        __block SENAccount* account = nil;
        __block NSDate* date = nil;
        
        beforeAll(^{
            year = 2015;
            month = 6;
            day = 23;
            isoDate = [NSString stringWithFormat:@"%ld-0%ld-%ld", year, month, day];
            account = [[SENAccount alloc] init];
            
            NSDateComponents* components = [[NSDateComponents alloc] init];
            [components setYear:year];
            [components setDay:day];
            [components setMonth:month];
            
            date = [gregorian dateFromComponents:components];
        });
        
        context(@"buddhist calendar is set", ^{
            
            __block NSCalendar* buddhist = nil;
            
            beforeAll(^{
                buddhist = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierBuddhist];
                [NSCalendar stub:@selector(currentCalendar) andReturn:buddhist];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:buddhist];
            });
            
            afterAll(^{
                [NSCalendar clearStubs];
            });
            
            it(@"should properly convert birthdate from buddhist to gregorian", ^{
                NSDateComponents* buddhistComponents = [buddhist components:NSCalendarUnitDay
                                                                            |NSCalendarUnitMonth
                                                                            |NSCalendarUnitYear
                                                                   fromDate:date];
                
                [account setBirthMonth:[buddhistComponents month]
                                   day:[buddhistComponents day]
                               andYear:[buddhistComponents year]];
                
                [[[account birthdate] should] equal:isoDate];
            });
            
        });
        
        context(@"japanese calendar is set", ^{
            
            __block NSCalendar* japanese = nil;
            
            beforeAll(^{
                japanese = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierJapanese];
                [NSCalendar stub:@selector(currentCalendar) andReturn:japanese];
                [NSCalendar stub:@selector(autoupdatingCurrentCalendar) andReturn:japanese];
            });
            
            afterAll(^{
                [NSCalendar clearStubs];
            });
            
            it(@"should properly convert birthdate from japanese to gregorian", ^{
                NSDateComponents* japaneseComponents = [japanese components:NSCalendarUnitDay
                                                                            |NSCalendarUnitMonth
                                                                            |NSCalendarUnitYear
                                                                   fromDate:date];
                
                [account setBirthMonth:[japaneseComponents month]
                                   day:[japaneseComponents day]
                               andYear:[japaneseComponents year]];
                
                [[[account birthdate] should] equal:isoDate];
            });
            
        });
        
    });
    
});

SPEC_END
