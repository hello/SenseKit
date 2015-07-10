
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIClient.h>

SPEC_BEGIN(SENAPINotificationSpec)

describe(@"SENAPINotification", ^{

    __block NSDictionary* requestParams;

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    beforeEach(^{
        [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
            requestParams = params[1];
            SENAPIDataBlock block = [params lastObject];
            block(nil, nil);
            return nil;
        }];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
        requestParams = nil;
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"registerForRemoteNotificationsWithTokenData:completion:", ^{

        it(@"invokes the completion block", ^{
            __block BOOL callbackInvoked = NO;
            NSData* data = [@"<2342324>" dataUsingEncoding:NSUTF8StringEncoding];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:data completion:^(NSError *error) {
                callbackInvoked = YES;
            }];
            [[@(callbackInvoked) should] beYes];
        });

        it(@"includes the OS in the request", ^{
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[[requestParams allKeys] should] contain:@"os"];
        });

        it(@"includes the OS version in the request", ^{
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[[requestParams allKeys] should] contain:@"version"];
        });

        it(@"includes the app version in the request", ^{
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[[requestParams allKeys] should] contain:@"app_version"];
        });

        it(@"includes the token in the request", ^{
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[[requestParams allKeys] should] contain:@"token"];
        });
    });
});

SPEC_END
