//
//  ColorConverter.m
//  SmallICCer
//
//  Color Converter implementation
//

#import "ColorConverter.h"
#import <math.h>

@implementation ColorConverter

+ (void)xyzToLab:(const double *)xyz lab:(double *)lab whitePoint:(const double *)whitePoint {
    // Normalize by white point
    double x = xyz[0] / whitePoint[0];
    double y = xyz[1] / whitePoint[1];
    double z = xyz[2] / whitePoint[2];
    
    // Apply f function
    double fx = (x > 0.008856) ? pow(x, 1.0/3.0) : (7.787 * x + 16.0/116.0);
    double fy = (y > 0.008856) ? pow(y, 1.0/3.0) : (7.787 * y + 16.0/116.0);
    double fz = (z > 0.008856) ? pow(z, 1.0/3.0) : (7.787 * z + 16.0/116.0);
    
    lab[0] = 116.0 * fy - 16.0; // L*
    lab[1] = 500.0 * (fx - fy);  // a*
    lab[2] = 200.0 * (fy - fz);  // b*
}

+ (void)labToXyz:(const double *)lab xyz:(double *)xyz whitePoint:(const double *)whitePoint {
    double fy = (lab[0] + 16.0) / 116.0;
    double fx = lab[1] / 500.0 + fy;
    double fz = fy - lab[2] / 200.0;
    
    double xr = (fx > 0.206897) ? pow(fx, 3.0) : (fx - 16.0/116.0) / 7.787;
    double yr = (fy > 0.206897) ? pow(fy, 3.0) : (fy - 16.0/116.0) / 7.787;
    double zr = (fz > 0.206897) ? pow(fz, 3.0) : (fz - 16.0/116.0) / 7.787;
    
    xyz[0] = xr * whitePoint[0];
    xyz[1] = yr * whitePoint[1];
    xyz[2] = zr * whitePoint[2];
}

+ (void)rgbToXyz:(const double *)rgb xyz:(double *)xyz 
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint {
    // This is a simplified conversion - a full implementation would
    // properly handle the matrix transformation from RGB to XYZ
    // using the primaries and white point
    
    // For now, use a simple linear approximation
    // In a real implementation, we'd:
    // 1. Apply TRC (gamma) to linearize RGB
    // 2. Convert to XYZ using primaries matrix
    // 3. Normalize by white point
    
    xyz[0] = rgb[0] * 0.4124 + rgb[1] * 0.3576 + rgb[2] * 0.1805;
    xyz[1] = rgb[0] * 0.2126 + rgb[1] * 0.7152 + rgb[2] * 0.0722;
    xyz[2] = rgb[0] * 0.0193 + rgb[1] * 0.1192 + rgb[2] * 0.9505;
}

+ (void)xyzToRgb:(const double *)xyz rgb:(double *)rgb
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint {
    // Simplified inverse conversion
    rgb[0] = xyz[0] * 3.2406 + xyz[1] * -1.5372 + xyz[2] * -0.4986;
    rgb[1] = xyz[0] * -0.9689 + xyz[1] * 1.8758 + xyz[2] * 0.0415;
    rgb[2] = xyz[0] * 0.0557 + xyz[1] * -0.2040 + xyz[2] * 1.0570;
    
    // Clamp to [0, 1]
    int i;
    for (i = 0; i < 3; i++) {
        if (rgb[i] < 0.0) rgb[i] = 0.0;
        if (rgb[i] > 1.0) rgb[i] = 1.0;
    }
}

@end
