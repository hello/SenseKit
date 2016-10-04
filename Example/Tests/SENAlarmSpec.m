
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENKeyedArchiver.h>

SPEC_BEGIN(SENAlarmSpec)

describe(@"SENAlarm", ^{
    __block SENAlarm* alarm;

    beforeEach(^{
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        [SENKeyedArchiver stub:@selector(datastorePath) andReturn:path];
    });

    afterEach(^{
        alarm = nil;
    });

    describe(@"+createDefaultAlarm", ^{

        it(@"creates a valid alarm", ^{
            [[[SENAlarm createDefaultAlarm] should] beKindOfClass:[SENAlarm class]];
        });
    });

    describe(@"-initWithDictionary:", ^{
        
        NSDictionary* alarmValues = @{@"id":@"abcdef-123456",
                                      @"enabled": @YES, @"hour":@22, @"minute":@15,
                                      @"sound":@{@"name":@"Bells",@"id":@78},
                                      @"editable": @YES, @"smart":@YES, @"day_of_week":@[@1,@5,@6]};
        
        beforeEach(^{
            alarm = [[SENAlarm alloc] initWithDictionary:alarmValues];
        });
        
        it(@"sets the activation state", ^{
            [[@([alarm isOn]) should] beTrue];
        });
        
        it(@"sets the hour", ^{
            [[@([alarm hour]) should] equal:alarmValues[@"hour"]];
        });
        
        it(@"sets the minute", ^{
            [[@([alarm minute]) should] equal:alarmValues[@"minute"]];
        });
        
        it(@"sets the sound name", ^{
            [[[alarm soundName] should] equal:alarmValues[@"sound"][@"name"]];
        });

        it(@"sets the sound ID", ^{
            [[[alarm soundID] should] equal:alarmValues[@"sound"][@"id"]];
        });

        it(@"sets the editable state", ^{
            [[@([alarm isEditable]) should] beYes];
        });

        it(@"sets the smart alarm state", ^{
            [[@([alarm isSmartAlarm]) should] beYes];
        });

        it(@"sets the identifier", ^{
            [[alarm.identifier should] equal:alarmValues[@"id"]];
        });

        it(@"sets the repeat days", ^{
            [[@([alarm repeatFlags]) should] equal:@(SENAlarmRepeatMonday | SENAlarmRepeatFriday | SENAlarmRepeatSaturday)];
        });

        it(@"is equal to an alarm with the same properties", ^{
            SENAlarm* other = [[SENAlarm alloc] initWithDictionary:alarmValues];
            [[alarm should] equal:other];
            [[@(alarm.hash) should] equal:@(other.hash)];
        });

        it(@"is not equal to an alarm with different properties", ^{
            NSMutableDictionary* properties = [alarmValues mutableCopy];
            properties[@"enabled"] = @NO;
            SENAlarm* other = [[SENAlarm alloc] initWithDictionary:properties];
            [[alarm shouldNot] equal:other];
        });
    });

    describe(@"- isRepeated", ^{

        beforeEach(^{
            alarm = [[SENAlarm alloc] init];
        });

        context(@"the alarm has repeat days set", ^{
            beforeEach(^{
                alarm.repeatFlags = (SENAlarmRepeatFriday | SENAlarmRepeatMonday);
            });

            it(@"is true", ^{
                [[@([alarm isRepeated]) should] beYes];
            });
        });

        context(@"the alarm is not repeating", ^{
            beforeEach(^{
                alarm.repeatFlags = 0;
            });

            it(@"is false", ^{
                [[@([alarm isRepeated]) should] beNo];
            });
        });
    });

    describe(@"- isRepeatedOn:", ^{

        beforeEach(^{
            alarm = [[SENAlarm alloc] init];
        });

        context(@"the alarm has repeat days set", ^{

            beforeEach(^{
                alarm.repeatFlags = (SENAlarmRepeatFriday | SENAlarmRepeatMonday);
            });

            context(@"the selected days match all of the repeat days", ^{

                it(@"is true", ^{
                    [[@([alarm isRepeatedOn:(SENAlarmRepeatFriday | SENAlarmRepeatMonday)]) should] beYes];
                });
            });

            context(@"the selected days match one of the repeat days", ^{

                it(@"is true", ^{
                    [[@([alarm isRepeatedOn:SENAlarmRepeatFriday]) should] beYes];
                });
            });

            context(@"the selected days match none of the repeat days", ^{

                it(@"is false", ^{
                    [[@([alarm isRepeatedOn:SENAlarmRepeatWednesday]) should] beNo];
                });
            });
        });

        context(@"the alarm is not repeating", ^{
            beforeEach(^{
                alarm.repeatFlags = 0;
            });

            it(@"is false", ^{
                [[@([alarm isRepeated]) should] beNo];
            });
        });
    });

    describe(@"- repeatFlags", ^{

        beforeEach(^{
            alarm = [[SENAlarm alloc] init];
        });

        context(@"a single day will be repeated", ^{

            beforeEach(^{
                alarm.repeatFlags = SENAlarmRepeatThursday;
            });

            it(@"accepts a single day", ^{
                [[@(alarm.repeatFlags & SENAlarmRepeatThursday) should] equal:@(SENAlarmRepeatThursday)];
            });

            it(@"does not include excluded days", ^{
                [[@(alarm.repeatFlags & SENAlarmRepeatSunday) shouldNot] equal:@(SENAlarmRepeatSunday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatMonday) shouldNot] equal:@(SENAlarmRepeatMonday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatTuesday) shouldNot] equal:@(SENAlarmRepeatTuesday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatWednesday) shouldNot] equal:@(SENAlarmRepeatWednesday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatFriday) shouldNot] equal:@(SENAlarmRepeatFriday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatSaturday) shouldNot] equal:@(SENAlarmRepeatSaturday)];
            });
        });

        context(@"multiple days will be repeated", ^{

            beforeEach(^{
                alarm.repeatFlags = (SENAlarmRepeatFriday | SENAlarmRepeatSaturday | SENAlarmRepeatWednesday);
            });

            it(@"does not include excluded days", ^{
                [[@(alarm.repeatFlags & SENAlarmRepeatSunday) shouldNot] equal:@(SENAlarmRepeatSunday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatMonday) shouldNot] equal:@(SENAlarmRepeatMonday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatTuesday) shouldNot] equal:@(SENAlarmRepeatTuesday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatThursday) shouldNot] equal:@(SENAlarmRepeatThursday)];
            });

            it(@"includes included days", ^{
                [[@(alarm.repeatFlags & SENAlarmRepeatWednesday) should] equal:@(SENAlarmRepeatWednesday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatFriday) should] equal:@(SENAlarmRepeatFriday)];
                [[@(alarm.repeatFlags & SENAlarmRepeatSaturday) should] equal:@(SENAlarmRepeatSaturday)];
            });
        });
    });
    
    describe(@"-dictionaryValue:", ^{
        
        context(@"called during a day that requires DST change, but before DST is actually triggered", ^{
            
            __block SENAlarm* alarm = nil;
            __block NSDictionary* dict = nil;
            
            beforeEach(^{
                // 1457861592.089f points to March 13th, 2016 at 1:33 AM
                NSDate* dstChange = [NSDate dateWithTimeIntervalSince1970:1457861592.089f];
                [NSDate stub:@selector(date) andReturn:dstChange];
                
                alarm = [SENAlarm new];
                [alarm setMinute:30];
                [alarm setHour:7];
                [alarm setOn:YES];
                [alarm setSoundID:@"1"];
                [alarm setSoundName:@"test"];
                [alarm setSmartAlarm:NO];
                
                dict = [alarm dictionaryValue];
            });
            
            afterEach(^{
                [NSDate clearStubs];
                alarm = nil;
                dict = nil;
            });
            
            it(@"should not change hour of dict", ^{
                [[dict[@"hour"] should] equal:@([alarm hour])];
            });
            
            it(@"should not change minute of dict", ^{
                [[dict[@"minute"] should] equal:@([alarm minute])];
            });
            
        });
        
        context(@"called after the set hour and minute", ^{
            
            __block SENAlarm* alarm = nil;
            __block NSDictionary* dict = nil;
            
            beforeEach(^{
                // 1457861592.089f points to March 13th, 2016 at 1:33 AM
                NSDate* dstChange = [NSDate dateWithTimeIntervalSince1970:1457861592.089f];
                [NSDate stub:@selector(date) andReturn:dstChange];
                
                alarm = [SENAlarm new];
                [alarm setMinute:10];
                [alarm setHour:1];
                [alarm setOn:YES];
                [alarm setSoundID:@"1"];
                [alarm setSoundName:@"test"];
                [alarm setSmartAlarm:NO];
                
                dict = [alarm dictionaryValue];
            });
            
            afterEach(^{
                [NSDate clearStubs];
                alarm = nil;
                dict = nil;
            });
            
            it(@"should change the day to be the 14th", ^{
                [[dict[@"day_of_month"] should] equal:@(14)];
            });
            
            it(@"should not change hour of dict", ^{
                [[dict[@"hour"] should] equal:@([alarm hour])];
            });
            
            it(@"should not change minute of dict", ^{
                [[dict[@"minute"] should] equal:@([alarm minute])];
            });
            
        });
        
    });


});

SPEC_END
