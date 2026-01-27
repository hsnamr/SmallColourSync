//
//  ColorConverter.h
//  SmallICCer
//
//  Converts between color spaces (XYZ ↔ Lab, RGB ↔ XYZ)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorConverter : NSObject

// XYZ to Lab conversion
+ (void)xyzToLab:(const double *)xyz lab:(double *)lab whitePoint:(const double *)whitePoint;

// Lab to XYZ conversion
+ (void)labToXyz:(const double *)lab xyz:(double *)xyz whitePoint:(const double *)whitePoint;

// RGB to XYZ conversion (using color space primaries and white point)
+ (void)rgbToXyz:(const double *)rgb xyz:(double *)xyz 
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint;

// XYZ to RGB conversion
+ (void)xyzToRgb:(const double *)xyz rgb:(double *)rgb
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint;

@end

NS_ASSUME_NONNULL_END
