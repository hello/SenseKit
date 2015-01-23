
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/API.h>
#import <AFNetworking/AFURLSessionManager.h>

@interface SENAuthorizationService()

+ (void)authorize:(NSString*)username
         password:(NSString*)password
     onCompletion:(void(^)(NSDictionary* response, NSError* error))block;

@end

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

    describe(@"+ isAuthorizationError:", ^{

        __block NSError* error;

        context(@"error is not related to HTTP requests", ^{

            beforeEach(^{
                error = [NSError errorWithDomain:@"is.hello" code:-1 userInfo:nil];
            });

            it(@"returns no", ^{
                [[@([SENAuthorizationService isAuthorizationError:error]) should] beNo];
            });
        });

        context(@"error is from a HTTP request", ^{

            context(@"error is not from authorization", ^{

                beforeEach(^{
                    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                              statusCode:404
                                                                             HTTPVersion:@"HTTP/1.1"
                                                                            headerFields:@{}];
                    error = [NSError errorWithDomain:@"is.hello" code:-1 userInfo:@{AFNetworkingOperationFailingURLResponseErrorKey:response}];
                });

                it(@"returns no", ^{
                    [[@([SENAuthorizationService isAuthorizationError:error]) should] beNo];
                });
            });

            context(@"error is from authorization", ^{
                beforeEach(^{
                    NSHTTPURLResponse* response = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]
                                                                              statusCode:401
                                                                             HTTPVersion:@"HTTP/1.1"
                                                                            headerFields:@{}];
                    error = [NSError errorWithDomain:@"is.hello" code:-1 userInfo:@{AFNetworkingOperationFailingURLResponseErrorKey:response}];
                });

                it(@"returns yes", ^{
                    [[@([SENAuthorizationService isAuthorizationError:error]) should] beYes];
                });
            });
        });
    });

    describe(@"+ isAuthorizedRequest:", ^{

        __block NSMutableURLRequest* request;

        beforeEach(^{
            request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://example.com"]];
        });

        context(@"request has an authorization header", ^{

            beforeEach(^{
                [request setValue:@"abc" forHTTPHeaderField:@"Authorization"];
            });

            it(@"returns yes", ^{
                [[@([SENAuthorizationService isAuthorizedRequest:request]) should] beYes];
            });
        });

        context(@"request does not have an authorization header", ^{

            beforeEach(^{
                [request setValue:nil forHTTPHeaderField:@"Authorization"];
            });

            it(@"returns no", ^{
                [[@([SENAuthorizationService isAuthorizedRequest:request]) should] beNo];
            });
        });
    });

    describe(@"+ emailAddressOfAuthorizedUser", ^{

        NSString* emailAddress = @"someguy@example.com";

        it(@"returns nil", ^{
            [[[SENAuthorizationService emailAddressOfAuthorizedUser] should] beNil];
        });

        context(@"a user successfully authenticates", ^{

            beforeEach(^{
                stubRequest(@"POST", @"https://dev-api.hello.is/v1/oauth2/token");
                [SENAuthorizationService stub:@selector(authorize:password:onCompletion:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSDictionary* response, NSError* error) = [params lastObject];
                    if (callback) callback (nil, nil);
                    return nil;
                }];
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
                [SENAuthorizationService stub:@selector(authorize:password:onCompletion:) withBlock:^id(NSArray *params) {
                    void(^callback)(NSDictionary* response, NSError* error) = [params lastObject];
                    if (callback) callback (nil, [NSError errorWithDomain:@"auth.test" code:-1 userInfo:nil]);
                    return nil;
                }];
                [SENAuthorizationService authorizeWithUsername:emailAddress password:@"pass" callback:NULL];
            });

            it(@"returns nil", ^{
                [[[SENAuthorizationService emailAddressOfAuthorizedUser] should] beNil];
            });
        });
    });
    
    describe(@"+ reauthorizeUserWithPassword:callback", ^{
        
        beforeEach(^{
            [SENAuthorizationService stub:@selector(authorize:password:onCompletion:) withBlock:^id(NSArray *params) {
                void(^callback)(NSDictionary* response, NSError* error) = [params lastObject];
                if (callback) callback (nil, nil);
                return nil;
            }];
        });
        
        it(@"should make a callback", ^{
            
            __block BOOL called = NO;
            [SENAuthorizationService reauthorizeUserWithPassword:@"newpass" callback:^(NSError *error) {
                called = YES;
            }];
            
            [[expectFutureValue(@(called)) shouldSoon] equal:@(YES)];
        });
        
        it(@"email of user should still be the same as initial authorization", ^{
            
            NSString* emailAddress = @"someguy@example.com";
            [SENAuthorizationService authorizeWithUsername:emailAddress password:@"pass" callback:^(NSError *error) {
                [SENAuthorizationService reauthorizeUserWithPassword:@"newpass" callback:nil];
                [[expectFutureValue([SENAuthorizationService emailAddressOfAuthorizedUser]) shouldEventually] equal:emailAddress];
            }];
        });
        
    });
    
});

SPEC_END
