
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAuthorizationService.h>

SPEC_BEGIN(SENAuthorizationServiceSpec)

describe(@"SENAuthorizationService", ^{

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    beforeEach(^{
        stubRequest(@"DELETE", @"https://dev-api.hello.is/v1/oauth2/token");
        [SENAuthorizationService deauthorize];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"+ emailAddressOfAuthorizedUser", ^{

        NSString* emailAddress = @"someguy@example.com";

        it(@"returns nil", ^{
            [[[SENAuthorizationService emailAddressOfAuthorizedUser] should] beNil];
        });

        context(@"a user successfully authenticates", ^{

            beforeEach(^{
                stubRequest(@"POST", @"https://dev-api.hello.is/v1/oauth2/token");
                [SENAuthorizationService authorizeWithUsername:emailAddress password:@"pass" callback:NULL];
            });

            it(@"returns the authenticating username", ^{
                [[expectFutureValue([SENAuthorizationService emailAddressOfAuthorizedUser]) shouldSoon] equal:emailAddress];
            });

            context(@"a user signs out", ^{

                beforeEach(^{
                    [SENAuthorizationService deauthorize];
                });

                it(@"returns nil", ^{
                    [[[SENAuthorizationService emailAddressOfAuthorizedUser] should] beNil];
                });
            });
        });

        context(@"a user fails to authenticate", ^{

            beforeEach(^{
                stubRequest(@"POST", @"https://dev-api.hello.is/v1/oauth2/token").andFailWithError([NSError errorWithDomain:@"hello.is" code:401 userInfo:nil]);
                [SENAuthorizationService authorizeWithUsername:emailAddress password:@"pass" callback:NULL];
            });

            it(@"returns nil", ^{
                [[[SENAuthorizationService emailAddressOfAuthorizedUser] should] beNil];
            });
        });
    });
});

SPEC_END
