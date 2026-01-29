//
//  test_ColorConverter.m
//  SmallICCer Tests
//
//  Unit tests for ColorConverter and StandardColorSpaces verification (Task 2.2).
//

#import <Foundation/Foundation.h>
#import "ColorConverter.h"
#import "StandardColorSpaces.h"
#import "ColorSpace.h"
#import <math.h>

#define TOL 0.02
#define TOL_STRICT 0.005

int testXYZToLab() {
    double xyz[3] = {0.9642, 1.0, 0.8249}; // D50 white point
    double whitePoint[3] = {0.9642, 1.0, 0.8249};
    double lab[3];
    
    [ColorConverter xyzToLab:xyz lab:lab whitePoint:whitePoint];
    
    // D50 white point should convert to approximately L*=100, a*=0, b*=0
    if (lab[0] < 99.0 || lab[0] > 101.0) {
        NSLog(@"ERROR: L* should be ~100, got %f", lab[0]);
        return 1;
    }
    if (fabs(lab[1]) > 1.0) {
        NSLog(@"ERROR: a* should be ~0, got %f", lab[1]);
        return 1;
    }
    if (fabs(lab[2]) > 1.0) {
        NSLog(@"ERROR: b* should be ~0, got %f", lab[2]);
        return 1;
    }
    
    NSLog(@"PASS: XYZ to Lab conversion test");
    return 0;
}

int testLabToXYZ() {
    double lab[3] = {100.0, 0.0, 0.0}; // White point in Lab
    double whitePoint[3] = {0.9642, 1.0, 0.8249};
    double xyz[3];
    
    [ColorConverter labToXyz:lab xyz:xyz whitePoint:whitePoint];
    
    // Should convert back to approximately the white point
    if (fabs(xyz[0] - whitePoint[0]) > 0.01) {
        NSLog(@"ERROR: X should be ~%f, got %f", whitePoint[0], xyz[0]);
        return 1;
    }
    if (fabs(xyz[1] - whitePoint[1]) > 0.01) {
        NSLog(@"ERROR: Y should be ~%f, got %f", whitePoint[1], xyz[1]);
        return 1;
    }
    if (fabs(xyz[2] - whitePoint[2]) > 0.01) {
        NSLog(@"ERROR: Z should be ~%f, got %f", whitePoint[2], xyz[2]);
        return 1;
    }
    
    NSLog(@"PASS: Lab to XYZ conversion test");
    return 0;
}

int testD65WhitePoint() {
    double xyz[3];
    [ColorConverter d65WhitePointXyz:xyz];
    // D65: x=0.3127, y=0.3290 -> X≈0.95047, Y=1, Z≈1.08883
    if (fabs(xyz[0] - 0.95047) > TOL || fabs(xyz[1] - 1.0) > TOL || fabs(xyz[2] - 1.08883) > TOL) {
        NSLog(@"ERROR: D65 white point wrong: got %f %f %f", xyz[0], xyz[1], xyz[2]);
        return 1;
    }
    NSLog(@"PASS: D65 white point");
    return 0;
}

int testD50WhitePoint() {
    double xyz[3];
    [ColorConverter d50WhitePointXyz:xyz];
    if (fabs(xyz[0] - 0.96422) > TOL || fabs(xyz[1] - 1.0) > TOL || fabs(xyz[2] - 0.82521) > TOL) {
        NSLog(@"ERROR: D50 white point wrong: got %f %f %f", xyz[0], xyz[1], xyz[2]);
        return 1;
    }
    NSLog(@"PASS: D50 white point");
    return 0;
}

int testSRGBWhiteToLab() {
    // sRGB (1,1,1) linear -> D65 XYZ -> Lab should be ~(100, 0, 0) with D65 white
    double rgb[3] = {1.0, 1.0, 1.0};
    double xyz[3];
    [ColorConverter rgbToXyz:rgb xyz:xyz primaries:nil whitePoint:nil];
    double wp[3];
    [ColorConverter d65WhitePointXyz:wp];
    double lab[3];
    [ColorConverter xyzToLab:xyz lab:lab whitePoint:wp];
    if (lab[0] < 99.0 || lab[0] > 101.0 || fabs(lab[1]) > 1.5 || fabs(lab[2]) > 1.5) {
        NSLog(@"ERROR: sRGB white Lab expected ~(100,0,0), got (%f,%f,%f)", lab[0], lab[1], lab[2]);
        return 1;
    }
    NSLog(@"PASS: sRGB white to Lab (D65)");
    return 0;
}

