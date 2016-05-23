
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/SENAPIClient.h>
#import <AFNetworking/AFHTTPSessionManager.h>

@interface SENAPIClient (Private)

+ (NSString*)urlEncode:(NSString*)URLString;
+ (AFHTTPSessionManager*)HTTPSessionManager;
@end

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
    
    id(^successMockBlockWithProgress)(NSArray*) =^id(NSArray* params) {
        void (^block)(NSURLSessionDataTask *, id) = params[3];
        block(nil, responseData);
        return nil;
    };
    
    id (^failureMockBlockWithProgress)(NSArray*) = ^id(NSArray *params) {
        void (^block)(NSURLSessionDataTask *, NSError *) = params[4];
        block(nil, [NSError errorWithDomain:@"is.hello" code:420 userInfo:@{}]);
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
        sessionManager = [SENAPIClient HTTPSessionManager];
    });

    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    
    describe(@"+urlEncode:", ^{
        
        it(@"url encoding encodes spaces", ^{
            NSString* path = @"devices/my device id";
            NSString* encoding = [SENAPIClient urlEncode:path];
            [[@([encoding rangeOfString:@" "].location) should] equal:@(NSNotFound)];
        });
        
        it(@"url encoding does not destroy ? and &", ^{
            NSString* path = @"questions?date=1900-01-01&test=true";
            NSString* encoding = [SENAPIClient urlEncode:path];
            [[encoding should] equal:path];
        });
        
    });

    describe(@"Making HTTP requests", ^{

        describe(@"GET:parameters:completion:", ^{
            it(@"sends a GET request", ^{
                [[sessionManager should] receive:@selector(GET:parameters:progress:success:failure:)];
                [SENAPIClient GET:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(GET:parameters:progress:success:failure:) withBlock:successMockBlockWithProgress];
                [SENAPIClient GET:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(GET:parameters:progress:success:failure:) withBlock:failureMockBlockWithProgress];
                [SENAPIClient GET:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });
        });

        describe(@"POST:parameters:completion:", ^{
            it(@"sends a POST request", ^{
                [[sessionManager should] receive:@selector(POST:parameters:progress:success:failure:)];
                [SENAPIClient POST:@"/" parameters:nil completion:NULL];
            });

            it(@"invokes the completion block on success", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(POST:parameters:progress:success:failure:) withBlock:successMockBlockWithProgress];
                [SENAPIClient POST:@"/" parameters:nil completion:^(id data, NSError *error) {
                    callbackInvoked = YES;
                }];
                [[expectFutureValue(@(callbackInvoked)) shouldSoon] beYes];
            });

            it(@"invokes the completion block on failure", ^{
                __block BOOL callbackInvoked = NO;
                [sessionManager stub:@selector(POST:parameters:progress:success:failure:) withBlock:failureMockBlockWithProgress];
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
            [sessionManager stub:@selector(GET:parameters:progress:success:failure:) withBlock:successMockBlockWithProgress];
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
