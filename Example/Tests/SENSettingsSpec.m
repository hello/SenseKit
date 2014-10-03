#import <Kiwi/Kiwi.h>
#import "SENSettings.h"

SPEC_BEGIN(SENSettingsSpec)

describe(@"SENSettings", ^{
    
    describe(@"+defaults", ^{
        
        it(@"should return values managed", ^{
            
            NSDictionary* dictionary = [SENSettings defaults];
            [[@([dictionary count]) should] equal:@(2)];
            [[[dictionary objectForKey:@"SENSettingsTimeFormat"] should] beNonNil];
            [[[dictionary objectForKey:@"SENSettingsTemperatureFormat"] should] beNonNil];
            
        });
        
    });
    
});

SPEC_END