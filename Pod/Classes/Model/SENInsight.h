
#import <Foundation/Foundation.h>

@interface SENInsight : NSObject <NSCoding>

@property (nonatomic, strong, readonly) NSDate* dateCreated;
@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* message;
@property (nonatomic, copy, readonly)   NSString* category;
@property (nonatomic, copy, readonly)   NSString* infoPreview;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

/**
 *  Convenience method for determining if an insight is in the generic category
 *
 *  @return YES if the category is generic
 */
- (BOOL)isGeneric;

@end

@interface SENInsightInfo : NSObject <NSCoding>

@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, copy, readonly)   NSString* category;
@property (nonatomic, copy, readonly)   NSString* title;
@property (nonatomic, copy, readonly)   NSString* info;
@property (nonatomic, copy, readonly)   NSString* imageURI;

- (instancetype)initWithDictionary:(NSDictionary*)dict;

@end
