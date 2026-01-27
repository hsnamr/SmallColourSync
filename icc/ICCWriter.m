//
//  ICCWriter.m
//  SmallICCer
//
//  ICC Writer implementation using LittleCMS
//

#import "ICCWriter.h"
#import "ICCProfile.h"
#import "ICCTag.h"
#import "ICCTagTRC.h"

#ifdef HAVE_LCMS
#include <lcms2.h>
#endif

@implementation ICCWriter

- (BOOL)writeProfile:(ICCProfile *)profile toPath:(NSString *)path error:(NSError **)error {
#ifdef HAVE_LCMS
    // Create a basic RGB profile based on the profile's data
    // This is a simplified implementation - a full version would properly
    // reconstruct all tags from the ICCProfile object
    
    // Get primaries from colorant tags or use defaults
    cmsCIExyY whitePoint;
    cmsWhitePointFromTemp(&whitePoint, 5000); // D50 approximation
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
    
    // Try to get TRC curves from profile
    ICCTag *redTRC = [profile tagWithSignature:@"rTRC"];
    ICCTag *greenTRC = [profile tagWithSignature:@"gTRC"];
    ICCTag *blueTRC = [profile tagWithSignature:@"bTRC"];
    
    cmsToneCurve *gamma = cmsBuildGamma(NULL, 2.2); // Default gamma
    cmsToneCurve *curves[3] = {gamma, gamma, gamma};
    
    // If we have TRC tags, try to use them (simplified - would need proper conversion)
    if ([redTRC isKindOfClass:[ICCTagTRC class]]) {
        // Would convert ICCTagTRC to cmsToneCurve here
        // For now, use default
    }
    
    // Create profile
    cmsHPROFILE hProfile = cmsCreateRGBProfileTHR(NULL, &whitePoint, &primaries, curves);
    
    cmsFreeToneCurve(gamma);
    
    if (!hProfile) {
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to create profile", NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    // Set profile metadata if available
    ICCTag *descTag = [profile tagWithSignature:@"desc"];
    if (descTag && [descTag isKindOfClass:NSClassFromString(@"ICCTagMetadata")]) {
        // Would set description here
    }
    
    // Save to memory first
    cmsUInt32Number size = 0;
    cmsSaveProfileToMem(hProfile, NULL, &size);
    
    if (size == 0) {
        cmsCloseProfile(hProfile);
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:2 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to determine profile size", NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    void *buffer = malloc(size);
    if (!buffer) {
        cmsCloseProfile(hProfile);
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:3 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to allocate memory", NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    cmsSaveProfileToMem(hProfile, buffer, &size);
    cmsCloseProfile(hProfile);
    
    // Write to file
    NSData *data = [NSData dataWithBytes:buffer length:size];
    BOOL success = [data writeToFile:path atomically:YES];
    
    free(buffer);
    
    if (!success && error) {
        *error = [NSError errorWithDomain:@"SmallICCer" 
                                     code:4 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"Failed to write file", NSLocalizedDescriptionKey, nil]];
    }
    return success;
#else
    if (error) {
        *error = [NSError errorWithDomain:@"SmallICCer" 
                                     code:5 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"LittleCMS not available", NSLocalizedDescriptionKey, nil]];
    }
    return NO;
#endif
}

@end