int testStandardColorSpacesExist() {
    NSArray *all = [StandardColorSpaces allStandardSpaces];
    if (!all || [all count] != 5) {
        NSLog(@"ERROR: allStandardSpaces should return 5 spaces, got %lu", (unsigned long)(all ? [all count] : 0));
        return 1;
    }
    NSUInteger i;
    for (i = 0; i < 5; i++) {
        ColorSpace *cs = [all objectAtIndex:i];
        if (![cs isKindOfClass:[ColorSpace class]]) {
            NSLog(@"ERROR: Standard space %lu is not ColorSpace", (unsigned long)i);
            return 1;
        }
        if (![cs name] || ![[cs primaries] isKindOfClass:[NSArray class]] || [cs primaries].count != 3) {
            NSLog(@"ERROR: Standard space %@ invalid primaries", [cs name]);
            return 1;
        }
        if (![cs whitePoint] || [cs whitePoint].count != 2) {
            NSLog(@"ERROR: Standard space %@ invalid white point", [cs name]);
            return 1;
        }
    }
    NSLog(@"PASS: All 5 standard color spaces present with valid primaries and white point");
    return 0;
}

int testRoundTripEachStandardSpace() {
    NSArray *all = [StandardColorSpaces allStandardSpaces];
    double whitePointXyz[3];
    for (ColorSpace *cs in all) {
        [ColorConverter whitePointXyzFromColorSpace:[cs whitePoint] outXyz:whitePointXyz];
        // Test (1,1,1) round-trip: RGB -> XYZ -> Lab -> XYZ -> RGB
        double rgb0[3] = {1.0, 1.0, 1.0};
        double xyz[3], lab[3], rgb1[3];
        [ColorConverter rgbToXyz:rgb0 xyz:xyz primaries:[cs primaries] whitePoint:[cs whitePoint]];
        [ColorConverter xyzToLab:xyz lab:lab whitePoint:whitePointXyz];
        [ColorConverter labToXyz:lab xyz:xyz whitePoint:whitePointXyz];
        [ColorConverter xyzToRgb:xyz rgb:rgb1 primaries:[cs primaries] whitePoint:[cs whitePoint]];
        if (fabs(rgb1[0] - 1.0) > TOL || fabs(rgb1[1] - 1.0) > TOL || fabs(rgb1[2] - 1.0) > TOL) {
            NSLog(@"ERROR: Round-trip failed for %@: got RGB (%f,%f,%f)", [cs name], rgb1[0], rgb1[1], rgb1[2]);
            return 1;
        }
    }
    NSLog(@"PASS: Round-trip (1,1,1) for all standard spaces");
    return 0;
}

int testXYChromaticityToXyz() {
    // D65 xy = (0.3127, 0.3290) -> XYZ with Y=1: X = x/y, Z = (1-x-y)/y
    double xyz[3];
    [ColorConverter xyChromaticityToXyzWithY1:0.3127 y:0.3290 xyz:xyz];
    double x = 0.3127/0.3290;
    double z = (1.0 - 0.3127 - 0.3290) / 0.3290;
    if (fabs(xyz[0] - x) > TOL_STRICT || fabs(xyz[1] - 1.0) > TOL_STRICT || fabs(xyz[2] - z) > TOL_STRICT) {
        NSLog(@"ERROR: xy to XYZ wrong: got (%f,%f,%f) expected (%f,1,%f)", xyz[0], xyz[1], xyz[2], x, z);
        return 1;
    }
    NSLog(@"PASS: xy chromaticity to XYZ (Y=1)");
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testXYZToLab();
    failures += testLabToXYZ();
    failures += testD65WhitePoint();
    failures += testD50WhitePoint();
    failures += testSRGBWhiteToLab();
    failures += testStandardColorSpacesExist();
    failures += testRoundTripEachStandardSpace();
    failures += testXYChromaticityToXyz();
    
    if (failures == 0) {
        NSLog(@"All tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
