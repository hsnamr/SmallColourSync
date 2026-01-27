//
//  ICCParser.m
//  SmallICCer
//
//  ICC Parser implementation using LittleCMS
//

#import "ICCParser.h"
#import "ICCProfile.h"
#import "ICCTag.h"
#import "ICCTagTRC.h"
#import "ICCTagMatrix.h"
#import "ICCTagLUT.h"
#import "ICCTagMetadata.h"

#ifdef HAVE_LCMS
#include <lcms2.h>
#endif

@implementation ICCParser

- (ICCProfile *)parseProfileFromPath:(NSString *)path error:(NSError **)error {
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to read file", NSLocalizedDescriptionKey, nil]];
        }
        return nil;
    }
    return [self parseProfileFromData:data error:error];
}

- (ICCProfile *)parseProfileFromData:(NSData *)data error:(NSError **)error {
#ifdef HAVE_LCMS
    const void *profileData = [data bytes];
    NSUInteger profileSize = [data length];
    
    cmsHPROFILE hProfile = cmsOpenProfileFromMem(profileData, profileSize);
    if (!hProfile) {
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:2 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to parse ICC profile", NSLocalizedDescriptionKey, nil]];
        }
        return nil;
    }
    
    ICCProfile *profile = [[ICCProfile alloc] init];
    
    // Parse header
    cmsUInt32Number size = (cmsUInt32Number)profileSize;
    profile.profileSize = size;
    
    // Get version
    cmsUInt32Number version = cmsGetProfileVersion(hProfile);
    profile.version = version;
    
    // Get device class
    cmsProfileClassSignature deviceClass = cmsGetDeviceClass(hProfile);
    profile.deviceClass = deviceClass;
    
    // Get color spaces
    cmsColorSpaceSignature dataColorSpace = cmsGetColorSpace(hProfile);
    profile.dataColorSpace = dataColorSpace;
    
    cmsColorSpaceSignature pcsColorSpace = cmsGetPCS(hProfile);
    profile.pcsColorSpace = pcsColorSpace;
    
    // Get creation date (simplified - would need proper date parsing)
    profile.creationDate = [NSDate date]; // Placeholder
    
    // Get rendering intent
    cmsUInt32Number renderingIntent = cmsGetHeaderRenderingIntent(hProfile);
    profile.renderingIntent = renderingIntent;
    
    // Get PCS illuminant
    cmsCIEXYZ *pcsIlluminant = (cmsCIEXYZ *)cmsReadTag(hProfile, cmsSigMediaWhitePointTag);
    if (pcsIlluminant) {
        profile.pcsIlluminant = [NSArray arrayWithObjects:
                                 [NSNumber numberWithDouble:pcsIlluminant->X],
                                 [NSNumber numberWithDouble:pcsIlluminant->Y],
                                 [NSNumber numberWithDouble:pcsIlluminant->Z],
                                 nil];
    }
    
    // Parse tags
    cmsUInt32Number tagCount = cmsGetTagCount(hProfile);
    cmsUInt32Number i;
    for (i = 0; i < tagCount; i++) {
        cmsTagSignature tagSig = cmsGetTagSignature(hProfile, i);
        NSString *tagSignature = [NSString stringWithFormat:@"%c%c%c%c",
                                  (char)((tagSig >> 24) & 0xFF),
                                  (char)((tagSig >> 16) & 0xFF),
                                  (char)((tagSig >> 8) & 0xFF),
                                  (char)(tagSig & 0xFF)];
        
        // Simplified tag parsing - would need proper tag type detection
        void *tagData = cmsReadTag(hProfile, tagSig);
        
        if (tagData) {
            // Create generic tag for now - would parse specific types properly
            ICCTag *tag = [[[ICCTag alloc] initWithData:tagData signature:tagSignature] autorelease];
            if (tag) {
                [profile setTag:tag withSignature:tagSignature];
            }
        }
    }
    
    cmsCloseProfile(hProfile);
    return [profile autorelease];
#else
    if (error) {
        *error = [NSError errorWithDomain:@"SmallICCer" 
                                     code:3 
                                 userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                           @"LittleCMS not available", NSLocalizedDescriptionKey, nil]];
    }
    return nil;
#endif
}

// Simplified tag parsing - would implement proper tag type detection in full version
// For now, create generic tags

@end
