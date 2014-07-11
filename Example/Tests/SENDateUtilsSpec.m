
#import <Kiwi/Kiwi.h>
#import "SENDateUtils.h"


SPEC_BEGIN(SENDateUtilsSpec)

describe(@"SENDateUtils", ^{

    describe(@"SEN_dataForDate()", ^{
        
        __block struct SENDateBytes dateBytes;
        __block NSDateComponents* dateComponents;
        
        beforeEach(^{
            dateComponents = [[NSDateComponents alloc] init];
            dateComponents.year = 2007;
            dateComponents.month = 11;
            dateComponents.day = 22;
            dateComponents.hour = 9;
            dateComponents.minute = 0;
            dateComponents.second = 43;
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            NSDate* date = [calendar dateFromComponents:dateComponents];
            NSData* data = SEN_dataForDate(date);
            [data getBytes:&dateBytes length:sizeof(struct SENDateBytes)];
        });
        
        it(@"sets the year", ^{
            [[@(dateBytes.year) should] equal:@(dateComponents.year)];
        });
        
        it(@"sets the month", ^{
            [[@(dateBytes.month) should] equal:@(dateComponents.month)];
        });
        
        it(@"sets the day", ^{
            [[@(dateBytes.day) should] equal:@(dateComponents.day)];
        });
        
        it(@"sets the hour", ^{
            [[@(dateBytes.hour) should] equal:@(dateComponents.hour)];
        });
        
        it(@"sets the minute", ^{
            [[@(dateBytes.minute) should] equal:@(dateComponents.minute)];
        });
        
        it(@"sets the second", ^{
            [[@(dateBytes.second) should] equal:@(dateComponents.second)];
        });
    });
    
    describe(@"SEN_dateFromData()", ^{
        
        __block struct SENDateBytes dateBytes;
        __block NSDateComponents* dateComponents;
        
        beforeEach(^{
            dateBytes.year = 2012;
            dateBytes.month = 4;
            dateBytes.day = 1;
            dateBytes.hour = 11;
            dateBytes.minute = 35;
            dateBytes.second = 8;
            NSDate* date = SEN_dateForData([NSData dataWithBytes:&dateBytes length:sizeof(struct SENDateBytes)]);
            NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
            dateComponents = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit)fromDate:date];
        });
        
        it(@"sets the year", ^{
            [[@(dateComponents.year) should] equal:@(dateBytes.year)];
        });
        
        it(@"sets the month", ^{
            [[@(dateComponents.month) should] equal:@(dateBytes.month)];
        });
        
        it(@"sets the day", ^{
            [[@(dateComponents.day) should] equal:@(dateBytes.day)];
        });
        
        it(@"sets the hour", ^{
            [[@(dateComponents.hour) should] equal:@(dateBytes.hour)];
        });
        
        it(@"sets the minute", ^{
            [[@(dateComponents.minute) should] equal:@(dateBytes.minute)];
        });
        
        it(@"sets the second", ^{
            [[@(dateComponents.second) should] equal:@(dateBytes.second)];
        });
    });
});

SPEC_END
