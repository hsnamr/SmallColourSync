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
#import "ICCTagMatrix.h"
#import "ICCTagLUT.h"
#import "ICCTagMetadata.h"

#ifdef HAVE_LCMS
#include <lcms2.h>
#include <wchar.h>
#endif

@implementation ICCWriter

- (BOOL)writeProfile:(ICCProfile *)profile toPath:(NSString *)path error:(NSError **)error {
#ifdef HAVE_LCMS
    // Get primaries and white point from profile or use defaults
    cmsCIExyY whitePoint;
    cmsCIExyYTRIPLE primaries;
    
    // Try to get white point from profile
    if ([profile pcsIlluminant] && [[profile pcsIlluminant] count] >= 3) {
        NSArray *illuminant = [profile pcsIlluminant];
        // Convert XYZ to xyY (simplified - would need proper conversion)
        whitePoint.x = 0.3457; // Default D50
        whitePoint.y = 0.3585;
        whitePoint.Y = 1.0;
    } else {
        cmsWhitePointFromTemp(&whitePoint, 5000); // D50
        whitePoint.x = 0.3457;
        whitePoint.y = 0.3585;
        whitePoint.Y = 1.0;
    }
    
    // Try to get primaries from colorant tags
    ICCTag *redColorant = [profile tagWithSignature:@"rXYZ"];
    ICCTag *greenColorant = [profile tagWithSignature:@"gXYZ"];
    ICCTag *blueColorant = [profile tagWithSignature:@"bXYZ"];
    
    // Default sRGB primaries
    primaries.Red.x = 0.6400;
    primaries.Red.y = 0.3300;
    primaries.Red.Y = 1.0;
    primaries.Green.x = 0.3000;
    primaries.Green.y = 0.6000;
    primaries.Green.Y = 1.0;
    primaries.Blue.x = 0.1500;
    primaries.Blue.y = 0.0600;
    primaries.Blue.Y = 1.0;
    
    // Get TRC curves from profile
    ICCTag *redTRC = [profile tagWithSignature:@"rTRC"];
    ICCTag *greenTRC = [profile tagWithSignature:@"gTRC"];
    ICCTag *blueTRC = [profile tagWithSignature:@"bTRC"];
    
    cmsToneCurve *curves[3] = {NULL, NULL, NULL};
    cmsToneCurve *defaultGamma = cmsBuildGamma(NULL, 2.2);
    
    // Convert ICCTagTRC to cmsToneCurve
    BOOL needFreeCurves[3] = {NO, NO, NO};
    
    if ([redTRC isKindOfClass:[ICCTagTRC class]]) {
        curves[0] = [self toneCurveFromICCTagTRC:(ICCTagTRC *)redTRC];
        if (curves[0]) needFreeCurves[0] = YES;
    }
    if (!curves[0]) {
        curves[0] = defaultGamma;
        needFreeCurves[0] = NO; // Don't free defaultGamma yet
    }
    
    if ([greenTRC isKindOfClass:[ICCTagTRC class]]) {
        curves[1] = [self toneCurveFromICCTagTRC:(ICCTagTRC *)greenTRC];
        if (curves[1]) needFreeCurves[1] = YES;
    }
    if (!curves[1]) {
        curves[1] = defaultGamma;
        needFreeCurves[1] = NO;
    }
    
    if ([blueTRC isKindOfClass:[ICCTagTRC class]]) {
        curves[2] = [self toneCurveFromICCTagTRC:(ICCTagTRC *)blueTRC];
        if (curves[2]) needFreeCurves[2] = YES;
    }
    if (!curves[2]) {
        curves[2] = defaultGamma;
        needFreeCurves[2] = NO;
    }
    
    // Create profile (makes copies of curves)
    cmsHPROFILE hProfile = cmsCreateRGBProfileTHR(NULL, &whitePoint, &primaries, curves);
    
    // Free curves we created (cmsCreateRGBProfileTHR makes copies)
    if (needFreeCurves[0] && curves[0]) cmsFreeToneCurve(curves[0]);
    if (needFreeCurves[1] && curves[1]) cmsFreeToneCurve(curves[1]);
    if (needFreeCurves[2] && curves[2]) cmsFreeToneCurve(curves[2]);
    cmsFreeToneCurve(defaultGamma);
    
    if (!hProfile) {
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"Failed to create profile", NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    // Write all tags from profile
    NSArray *tagSignatures = [profile allTagSignatures];
    for (NSString *signature in tagSignatures) {
        ICCTag *tag = [profile tagWithSignature:signature];
        if (!tag) continue;
        
        // Skip TRC tags as they're already in the profile
        if ([signature isEqualToString:@"rTRC"] || 
            [signature isEqualToString:@"gTRC"] || 
            [signature isEqualToString:@"bTRC"]) {
            continue;
        }
        
        // Convert signature string to cmsTagSignature
        cmsTagSignature tagSig = [self tagSignatureFromString:signature];
        
        // Write tag based on type
        if ([tag isKindOfClass:[ICCTagTRC class]]) {
            cmsToneCurve *curve = [self toneCurveFromICCTagTRC:(ICCTagTRC *)tag];
            if (curve) {
                cmsWriteTag(hProfile, tagSig, curve);
                cmsFreeToneCurve(curve);
            }
        } else if ([tag isKindOfClass:[ICCTagMatrix class]]) {
            // Matrix tags are typically part of the profile structure, not separate tags
            // But we can write them if needed
        } else if ([tag isKindOfClass:[ICCTagLUT class]]) {
            ICCTagLUT *lutTag = (ICCTagLUT *)tag;
            // LUT tags need pipeline - would need to reconstruct from LUT data
            // For now, skip (complex implementation needed)
        } else if ([tag isKindOfClass:[ICCTagMetadata class]]) {
            ICCTagMetadata *metaTag = (ICCTagMetadata *)tag;
            NSString *text = [metaTag textValue];
            if (text) {
                // Convert NSString to wide string
                NSUInteger length = [text length];
                wchar_t *wtext = (wchar_t *)malloc((length + 1) * sizeof(wchar_t));
                if (wtext) {
                    [text getCharacters:(unichar *)wtext range:NSMakeRange(0, length)];
                    wtext[length] = 0;
                    cmsWriteTag(hProfile, tagSig, wtext);
                    free(wtext);
                }
            }
        }
    }
    
    // Set profile description if available
    ICCTag *descTag = [profile tagWithSignature:@"desc"];
    if (descTag && [descTag isKindOfClass:[ICCTagMetadata class]]) {
        NSString *desc = [(ICCTagMetadata *)descTag textValue];
        if (desc) {
            NSUInteger length = [desc length];
            wchar_t *wdesc = (wchar_t *)malloc((length + 1) * sizeof(wchar_t));
            if (wdesc) {
                [desc getCharacters:(unichar *)wdesc range:NSMakeRange(0, length)];
                wdesc[length] = 0;
                cmsWriteTag(hProfile, cmsSigProfileDescriptionTag, wdesc);
                free(wdesc);
            }
        }
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

#ifdef HAVE_LCMS
- (cmsToneCurve *)toneCurveFromICCTagTRC:(ICCTagTRC *)trcTag {
    NSArray *points = [trcTag curvePoints];
    if (!points || [points count] == 0) {
        return cmsBuildGamma(NULL, 2.2); // Default gamma
    }
    
    NSUInteger count = [points count];
    cmsFloat32Number *table = (cmsFloat32Number *)malloc(count * sizeof(cmsFloat32Number));
    if (!table) {
        return cmsBuildGamma(NULL, 2.2);
    }
    
    NSUInteger i;
    for (i = 0; i < count; i++) {
        table[i] = (cmsFloat32Number)[[points objectAtIndex:i] doubleValue];
    }
    
    cmsToneCurve *curve = cmsBuildTabulatedToneCurve16(NULL, count, table);
    free(table);
    
    return curve ? curve : cmsBuildGamma(NULL, 2.2);
}

- (cmsTagSignature)tagSignatureFromString:(NSString *)signature {
    if ([signature length] != 4) {
        return 0;
    }
    
    const char *chars = [signature UTF8String];
    cmsTagSignature sig = 0;
    sig |= ((cmsUInt32Number)chars[0]) << 24;
    sig |= ((cmsUInt32Number)chars[1]) << 16;
    sig |= ((cmsUInt32Number)chars[2]) << 8;
    sig |= ((cmsUInt32Number)chars[3]);
    
    return sig;
}
#endif

@end
