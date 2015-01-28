
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

    describe(@"+updateSavedAlarmsWithData:", ^{

        context(@"saved alarms exist", ^{

            beforeEach(^{
                [[[SENAlarm alloc] initWithDictionary:@{@"hour":@6,@"minute":@30}] save];
            });

            it(@"deletes existing alarms", ^{
                [SENAlarm updateSavedAlarmsWithData:nil];
                [[[SENAlarm savedAlarms] should] beEmpty];
            });

            it(@"creates saves from data", ^{
                NSArray* alarms = @[@{@"hour":@18,@"minute":@30},@{@"hour":@7,@"minute":@45}];
                [SENAlarm updateSavedAlarmsWithData:alarms];
                [[[SENAlarm savedAlarms] should] haveCountOf:2];
            });

            it(@"returns saved alarms", ^{
                NSArray* alarmData = @[@{@"hour":@18,@"minute":@30},@{@"hour":@7,@"minute":@45}];
                NSArray* alarms = [SENAlarm updateSavedAlarmsWithData:alarmData];
                [[alarms should] haveCountOf:2];
            });
        });

        context(@"no saved alarms exist", ^{

            it(@"creates alarms from data", ^{
                NSArray* alarmData = @[@{@"hour":@22,@"minute":@0},@{@"hour":@8,@"minute":@30}];
                [SENAlarm updateSavedAlarmsWithData:alarmData];
                [[[SENAlarm savedAlarms] should] haveCountOf:2];
            });

            it(@"returns saved alarms", ^{
                NSArray* alarmData = @[@{@"hour":@22,@"minute":@0},
                                       @{@"hour":@8,@"minute":@30},
                                       @{@"hour":@7,@"minute":@45}];
                NSArray* alarms = [SENAlarm updateSavedAlarmsWithData:alarmData];
                [[alarms should] haveCountOf:3];
            });
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
