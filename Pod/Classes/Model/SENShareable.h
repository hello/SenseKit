//
//  SENShareable.h
//  Pods
//
//  Created by Jimmy Lu on 6/21/16.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SENShareable <NSObject>

@required
- (NSString*)identifier;
- (NSString*)shareType;

@end

NS_ASSUME_NONNULL_END
