//
//  ColorConverter.m
//  SmallICCer
//
//  Color Converter implementation.
//  XYZ/Lab use CIE 1931 2° observer. RGB↔XYZ matrices are derived from
//  xy chromaticities and reference white per Bruce Lindbloom's formulation.
//

#import "ColorConverter.h"
#import <math.h>

// D65 reference white (Y=1): IEC 61966-2-1
static const double kD65_X = 0.95047;
static const double kD65_Y = 1.0;
static const double kD65_Z = 1.08883;

// D50 reference white (Y=1): ICC standard
static const double kD50_X = 0.96422;
static const double kD50_Y = 1.0;
static const double kD50_Z = 0.82521;

@implementation ColorConverter

#pragma mark - xy chromaticity and white point helpers

// Convert xy chromaticity to XYZ with Y=1 (for primaries or white).
+ (void)xyChromaticityToXyzWithY1:(double)x y:(double)y xyz:(double *)xyz {
    if (y <= 0.0) {
        xyz[0] = xyz[1] = xyz[2] = 0.0;
        return;
    }
    xyz[0] = x / y;
    xyz[1] = 1.0;
    xyz[2] = (1.0 - x - y) / y;
}

// Fill xyz[3] with D65 white point (Y=1).
+ (void)d65WhitePointXyz:(double *)xyz {
    xyz[0] = kD65_X;
    xyz[1] = kD65_Y;
    xyz[2] = kD65_Z;
}

// Fill xyz[3] with D50 white point (Y=1).
+ (void)d50WhitePointXyz:(double *)xyz {
    xyz[0] = kD50_X;
    xyz[1] = kD50_Y;
    xyz[2] = kD50_Z;
}

// Get XYZ white point from ColorSpace xy white point (Y=1).
+ (void)whitePointXyzFromColorSpace:(NSArray *)whitePointXy outXyz:(double *)xyz {
    if (!whitePointXy || [whitePointXy count] < 2) {
        [self d65WhitePointXyz:xyz];
        return;
    }
    double x = [[whitePointXy objectAtIndex:0] doubleValue];
    double y = [[whitePointXy objectAtIndex:1] doubleValue];
    [self xyChromaticityToXyzWithY1:x y:y xyz:xyz];
}

#pragma mark - XYZ ↔ Lab (CIE 1976 L*a*b*)

