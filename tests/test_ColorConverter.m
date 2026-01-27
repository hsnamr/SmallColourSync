//
//  test_ColorConverter.m
//  SmallICCer Tests
//
//  Unit tests for ColorConverter
//

#import <Foundation/Foundation.h>
#import "ColorConverter.h"

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

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testXYZToLab();
    failures += testLabToXYZ();
    
    if (failures == 0) {
        NSLog(@"All tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
