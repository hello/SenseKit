
#import <Foundation/Foundation.h>

@interface SENInsight : NSObject <NSCoding>

@property (nonatomic, strong) NSDate* dateCreated;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSString* message;
@end
