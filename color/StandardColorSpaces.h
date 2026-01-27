//
//  StandardColorSpaces.h
//  SmallICCer
//
//  Static definitions for standard color spaces
//

#import <Foundation/Foundation.h>
#import "ColorSpace.h"

NS_ASSUME_NONNULL_BEGIN

@interface StandardColorSpaces : NSObject

+ (ColorSpace *)sRGB;
+ (ColorSpace *)adobeRGB;
+ (ColorSpace *)displayP3;
+ (ColorSpace *)proPhotoRGB;
+ (ColorSpace *)rec2020;
+ (NSArray *)allStandardSpaces;

@end

NS_ASSUME_NONNULL_END
