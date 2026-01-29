//
//  test_ICCParser.m
//  SmallICCer Tests
//
//  Unit tests for ICC profile parsing
//

#import <Foundation/Foundation.h>
#import "ICCParser.h"
#import "ICCProfile.h"
#import "ICCTag.h"
#import "ICCTagTRC.h"
#import "ICCTagMetadata.h"

int testParserInitialization() {
    ICCParser *parser = [[ICCParser alloc] init];
    if (!parser) {
        NSLog(@"ERROR: Failed to create ICCParser");
        return 1;
    }
    [parser release];
    NSLog(@"PASS: ICCParser initialization");
    return 0;
}

int testParseInvalidData() {
    ICCParser *parser = [[ICCParser alloc] init];
    NSData *invalidData = [NSData dataWithBytes:"invalid" length:7];
    NSError *error = nil;
    
    ICCProfile *profile = [parser parseProfileFromData:invalidData error:&error];
    
    if (profile != nil) {
        NSLog(@"ERROR: Should return nil for invalid data");
        [parser release];
        return 1;
    }
    
    if (error == nil) {
        NSLog(@"ERROR: Should set error for invalid data");
        [parser release];
        return 1;
    }
    
    [parser release];
    NSLog(@"PASS: Invalid data handling");
    return 0;
}

int testParseNonexistentFile() {
    ICCParser *parser = [[ICCParser alloc] init];
    NSError *error = nil;
    
    ICCProfile *profile = [parser parseProfileFromPath:@"/nonexistent/file.icc" error:&error];
    
    if (profile != nil) {
        NSLog(@"ERROR: Should return nil for nonexistent file");
        [parser release];
        return 1;
    }
    
    if (error == nil) {
        NSLog(@"ERROR: Should set error for nonexistent file");
        [parser release];
        return 1;
    }
    
    [parser release];
    NSLog(@"PASS: Nonexistent file handling");
    return 0;
}

#ifdef HAVE_LCMS
int testParseValidProfile() {
    ICCParser *parser = [[ICCParser alloc] init];
    
    // Create a minimal valid ICC profile using LittleCMS
    #include <lcms2.h>
    
    cmsCIExyY whitePoint;
    cmsWhitePointFromTemp(&whitePoint, 5000); // D50
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
    
    if (!hProfile) {
        NSLog(@"ERROR: Failed to create test profile");
        [parser release];
        return 1;
    }
    
    // Save to memory
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
        NSLog(@"ERROR: Failed to parse valid profile: %@", error);
        [parser release];
        return 1;
    }
    
    // Verify profile has basic properties
    if ([profile profileSize] == 0) {
        NSLog(@"ERROR: Profile size should be > 0");
        [parser release];
        return 1;
    }
    
    if ([profile version] == 0) {
        NSLog(@"ERROR: Profile version should be set");
        [parser release];
        return 1;
    }
    
    // Verify profile has tags
    NSArray *tagSignatures = [profile allTagSignatures];
    if ([tagSignatures count] == 0) {
        NSLog(@"ERROR: Profile should have tags");
        [parser release];
        return 1;
    }
    
    [parser release];
    NSLog(@"PASS: Valid profile parsing");
    return 0;
}

int testParseProfileTags() {
    ICCParser *parser = [[ICCParser alloc] init];
    
    // Create a test profile with known tags
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
    
    // Save to memory
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
        NSLog(@"ERROR: Failed to parse profile");
        [parser release];
        return 1;
    }
    
    // Check for expected tags (rTRC, gTRC, bTRC should exist)
    ICCTag *redTRC = [profile tagWithSignature:@"rTRC"];
    ICCTag *greenTRC = [profile tagWithSignature:@"gTRC"];
    ICCTag *blueTRC = [profile tagWithSignature:@"bTRC"];
    
    if (!redTRC || !greenTRC || !blueTRC) {
        NSLog(@"ERROR: RGB TRC tags should be present");
        [parser release];
        return 1;
    }
    
    // Verify TRC tags are of correct type
    if (![redTRC isKindOfClass:[ICCTagTRC class]]) {
        NSLog(@"ERROR: rTRC should be ICCTagTRC");
        [parser release];
        return 1;
    }
    
    [parser release];
    NSLog(@"PASS: Profile tag parsing");
    return 0;
}
#else
int testParseValidProfile() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}

int testParseProfileTags() {
    NSLog(@"SKIP: LittleCMS not available");
    return 0;
}
#endif

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testParserInitialization();
    failures += testParseInvalidData();
    failures += testParseNonexistentFile();
    failures += testParseValidProfile();
    failures += testParseProfileTags();
    
    if (failures == 0) {
        NSLog(@"All ICC parser tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
