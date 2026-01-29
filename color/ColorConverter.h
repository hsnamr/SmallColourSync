//
//  ColorConverter.h
//  SmallICCer
//
//  Converts between color spaces (XYZ ↔ Lab, RGB ↔ XYZ)
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorConverter : NSObject

// xy chromaticity (2 numbers) to XYZ with Y=1
+ (void)xyChromaticityToXyzWithY1:(double)x y:(double)y xyz:(double *)xyz;

// Standard white points (Y=1): fill xyz[3]
+ (void)d65WhitePointXyz:(double *)xyz;
+ (void)d50WhitePointXyz:(double *)xyz;

// Get XYZ white point from ColorSpace white point (array of 2 xy values). Uses D65 if nil.
+ (void)whitePointXyzFromColorSpace:(NSArray *)whitePointXy outXyz:(double *)xyz;

// XYZ to Lab conversion (CIE 1976 L*a*b*, white point in XYZ)
+ (void)xyzToLab:(const double *)xyz lab:(double *)lab whitePoint:(const double *)whitePoint;

// Lab to XYZ conversion
+ (void)labToXyz:(const double *)lab xyz:(double *)xyz whitePoint:(const double *)whitePoint;

// RGB to XYZ conversion (linear RGB; matrix from primaries and white point xy; nil = sRGB D65)
+ (void)rgbToXyz:(const double *)rgb xyz:(double *)xyz 
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint;

// XYZ to RGB conversion (output clamped to [0,1])
+ (void)xyzToRgb:(const double *)xyz rgb:(double *)rgb
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint;

@end

NS_ASSUME_NONNULL_END
