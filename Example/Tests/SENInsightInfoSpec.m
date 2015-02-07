//
//  SENInsightInfoSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 2/6/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENInsight.h>


SPEC_BEGIN(SENInsightInfoSpec)

describe(@"SENInsightInfo", ^{

    __block SENInsightInfo* info;

    afterEach(^{
        info = nil;
    });

    describe(@"initWithDictionary:", ^{

        NSDictionary* data = @{@"identifier":@456,
                               @"category":@"PIZZA_ROLLS",
                               @"text":@"This is some info",
                               @"title":@"INFORMACION",
                               @"image_url":@"https://example.com/img/example.jpg"};

        beforeEach(^{
            info = [[SENInsightInfo alloc] initWithDictionary:data];
        });

        it(@"sets the identifier", ^{
            [[@(info.identifier) should] equal:data[@"identifier"]];
        });

        it(@"sets the category", ^{
            [[info.category should] equal:data[@"category"]];
        });

        it(@"sets info", ^{
            [[info.info should] equal:data[@"text"]];
        });

        it(@"sets the title", ^{
            [[info.title should] equal:data[@"title"]];
        });

        it(@"sets the image URI", ^{
            [[info.imageURI should] equal:data[@"image_url"]];
        });

        it(@"is equal to an info with the same properties", ^{
            SENInsightInfo* other = [[SENInsightInfo alloc] initWithDictionary:data];
            [[info should] equal:other];
            [[@(info.hash) should] equal:@(other.hash)];
        });

        it(@"is not equal to an info with different properties", ^{
            SENInsightInfo* other = [[SENInsightInfo alloc] initWithDictionary:@{@"title":@"All work no play",
                                                                                 @"info":@"Working so late is destroying your sleep"}];
            [[info shouldNot] equal:other];
        });
    });
});

SPEC_END
