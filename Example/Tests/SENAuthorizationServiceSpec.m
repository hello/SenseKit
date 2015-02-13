
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
        [SENAPIClient stub:@selector(DELETE:parameters:completion:)];
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
            [SENAuthorizationService reauthorizeUser:@"username" password:@"newpass" callback:^(NSError *error) {
                called = YES;
            }];
            
            [[@(called) should] equal:@(YES)];
        });
        
    });
    
});

SPEC_END
