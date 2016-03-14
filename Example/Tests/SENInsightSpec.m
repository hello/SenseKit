//
//  SENInsightSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 2/6/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/Model.h>

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
                               @"category": @"ROOF_SENSOR",
                               @"insight_type" : @"BASIC",
                               @"image" : @{@"phone_1x" : @"https://someimage.url.com/1x",
                                            @"phone_2x" : @"https://someimage.url.com/2x",
                                            @"phone_3x" : @"https://someimage.url.com/3x"}};

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
        
        it(@"should create a SENRemoteImage object", ^{
            [[insight.remoteImage should] beKindOfClass:[SENRemoteImage class]];
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
        
        it(@"should set insight type", ^{
            [[@(insight.type) should] equal:@(SENInsightTypeBasic)];
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
