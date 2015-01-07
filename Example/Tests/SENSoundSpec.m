//
//  SENSoundSpec.m
//  SenseKit
//
//  Created by Delisa Mason on 1/6/15.
//  Copyright 2015 Hello, Inc. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import <SenseKit/SENSound.h>


SPEC_BEGIN(SENSoundSpec)

describe(@"SENSound", ^{

    describe(@"initWithDictionary:", ^{
        __block SENSound* sound;
        NSString* name = @"Lilt";
        NSString* path = @"http://example.com/sounds/lilt.mp3";
        NSString* identifier = @"FILE002";

        beforeEach(^{
            sound = [[SENSound alloc] initWithDictionary:@{@"name":name, @"url":path, @"id":identifier}];
        });

        it(@"sets the name", ^{
            [[sound.displayName should] equal:name];
        });

        it(@"sets the URL path", ^{
            [[sound.URLPath should] equal:path];
        });

        it(@"sets the identifier", ^{
            [[sound.identifier should] equal:identifier];
        });

        it(@"is serializable", ^{
            [[sound should] conformToProtocol:@protocol(NSCoding)];
        });

        context(@"after serialization", ^{

            __block SENSound* decodedSound;

            beforeEach(^{
                NSData* data = [NSKeyedArchiver archivedDataWithRootObject:sound];
                decodedSound = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            });

            it(@"sets the name", ^{
                [[decodedSound.displayName should] equal:name];
            });

            it(@"sets the URL path", ^{
                [[decodedSound.URLPath should] equal:path];
            });

            it(@"sets the identifier", ^{
                [[decodedSound.identifier should] equal:identifier];
            });
        });
    });
});

SPEC_END
