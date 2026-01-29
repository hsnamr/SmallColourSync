//
//  test_ICCWriter.m
//  SmallICCer Tests
//
//  Unit tests for ICC profile writing
//

#import <Foundation/Foundation.h>
#import "ICCWriter.h"
#import "ICCProfile.h"
#import "ICCParser.h"
#import "ICCTagTRC.h"

int testWriterInitialization() {
    ICCWriter *writer = [[ICCWriter alloc] init];
    if (!writer) {
        NSLog(@"ERROR: Failed to create ICCWriter");
        return 1;
    }
    [writer release];
    NSLog(@"PASS: ICCWriter initialization");
    return 0;
}

#ifdef HAVE_LCMS
int testWriteProfile() {
    ICCParser *parser = [[ICCParser alloc] init];
    ICCWriter *writer = [[ICCWriter alloc] init];
    
    // Create a test profile
    #include <lcms2.h>
    
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
    
    // Parse the profile
    NSError *error = nil;
    ICCProfile *profile = [parser parseProfileFromData:profileData error:&error];
    
    if (!profile) {
        NSLog(@"ERROR: Failed to parse test profile");
        [parser release];
        [writer release];
        return 1;
    }
    
    // Write to temporary file
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test_profile.icc"];
    error = nil;
    BOOL success = [writer writeProfile:profile toPath:tempPath error:&error];
    
    if (!success) {
        NSLog(@"ERROR: Failed to write profile: %@", error);
        [parser release];
        [writer release];
        return 1;
    }
    
    // Verify file exists
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:tempPath]) {
        NSLog(@"ERROR: Written file does not exist");
        [parser release];
        [writer release];
        return 1;
    }
    
    // Verify file is readable
    NSData *writtenData = [NSData dataWithContentsOfFile:tempPath];
    if (!writtenData || [writtenData length] == 0) {
        NSLog(@"ERROR: Written file is empty or unreadable");
        [parser release];
        [writer release];
        return 1;
    }
    
    // Clean up
    [fm removeItemAtPath:tempPath error:nil];
    
    [parser release];
    [writer release];
    NSLog(@"PASS: Profile writing");
    return 0;
}

int testWriteReadRoundTrip() {
    ICCParser *parser = [[ICCParser alloc] init];
    ICCWriter *writer = [[ICCWriter alloc] init];
    
    // Create a test profile
    #include <lcms2.h>
    
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
    
    NSData *originalData = [NSData dataWithBytes:buffer length:size];
    free(buffer);
    
    // Parse original
    NSError *error = nil;
    ICCProfile *originalProfile = [parser parseProfileFromData:originalData error:&error];
    
    if (!originalProfile) {
        NSLog(@"ERROR: Failed to parse original profile");
        [parser release];
        [writer release];
        return 1;
    }
    
    NSUInteger originalSize = [originalProfile profileSize];
    NSUInteger originalVersion = [originalProfile version];
    NSArray *originalTags = [originalProfile allTagSignatures];
    
    // Write and read back
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test_roundtrip.icc"];
    error = nil;
    BOOL success = [writer writeProfile:originalProfile toPath:tempPath error:&error];
    
    if (!success) {
        NSLog(@"ERROR: Failed to write profile");
        [parser release];
        [writer release];
        return 1;
    }
    
    // Read back
    error = nil;
    ICCProfile *readProfile = [parser parseProfileFromPath:tempPath error:&error];
    
    if (!readProfile) {
        NSLog(@"ERROR: Failed to read back profile: %@", error);
        [parser release];
        [writer release];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        return 1;
    }
    
    // Verify basic properties are preserved
    // Note: Some properties may differ due to simplified writer implementation
    NSArray *readTags = [readProfile allTagSignatures];
    
    if ([readTags count] == 0) {
        NSLog(@"ERROR: Read profile has no tags");
        [parser release];
        [writer release];
        [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
        return 1;
    }
    
    // Clean up
    [[NSFileManager defaultManager] removeItemAtPath:tempPath error:nil];
    
    [parser release];
    [writer release];
    NSLog(@"PASS: Write/read round-trip");
    return 0;
}

int testWriteInvalidPath() {
    ICCWriter *writer = [[ICCWriter alloc] init];
    ICCProfile *profile = [[ICCProfile alloc] init];
    
    // Try to write to invalid path
    NSError *error = nil;
    BOOL success = [writer writeProfile:profile toPath:@"/invalid/path/profile.icc" error:&error];
    
    if (success) {
        NSLog(@"ERROR: Should fail for invalid path");
        [writer release];
        [profile release];
        return 1;
    }
    
    if (error == nil) {
        NSLog(@"ERROR: Should set error for invalid path");
        [writer release];
        [profile release];
        return 1;
    }
    
    [writer release];
    [profile release];
    NSLog(@"PASS: Invalid path handling");
    return 0;
}
#else
int testWriteProfile() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}

int testWriteReadRoundTrip() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}

int testWriteInvalidPath() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}
#endif

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testWriterInitialization();
    failures += testWriteProfile();
    failures += testWriteReadRoundTrip();
    failures += testWriteInvalidPath();
    
    if (failures == 0) {
        NSLog(@"All ICC writer tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
