
#import <Kiwi/Kiwi.h>
#import <SenseKit/SENAlarm.h>
#import <SenseKit/SENKeyedArchiver.h>
#import <YapDatabase/YapDatabase.h>

@interface SENKeyedArchiver ()
+ (YapDatabaseConnection*)mainConnection;
@end

SPEC_BEGIN(SENAlarmSpec)

describe(@"SENAlarm", ^{
    __block SENAlarm* alarm;

    beforeEach(^{
        NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSUUID UUID] UUIDString]];
        YapDatabase* database = [[YapDatabase alloc] initWithPath:path];
        id connection = [database newConnection];
        [SENKeyedArchiver stub:@selector(mainConnection) andReturn:connection];
    });

    afterEach(^{
        alarm = nil;
        [SENAlarm clearSavedAlarms];
    });

    describe(@"+createDefaultAlarm", ^{

        it(@"creates a valid alarm", ^{
            [[[SENAlarm createDefaultAlarm] should] beKindOfClass:[SENAlarm class]];
        });
    });

    describe(@"-initWithDictionary:", ^{
        
        NSDictionary* alarmValues = @{
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

        it(@"sets the repeat days", ^{
            [[@([alarm repeatFlags]) should] equal:@(SENAlarmRepeatMonday | SENAlarmRepeatFriday | SENAlarmRepeatSaturday)];
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
    
    describe(@"- incrementAlarmTimeByMinutes:", ^{
        
        __block SENAlarm* alarm;
        
        beforeEach(^{
            alarm = [[SENAlarm alloc] initWithDictionary:@{@"hour": @2, @"minute": @0}];
        });
       
        context(@"minutes do not roll over to a different hour", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:40];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@40];
            });
        });
        
        context(@"minutes roll over to a differen hour", ^{
           
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:130];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@10];
            });
            
            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@4];
            });
        });
        
        context(@"minutes and hours roll forward to a different day", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:1430];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@50];
            });

            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@1];
            });
        });
        
        context(@"minutes and hours roll backward to a different day", ^{
            
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:-130];
            });
            
            it(@"updates the number of minutes", ^{
                [[@([alarm minute]) should] equal:@50];
            });
            
            it(@"updates the number of hours", ^{
                [[@([alarm hour]) should] equal:@23];
            });
        });
        
        context(@"minutes roll backwards less than an hour", ^{
           
            beforeEach(^{
                [alarm incrementAlarmTimeByMinutes:-20];
            });
            
            it(@"updates the minutes", ^{
                [[@([alarm minute]) should] equal:@40];
            });
            
            it(@"updates the hour", ^{
                [[@([alarm hour]) should] equal:@1];
            });
        });
    });

    describe(@"- isSaved", ^{
        __block SENAlarm* alarm;

        beforeEach(^{
            alarm = [[SENAlarm alloc] init];
        });

        context(@"an alarm is unsaved", ^{

            it(@"is false", ^{
                [[@([alarm isSaved]) should] beNo];
            });
        });

        context(@"an alarm is saved", ^{

            beforeEach(^{
                [alarm save];
            });

            it(@"is true", ^{
                [[@([alarm isSaved]) should] beYes];
            });

            context(@"an alarm is deleted", ^{

                beforeEach(^{
                    [alarm delete];
                });

                it(@"is false", ^{
                    [[@([alarm isSaved]) should] beNo];
                });
            });
        });
    });

    describe(@"+ savedAlarms", ^{

        it(@"is initially empty", ^{
            [[[SENAlarm savedAlarms] should] haveCountOf:0];
        });

        context(@"an alarm is saved", ^{

            __block SENAlarm* alarm;

            beforeEach(^{
                alarm = [[SENAlarm alloc] init];
                [alarm save];
            });

            it(@"returns the saved alarm", ^{
                [[[[SENAlarm savedAlarms] firstObject] should] equal:alarm];
            });

            context(@"an alarm is saved again", ^{

                beforeEach(^{
                    [alarm save];
                });

                it(@"does not save duplicate alarms", ^{
                    [[[SENAlarm savedAlarms] should] haveCountOf:1];
                });
            });

            context(@"a different alarm is saved", ^{

                __block SENAlarm* otherAlarm;

                beforeEach(^{
                    otherAlarm = [[SENAlarm alloc] init];
                    [otherAlarm save];
                });

                it(@"saves separate alarms", ^{
                    [[[SENAlarm savedAlarms] should] haveCountOf:2];
                    [[[SENAlarm savedAlarms] should] containObjects:otherAlarm, alarm, nil];
                });
            });

            context(@"an alarm is deleted", ^{

                beforeEach(^{
                    [alarm delete];
                });

                it(@"removes the alarm from the store", ^{
                    [[[SENAlarm savedAlarms] should] haveCountOf:0];
                });
            });
        });
    });
});

SPEC_END
