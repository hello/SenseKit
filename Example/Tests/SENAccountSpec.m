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

    describe(@"-initWithDictionary:", ^{

        it(@"sets accountId", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"id":@"399-90-11123"}];
            [[[account accountId] should] equal:@"399-90-11123"];
        });

        it(@"sets lastModified", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"last_modified":@303444}];
            [[[account lastModified] should] equal:@303444];
        });

        it(@"sets email", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"email":@"v@example.com"}];
            [[[account email] should] equal:@"v@example.com"];
        });

        it(@"sets weight", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"weight":@51}];
            [[[account weight] should] equal:@51];
        });

        it(@"sets height", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"height":@154}];
            [[[account height] should] equal:@154];
        });

        it(@"sets latitude", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"lat":@(-42.22)}];
            [[[account latitude] should] equal:@(-42.22)];
        });

        it(@"sets longitude", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"long":@(84.50993)}];
            [[[account longitude] should] equal:@(84.50993)];
        });

        it(@"sets birthdate", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"dob":@"1982-03-17"}];
            [[[account birthdate] should] equal:@"1982-03-17"];
        });

        it(@"sets createdAt", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"created":@1439225747000}];
            [[@([[account createdAt] timeIntervalSince1970]) should] equal:@1439225747];
        });

        it(@"ignores unknown values", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"created":@1439225747000, @"color":@"blue"}];
            [[@([[account createdAt] timeIntervalSince1970]) should] equal:@1439225747];
        });

        it(@"ignores non-dictionary values", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:(id)@300];
            [[account should] beNil];
        });

        context(@"gender is female", ^{

            it(@"sets female gender", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"FEMALE"}];
                [[@([account gender]) should] equal:@(SENAccountGenderFemale)];
            });
        });

        context(@"gender is male", ^{

            it(@"sets male gender", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"MALE"}];
                [[@([account gender]) should] equal:@(SENAccountGenderMale)];
            });
        });

        context(@"gender is other", ^{

            it(@"sets female gender", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"OTHER"}];
                [[@([account gender]) should] equal:@(SENAccountGenderOther)];
            });
        });

        context(@"gender is unknown", ^{

            it(@"sets other gender", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"mayonnaise"}];
                [[@([account gender]) should] equal:@(SENAccountGenderOther)];
            });
        });

        context(@"gender is unspecified", ^{

            it(@"sets other gender", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{}];
                [[@([account gender]) should] equal:@(SENAccountGenderOther)];
            });
        });
    });

    describe(@"-dictionaryValue", ^{

        it(@"does not set account ID", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"id":@399}];
            [[[account dictionaryValue][@"id"] should] beNil];
        });

        it(@"does not populate missing values", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"weight":@399}];
            [[[account dictionaryValue][@"name"] should] beNil];
        });

        it(@"sets email", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"email":@"betty@example.com"}];
            [[[account dictionaryValue][@"email"] should] equal:@"betty@example.com"];
        });

        it(@"sets weight", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"weight":@59}];
            [[[account dictionaryValue][@"weight"] should] equal:@59];
        });

        it(@"sets height", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"height":@180}];
            [[[account dictionaryValue][@"height"] should] equal:@180];
        });

        it(@"sets birthdate", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"dob":@"1978-01-23"}];
            [[[account dictionaryValue][@"dob"] should] equal:@"1978-01-23"];
        });

        it(@"sets last modified", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"last_modified":@1439225747}];
            [[[account dictionaryValue][@"last_modified"] should] equal:@1439225747];
        });

        it(@"sets created at", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"created":@1439225747000}];
            [[[account dictionaryValue][@"created"] should] equal:@1439225747000];
        });

        it(@"sets latitude", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"lat":@143}];
            [[[account dictionaryValue][@"lat"] should] equal:@143];
        });

        it(@"sets longitude", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"long":@344}];
            [[[account dictionaryValue][@"long"] should] equal:@344];
        });
        
        it(@"sets first name", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"firstname":@"Jimmy"}];
            [[[account dictionaryValue][@"firstname"] should] equal:@"Jimmy"];
        });
        
        it(@"sets last name", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"lastname":@"Lu"}];
            [[[account dictionaryValue][@"lastname"] should] equal:@"Lu"];
        });
        
        it(@"sets time zone", ^{
            SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"time_zone":@"America/Los_Angeles"}];
            [[[account dictionaryValue][@"time_zone"] should] equal:@"America/Los_Angeles"];
        });

        context(@"gender is male", ^{

            it(@"sets gender property to MALE", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"MALE"}];
                [[[account dictionaryValue][@"gender"] should] equal:@"MALE"];
            });
        });

        context(@"gender is female", ^{

            it(@"sets gender property to FEMALE", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"FEMALE"}];
                [[[account dictionaryValue][@"gender"] should] equal:@"FEMALE"];
            });
        });

        context(@"gender is other", ^{

            it(@"sets gender property to OTHER", ^{
                SENAccount* account = [[SENAccount alloc] initWithDictionary:@{@"gender":@"OTHER"}];
                [[[account dictionaryValue][@"gender"] should] equal:@"OTHER"];
            });
        });
        
    });
    
    describe(@"-setBirthMonth:day:andYear:", ^{
        
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