+ (void)xyzToLab:(const double *)xyz lab:(double *)lab whitePoint:(const double *)whitePoint {
    // Normalize by white point
    double x = xyz[0] / whitePoint[0];
    double y = xyz[1] / whitePoint[1];
    double z = xyz[2] / whitePoint[2];
    
    // Apply f function (CIE 1976)
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

#pragma mark - RGB ↔ XYZ matrix from primaries and white point

// Compute 3x3 inverse of M into invM. Returns NO if singular.
static BOOL matrix3x3Inverse(const double M[9], double invM[9]) {
    double det = M[0]*(M[4]*M[8] - M[5]*M[7]) - M[1]*(M[3]*M[8] - M[5]*M[6]) + M[2]*(M[3]*M[7] - M[4]*M[6]);
    const double eps = 1e-10;
    if (fabs(det) < eps) return NO;
    double invDet = 1.0 / det;
    invM[0] = (M[4]*M[8] - M[5]*M[7]) * invDet;
    invM[1] = (M[2]*M[7] - M[1]*M[8]) * invDet;
    invM[2] = (M[1]*M[5] - M[2]*M[4]) * invDet;
    invM[3] = (M[5]*M[6] - M[3]*M[8]) * invDet;
    invM[4] = (M[0]*M[8] - M[2]*M[6]) * invDet;
    invM[5] = (M[3]*M[2] - M[0]*M[5]) * invDet;
    invM[6] = (M[3]*M[7] - M[4]*M[6]) * invDet;
    invM[7] = (M[1]*M[6] - M[0]*M[7]) * invDet;
    invM[8] = (M[0]*M[4] - M[1]*M[3]) * invDet;
    return YES;
}

// Build RGB→XYZ matrix from primaries (array of 3 arrays of 2 numbers each) and
// white point (array of 2 numbers). Output: rgb2xyz[9] row-major.
// Formula: Lindbloom, RGB/XYZ Matrices. Returns NO if primaries/white invalid.
+ (BOOL)rgbToXyzMatrixFromPrimaries:(NSArray *)primaries
                         whitePoint:(NSArray *)whitePoint
                          matrixOut:(double *)rgb2xyz {
    if (!primaries || [primaries count] < 3 || !whitePoint || [whitePoint count] < 2) return NO;
    
    double xr = [[[primaries objectAtIndex:0] objectAtIndex:0] doubleValue];
    double yr = [[[primaries objectAtIndex:0] objectAtIndex:1] doubleValue];
    double xg = [[[primaries objectAtIndex:1] objectAtIndex:0] doubleValue];
    double yg = [[[primaries objectAtIndex:1] objectAtIndex:1] doubleValue];
    double xb = [[[primaries objectAtIndex:2] objectAtIndex:0] doubleValue];
    double yb = [[[primaries objectAtIndex:2] objectAtIndex:1] doubleValue];
    double xw = [[whitePoint objectAtIndex:0] doubleValue];
    double yw = [[whitePoint objectAtIndex:1] doubleValue];
    
    double xyzR[3], xyzG[3], xyzB[3], xyzW[3];
    [self xyChromaticityToXyzWithY1:xr y:yr xyz:xyzR];
    [self xyChromaticityToXyzWithY1:xg y:yg xyz:xyzG];
    [self xyChromaticityToXyzWithY1:xb y:yb xyz:xyzB];
    [self xyChromaticityToXyzWithY1:xw y:yw xyz:xyzW];
    
    // Column matrix of primaries: [Xr Xg Xb; Yr Yg Yb; Zr Zg Zb] stored row-major
    double primCol[9] = {
        xyzR[0], xyzG[0], xyzB[0],
        xyzR[1], xyzG[1], xyzB[1],
        xyzR[2], xyzG[2], xyzB[2]
    };
    double W[3] = { xyzW[0], xyzW[1], xyzW[2] };
    double invP[9];
    if (!matrix3x3Inverse(primCol, invP)) return NO;
    // S = inv(P) * W (scale factors so RGB 1,1,1 -> white)
    double S[3];
    S[0] = invP[0]*W[0] + invP[1]*W[1] + invP[2]*W[2];
    S[1] = invP[3]*W[0] + invP[4]*W[1] + invP[5]*W[2];
    S[2] = invP[6]*W[0] + invP[7]*W[1] + invP[8]*W[2];
    
    // M = [Sr*Xr Sg*Xg Sb*Xb; Sr*Yr Sg*Yg Sb*Yb; Sr*Zr Sg*Zg Sb*Zb] (row-major)
    rgb2xyz[0] = S[0]*xyzR[0]; rgb2xyz[1] = S[1]*xyzG[0]; rgb2xyz[2] = S[2]*xyzB[0];
    rgb2xyz[3] = S[0]*xyzR[1]; rgb2xyz[4] = S[1]*xyzG[1]; rgb2xyz[5] = S[2]*xyzB[1];
    rgb2xyz[6] = S[0]*xyzR[2]; rgb2xyz[7] = S[1]*xyzG[2]; rgb2xyz[8] = S[2]*xyzB[2];
    return YES;
}

+ (void)rgbToXyz:(const double *)rgb xyz:(double *)xyz 
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint {
    double M[9];
    BOOL useMatrix = [self rgbToXyzMatrixFromPrimaries:primaries whitePoint:whitePoint matrixOut:M];
    
    if (!useMatrix) {
        // Fallback: sRGB D65 (linear RGB, IEC 61966-2-1)
        M[0] = 0.4124564; M[1] = 0.3575761; M[2] = 0.1804375;
        M[3] = 0.2126729; M[4] = 0.7151522; M[5] = 0.0721750;
        M[6] = 0.0193339; M[7] = 0.1191920; M[8] = 0.9503041;
    }
    
    xyz[0] = M[0]*rgb[0] + M[1]*rgb[1] + M[2]*rgb[2];
    xyz[1] = M[3]*rgb[0] + M[4]*rgb[1] + M[5]*rgb[2];
    xyz[2] = M[6]*rgb[0] + M[7]*rgb[1] + M[8]*rgb[2];
}

+ (void)xyzToRgb:(const double *)xyz rgb:(double *)rgb
       primaries:(NSArray *)primaries whitePoint:(NSArray *)whitePoint {
    double M[9];
    BOOL useMatrix = [self rgbToXyzMatrixFromPrimaries:primaries whitePoint:whitePoint matrixOut:M];
    
    if (!useMatrix) {
        M[0] = 0.4124564; M[1] = 0.3575761; M[2] = 0.1804375;
        M[3] = 0.2126729; M[4] = 0.7151522; M[5] = 0.0721750;
        M[6] = 0.0193339; M[7] = 0.1191920; M[8] = 0.9503041;
    }
    
    double invM[9];
    if (!matrix3x3Inverse(M, invM)) {
        rgb[0] = rgb[1] = rgb[2] = 0.0;
        return;
    }
    
    rgb[0] = invM[0]*xyz[0] + invM[1]*xyz[1] + invM[2]*xyz[2];
    rgb[1] = invM[3]*xyz[0] + invM[4]*xyz[1] + invM[5]*xyz[2];
    rgb[2] = invM[6]*xyz[0] + invM[7]*xyz[1] + invM[8]*xyz[2];
    
    {
        int i;
        for (i = 0; i < 3; i++) {
            if (rgb[i] < 0.0) rgb[i] = 0.0;
            if (rgb[i] > 1.0) rgb[i] = 1.0;
        }
    }
}

@end
