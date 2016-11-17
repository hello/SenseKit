
#import <Kiwi/Kiwi.h>
#import <Nocilla/Nocilla.h>
#import <SenseKit/API.h>
#import <AFNetworking/AFURLSessionManager.h>

@interface SENAuthorizationService()

+ (void)authorize:(NSString*)username
         password:(NSString*)password
     onCompletion:(void(^)(NSDictionary* response, NSError* error))block;
+ (void)authorizeRequestsWithToken:(NSString*)token;
+ (void)setAccountIdOfAuthorizedUser:(NSString*)accountId;
+ (void)notify:(NSString*)notificationName;

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
    
    describe(@"+ deauthorize", ^{
        
        context(@"already deauthorized", ^{
            
            __block BOOL apiCalled = NO;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    apiCalled = YES;
                    SENAPIDataBlock block = [params lastObject];
                    block (nil, nil);
                    return nil;
                }];
                
                [SENAuthorizationService deauthorize];
                
            });
            
            afterEach(^{
                [SENAPIClient clearStubs];
            });
            
            it(@"api should not be called", ^{
                [[@(apiCalled) should] equal:@(NO)];
            });
            
        });
        
        context(@"is currently authorized", ^{
            
            __block BOOL apiCalled = NO;
            __block BOOL notificationCalled = NO;
            __block id token = @"shouldbewiped";
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(DELETE:parameters:completion:) withBlock:^id(NSArray *params) {
                    apiCalled = YES;
                    return nil;
                }];
                
                [SENAuthorizationService stub:@selector(isAuthorized) andReturn:[KWValue valueWithBool:YES]];
                
                [SENAuthorizationService stub:@selector(authorizeRequestsWithToken:) withBlock:^id(NSArray *params) {
                    id param = [params firstObject];
                    token = [param isKindOfClass:[NSNull class]] ? nil : param;
                    return nil;
                }];
                
                [SENAuthorizationService stub:@selector(notify:) withBlock:^id(NSArray *params) {
                    notificationCalled = YES;
                    return nil;
                }];
                
                [SENAuthorizationService deauthorize];
                
            });
            
            afterEach(^{
                
                [SENAuthorizationService clearStubs];
                [SENAPIClient clearStubs];
                
            });
            
            it(@"should call api", ^{
                [[@(apiCalled) should] equal:@(YES)];
            });
            
            it(@"should remove token", ^{
                [[token should] beNil];
            });
            
            it(@"should send notification", ^{
                [[@(notificationCalled) should] equal:@(YES)];
            });
            
        });
        
    });
    
});

SPEC_END
