
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPINotification.h>
#import <SenseKit/SENAPIClient.h>

SPEC_BEGIN(SENAPINotificationSpec)

describe(@"SENAPINotification", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"registerForRemoteNotificationsWithTokenData:completion:", ^{

        it(@"sends a POST request", ^{
            [[SENAPIClient should] receive:@selector(POST:parameters:completion:)];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
        });

        it(@"invokes the completion block", ^{
            __block BOOL callbackInvoked = NO;
            stubRequest(@"POST", @".*".regex).andReturn(200).withBody(@"{}").withHeader(@"Content-Type", @"application/json");
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:^(NSError *error) {
                callbackInvoked = YES;
            }];
            [[expectFutureValue(@(callbackInvoked)) shouldEventuallyBeforeTimingOutAfter(0.5)] beYes];
        });

        it(@"includes the OS in the request", ^{
            __block NSDictionary* requestParams;
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                requestParams = params[1];
                return nil;
            }];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[expectFutureValue([requestParams allKeys]) shouldEventuallyBeforeTimingOutAfter(0.5)] contain:@"os"];
        });

        it(@"includes the OS version in the request", ^{
            __block NSDictionary* requestParams;
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                requestParams = params[1];
                return nil;
            }];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[expectFutureValue([requestParams allKeys]) shouldEventuallyBeforeTimingOutAfter(0.5)] contain:@"version"];
        });

        it(@"includes the app version in the request", ^{
            __block NSDictionary* requestParams;
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                requestParams = params[1];
                return nil;
            }];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[expectFutureValue([requestParams allKeys]) shouldEventuallyBeforeTimingOutAfter(0.5)] contain:@"app_version"];
        });

        it(@"includes the token in the request", ^{
            __block NSDictionary* requestParams;
            [SENAPIClient stub:@selector(POST:parameters:completion:) withBlock:^id(NSArray *params) {
                requestParams = params[1];
                return nil;
            }];
            [SENAPINotification registerForRemoteNotificationsWithTokenData:[NSData data] completion:NULL];
            [[expectFutureValue([requestParams allKeys]) shouldEventuallyBeforeTimingOutAfter(0.5)] contain:@"token"];
        });
    });
});

SPEC_END
