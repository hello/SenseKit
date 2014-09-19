
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPIClient.h>
#import <AFNetworking/AFHTTPSessionManager.h>

SPEC_BEGIN(SENAPIClientSpec)

describe(@"SENAPIClient", ^{
    NSDictionary* responseData = @{@"kiwi": @"fruit",
                                   @"starfruit": [NSNull null],
                                   @"pies" : @[@"lemon", @"cherry", [NSNull null]],
                                   @"meats" : @{
                                           @"cevapcici" : @YES,
                                           @"meatloaf" : @NO,
                                           @"bacon" : [NSNull null],
                                           }};

    __block AFHTTPSessionManager* sessionManager;
    id (^successMockBlock)(NSArray*) = ^id(NSArray *params) {
        void (^block)(NSURLSessionDataTask *, id) = params[2];
        block(nil, responseData);
        return nil;
    };

    id (^failureMockBlock)(NSArray*) = ^id(NSArray *params) {
        void (^block)(NSURLSessionDataTask *, NSError *) = params[3];
        block(nil, [NSError errorWithDomain:@"is.hello" code:420 userInfo:@{}]);
        return nil;
    };

    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });

    beforeEach(^{
        sessionManager = [[SENAPIClient class] performSelector:@selector(HTTPSessionManager)];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });

    describe(@"Making HTTP requests", ^{

        describe(@"GET:parameters:completion:", ^{
            it(@"sends a GET request", ^{
                [[sessionManager should] receive:@selector(GET:parameters:success:failure:)];
                [SENAPIClient GET:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(GET:parameters:success:failure:) withBlock:successMockBlock];
                [SENAPIClient GET:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(GET:parameters:success:failure:) withBlock:failureMockBlock];
                [SENAPIClient GET:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        describe(@"POST:parameters:completion:", ^{
            it(@"sends a POST request", ^{
                [[sessionManager should] receive:@selector(POST:parameters:success:failure:)];
                [SENAPIClient POST:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(POST:parameters:success:failure:) withBlock:successMockBlock];
                [SENAPIClient POST:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(POST:parameters:success:failure:) withBlock:failureMockBlock];
                [SENAPIClient POST:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        describe(@"PUT:parameters:completion:", ^{
            it(@"sends a PUT request", ^{
                [[sessionManager should] receive:@selector(PUT:parameters:success:failure:)];
                [SENAPIClient PUT:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(PUT:parameters:success:failure:) withBlock:successMockBlock];
                [SENAPIClient PUT:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(PUT:parameters:success:failure:) withBlock:failureMockBlock];
                [SENAPIClient PUT:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        describe(@"PATCH:parameters:completion:", ^{
            it(@"sends a PATCH request", ^{
                [[sessionManager should] receive:@selector(PATCH:parameters:success:failure:)];
                [SENAPIClient PATCH:@"/" parameters:@{ @"red" : @YES } completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(PATCH:parameters:success:failure:) withBlock:successMockBlock];
                [SENAPIClient PATCH:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(PATCH:parameters:success:failure:) withBlock:failureMockBlock];
                [SENAPIClient PATCH:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        describe(@"DELETE:parameters:completion:", ^{
            it(@"sends a DELETE request", ^{
                [[sessionManager should] receive:@selector(DELETE:parameters:success:failure:)];
                [SENAPIClient DELETE:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(DELETE:parameters:success:failure:) withBlock:successMockBlock];
                [SENAPIClient DELETE:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(DELETE:parameters:success:failure:) withBlock:failureMockBlock];
                [SENAPIClient DELETE:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });
    });

    context(@"NSNull values are retrieved from API requests", ^{

        beforeEach(^{
            [sessionManager stub:@selector(GET:parameters:success:failure:) withBlock:successMockBlock];
        });

        it(@"removes NSNull values and keys", ^{
            [SENAPIClient GET:@"fruit" parameters:nil completion:^(NSDictionary* data, NSError *error) {
                [[data[@"starfruit"] should] beNil];
            }];
        });

        it(@"removes nested NSNull values and keys", ^{
            [SENAPIClient GET:@"fruit" parameters:nil completion:^(NSDictionary* data, NSError *error) {
                [[data[@"meats"][@"bacon"] should] beNil];
            }];
        });

        it(@"removes NSNull values from arrays", ^{
            [SENAPIClient GET:@"fruit" parameters:nil completion:^(NSDictionary* data, NSError *error) {
                [[data[@"pies"] shouldNot] containObjects:[NSNull null], nil];
            }];
        });
    });
});

SPEC_END
