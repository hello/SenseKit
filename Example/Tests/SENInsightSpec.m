//
//  SENInsightSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 2/6/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENInsight.h>


SPEC_BEGIN(SENInsightSpec)

describe(@"SENInsight", ^{

    __block SENInsight* insight;

    afterEach(^{
        insight = nil;
    });

    describe(@"initWithDictionary:", ^{

        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
        NSDictionary* data = @{@"timestamp":@(timeInterval * 1000),
                               @"title": @"The forecast calls for rain",
                               @"message": @"You may need to patch your roof, it is too damp for quality sleep.",
                               @"category": @"ROOF_SENSOR"};

        beforeEach(^{
            insight = [[SENInsight alloc] initWithDictionary:data];
        });

        it(@"sets the creation date", ^{
            double diff = ABS([insight.dateCreated timeIntervalSince1970] - timeInterval);
            [[@(diff) should] beLessThan:@1];
        });

        it(@"sets the title", ^{
            [[insight.title should] equal:data[@"title"]];
        });

        it(@"sets the message", ^{
            [[insight.message should] equal:data[@"message"]];
        });

        it(@"sets the category", ^{
            [[insight.category should] equal:data[@"category"]];
        });

        it(@"is equal to an insight with the same properties", ^{
            SENInsight* other = [[SENInsight alloc] initWithDictionary:data];
            [[insight should] equal:other];
            [[@(insight.hash) should] equal:@(other.hash)];
        });

        it(@"is not equal to an insight with different properties", ^{
            SENInsight* other = [[SENInsight alloc] initWithDictionary:@{@"title":@"Blue moons are bad for you"}];
            [[insight shouldNot] equal:other];
        });
    });

    describe(@"isGeneric", ^{

        context(@"category is generic", ^{

            beforeEach(^{
                insight = [[SENInsight alloc] initWithDictionary:@{@"category":@"GENERIC"}];
            });

            it(@"is YES", ^{
                [[@([insight isGeneric]) should] beYes];
            });
        });

        context(@"category is not generic", ^{

            beforeEach(^{
                insight = [[SENInsight alloc] initWithDictionary:@{@"category":@"SNAZZ"}];
            });

            it(@"is YES", ^{
                [[@([insight isGeneric]) should] beNo];
            });
        });
    });
    
    describe(@"-isEqual:", ^{
        
        it(@"it is equal", ^{
            
            NSDictionary* dict = @{@"title" : @"1", @"category":@"SNAZZ", @"info_preview" : @"preview"};
            insight = [[SENInsight alloc] initWithDictionary:dict];
            SENInsight* insight2 = [[SENInsight alloc] initWithDictionary:dict];
            [[insight should] equal:insight2];
            
        });
        
        it(@"is is not equal", ^{
            
            NSDictionary* dict1 = @{@"title" : @"1", @"category":@"SNAZZ", @"info_preview" : @"preview"};
            NSDictionary* dict2 = @{@"title" : @"1", @"category":@"SNAZZ"};
            
            insight = [[SENInsight alloc] initWithDictionary:dict1];
            SENInsight* insight2 = [[SENInsight alloc] initWithDictionary:dict2];
            [[insight shouldNot] equal:insight2];
            
        });
        
    });
});

SPEC_END
