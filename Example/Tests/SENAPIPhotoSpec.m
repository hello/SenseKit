//
//  SENAPIPhotoSpec.m
//  SenseKit
//
//  Created by Jimmy Lu on 5/23/16.
//  Copyright © 2016 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "API.h"
#import "Model.h"

SPEC_BEGIN(SENAPIPhotoSpec)

describe(@"SENAPIPhoto", ^{

    describe(@"+uploadProfilePhoto:type:progress:completion", ^{
        
        context(@"jpeg photo uploaded", ^{
            
            __block BOOL calledBack = NO;
            __block NSError* apiError = nil;
            __block NSString* fileName = nil;
            __block NSString* mimeType = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(UPLOAD:name:fileName:mimeType:toURL:parameters:progress:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    fileName = params[2];
                    mimeType = params[3];
                    cb (@{}, nil);
                    return nil;
                }];
                
                [SENAPIPhoto uploadProfilePhoto:[NSData new] type:SENAPIPhotoTypeJpeg progress:nil completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                
                [SENAPIClient clearStubs];
                calledBack = NO;
                apiError = nil;
                fileName = nil;
                mimeType = nil;
                
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have a jpeg mimetype", ^{
                [[mimeType should] equal:@"image/jpeg"];
            });
            
            it(@"filename should be file.jpg", ^{
                [[fileName should] equal:@"file.jpg"];
            });
            
        });
        
        context(@"png photo uploaded", ^{
            
            __block BOOL calledBack = NO;
            __block NSError* apiError = nil;
            __block NSString* fileName = nil;
            __block NSString* mimeType = nil;
            
            beforeEach(^{
                
                [SENAPIClient stub:@selector(UPLOAD:name:fileName:mimeType:toURL:parameters:progress:completion:) withBlock:^id(NSArray *params) {
                    SENAPIDataBlock cb = [params lastObject];
                    fileName = params[2];
                    mimeType = params[3];
                    cb (@{}, nil);
                    return nil;
                }];
                
                [SENAPIPhoto uploadProfilePhoto:[NSData new] type:SENAPIPhotoTypePng progress:nil completion:^(id data, NSError *error) {
                    calledBack = YES;
                    apiError = error;
                }];
                
            });
            
            afterEach(^{
                
                [SENAPIClient clearStubs];
                calledBack = NO;
                apiError = nil;
                fileName = nil;
                mimeType = nil;
                
            });
            
            it(@"should have called back", ^{
                [[@(calledBack) should] beYes];
            });
            
            it(@"should not return an error", ^{
                [[apiError should] beNil];
            });
            
            it(@"should have a jpeg mimetype", ^{
                [[mimeType should] equal:@"image/png"];
            });
            
            it(@"filename should be file.jpg", ^{
                [[fileName should] equal:@"file.png"];
            });
            
        });
        
    });
    
});

SPEC_END
