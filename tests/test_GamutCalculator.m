//
//  test_GamutCalculator.m
//  SmallICCer Tests
//
//  Unit tests for gamut calculation and visualization
//

#import <Foundation/Foundation.h>
#import "GamutCalculator.h"
#import "ICCProfile.h"
#import "ICCParser.h"
#import "StandardColorSpaces.h"
#import "ColorSpace.h"

int testGamutCalculatorInitialization() {
    GamutCalculator *calculator = [[GamutCalculator alloc] init];
    if (!calculator) {
        NSLog(@"ERROR: Failed to create GamutCalculator");
        return 1;
    }
    [calculator release];
    NSLog(@"PASS: GamutCalculator initialization");
    return 0;
}

#ifdef HAVE_LCMS
#include <lcms2.h>

int testComputeGamutForProfile() {
    GamutCalculator *calculator = [[GamutCalculator alloc] init];
    ICCParser *parser = [[ICCParser alloc] init];
    
    // Create a test profile
    
    cmsCIExyY whitePoint;
    cmsWhitePointFromTemp(&whitePoint, 5000);
    whitePoint.x = 0.3457;
    whitePoint.y = 0.3585;
    whitePoint.Y = 1.0;
    
    cmsCIExyYTRIPLE primaries;
    primaries.Red.x = 0.6400;
    primaries.Red.y = 0.3300;
    primaries.Red.Y = 1.0;
    primaries.Green.x = 0.3000;
    primaries.Green.y = 0.6000;
    primaries.Green.Y = 1.0;
    primaries.Blue.x = 0.1500;
    primaries.Blue.y = 0.0600;
    primaries.Blue.Y = 1.0;
    
    cmsToneCurve *gamma = cmsBuildGamma(NULL, 2.2);
    cmsToneCurve *curves[3] = {gamma, gamma, gamma};
    
    cmsHPROFILE hProfile = cmsCreateRGBProfileTHR(NULL, &whitePoint, &primaries, curves);
    cmsFreeToneCurve(gamma);
    
    cmsUInt32Number size = 0;
    cmsSaveProfileToMem(hProfile, NULL, &size);
    void *buffer = malloc(size);
    cmsSaveProfileToMem(hProfile, buffer, &size);
    cmsCloseProfile(hProfile);
    
    NSData *profileData = [NSData dataWithBytes:buffer length:size];
    free(buffer);
    
    NSError *error = nil;
    ICCProfile *profile = [parser parseProfileFromData:profileData error:&error];
    
    if (!profile) {
        NSLog(@"ERROR: Failed to parse test profile");
        [calculator release];
        [parser release];
        return 1;
    }
    
    // Compute gamut
    NSArray *gamutPoints = [calculator computeGamutForProfile:profile];
    
    if (!gamutPoints) {
        NSLog(@"ERROR: Gamut computation returned nil");
        [calculator release];
        [parser release];
        return 1;
    }
    
    if ([gamutPoints count] == 0) {
        NSLog(@"ERROR: Gamut should have points");
        [calculator release];
        [parser release];
        return 1;
    }
    
    // Verify points are in Lab space (3 coordinates)
    NSArray *firstPoint = [gamutPoints objectAtIndex:0];
    if ([firstPoint count] != 3) {
        NSLog(@"ERROR: Gamut points should have 3 coordinates (Lab)");
        [calculator release];
        [parser release];
        return 1;
    }
    
    // Verify L* is in valid range (0-100)
    NSNumber *lValue = [firstPoint objectAtIndex:0];
    double l = [lValue doubleValue];
    if (l < 0.0 || l > 100.0) {
        NSLog(@"ERROR: L* should be in range 0-100, got %f", l);
        [calculator release];
        [parser release];
        return 1;
    }
    
    [calculator release];
    [parser release];
    NSLog(@"PASS: Gamut computation for profile");
    return 0;
}

int testComputeGamutForColorSpace() {
    GamutCalculator *calculator = [[GamutCalculator alloc] init];
    
    // Get sRGB color space
    ColorSpace *sRGB = [StandardColorSpaces sRGB];
    if (!sRGB) {
        NSLog(@"ERROR: Failed to get sRGB color space");
        [calculator release];
        return 1;
    }
    
    // Compute gamut
    NSArray *gamutPoints = [calculator computeGamutForColorSpace:sRGB];
    
    if (!gamutPoints) {
        NSLog(@"ERROR: Gamut computation returned nil");
        [calculator release];
        return 1;
    }
    
    if ([gamutPoints count] == 0) {
        NSLog(@"ERROR: Gamut should have points");
        [calculator release];
        return 1;
    }
    
    // Verify points are in Lab space
    NSArray *firstPoint = [gamutPoints objectAtIndex:0];
    if ([firstPoint count] != 3) {
        NSLog(@"ERROR: Gamut points should have 3 coordinates (Lab)");
        [calculator release];
        return 1;
    }
    
    [calculator release];
    NSLog(@"PASS: Gamut computation for color space");
    return 0;
}

int testSampleRGBSpace() {
    GamutCalculator *calculator = [[GamutCalculator alloc] init];
    
    // Test RGB sampling with different resolutions
    NSArray *samples = [calculator sampleRGBSpaceWithResolution:5];
    
    if (!samples) {
        NSLog(@"ERROR: RGB sampling returned nil");
        [calculator release];
        return 1;
    }
    
    // Should have 5^3 = 125 samples
    NSUInteger expectedCount = 5 * 5 * 5;
    if ([samples count] != expectedCount) {
        NSLog(@"ERROR: Expected %lu samples, got %lu", (unsigned long)expectedCount, (unsigned long)[samples count]);
        [calculator release];
        return 1;
    }
    
    // Verify samples are in RGB range (0.0 to 1.0)
    NSArray *firstSample = [samples objectAtIndex:0];
    if ([firstSample count] != 3) {
        NSLog(@"ERROR: RGB samples should have 3 components");
        [calculator release];
        return 1;
    }
    
    NSNumber *r = [firstSample objectAtIndex:0];
    NSNumber *g = [firstSample objectAtIndex:1];
    NSNumber *b = [firstSample objectAtIndex:2];
    
    if ([r doubleValue] < 0.0 || [r doubleValue] > 1.0) {
        NSLog(@"ERROR: R component out of range");
        [calculator release];
        return 1;
    }
    
    [calculator release];
    NSLog(@"PASS: RGB space sampling");
    return 0;
}
#else
int testComputeGamutForProfile() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}

int testComputeGamutForColorSpace() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}

int testSampleRGBSpace() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}
#endif

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testGamutCalculatorInitialization();
    failures += testComputeGamutForProfile();
    failures += testComputeGamutForColorSpace();
    failures += testSampleRGBSpace();
    
    if (failures == 0) {
        NSLog(@"All gamut calculator tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
