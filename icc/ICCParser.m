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
#include <wchar.h>
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
        
        ICCTag *tag = [self parseTag:hProfile signature:tagSig stringSignature:tagSignature];
        if (tag) {
            [profile setTag:tag withSignature:tagSignature];
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

- (ICCTag *)parseTag:(cmsHPROFILE)hProfile signature:(cmsTagSignature)tagSig stringSignature:(NSString *)tagSignature {
#ifdef HAVE_LCMS
    // Check for TRC tags (Red, Green, Blue)
    if (tagSig == cmsSigRedTRCTag || tagSig == cmsSigGreenTRCTag || tagSig == cmsSigBlueTRCTag) {
        cmsToneCurve *curve = (cmsToneCurve *)cmsReadTag(hProfile, tagSig);
        if (curve) {
            ICCTagTRC *trcTag = [[ICCTagTRC alloc] initWithData:curve signature:tagSignature];
            [trcTag loadFromToneCurve:curve];
            return [trcTag autorelease];
        }
    }
    
    // Check for colorant tags (XYZ values)
    if (tagSig == cmsSigRedColorantTag || tagSig == cmsSigGreenColorantTag || 
        tagSig == cmsSigBlueColorantTag) {
        cmsCIEXYZ *xyz = (cmsCIEXYZ *)cmsReadTag(hProfile, tagSig);
        if (xyz) {
            // Store as metadata for now - could create a ColorantTag class
            ICCTagMetadata *metaTag = [[ICCTagMetadata alloc] initWithData:xyz signature:tagSignature];
            NSString *xyzString = [NSString stringWithFormat:@"X=%.6f Y=%.6f Z=%.6f", 
                                   xyz->X, xyz->Y, xyz->Z];
            metaTag.textValue = xyzString;
            return [metaTag autorelease];
        }
    }
    
    // Check for text tags (description, copyright, etc.)
    if (tagSig == cmsSigProfileDescriptionTag || tagSig == cmsSigCopyrightTag ||
        tagSig == cmsSigDeviceMfgDescTag || tagSig == cmsSigDeviceModelDescTag) {
        wchar_t *text = (wchar_t *)cmsReadTag(hProfile, tagSig);
        if (text) {
            ICCTagMetadata *metaTag = [[ICCTagMetadata alloc] initWithData:text signature:tagSignature];
            // Convert wide string to NSString
            NSString *nsString = [NSString stringWithCharacters:(const unichar *)text 
                                                          length:wcslen(text)];
            metaTag.textValue = nsString;
            return [metaTag autorelease];
        }
    }
    
    // Check for LUT tags
    if (tagSig == cmsSigAToB0Tag || tagSig == cmsSigAToB1Tag || tagSig == cmsSigAToB2Tag ||
        tagSig == cmsSigBToA0Tag || tagSig == cmsSigBToA1Tag || tagSig == cmsSigBToA2Tag) {
        cmsPipeline *pipeline = (cmsPipeline *)cmsReadTag(hProfile, tagSig);
        if (pipeline) {
            ICCTagLUT *lutTag = [[ICCTagLUT alloc] initWithData:pipeline signature:tagSignature];
            [lutTag loadFromPipeline:pipeline];
            return [lutTag autorelease];
        }
    }
    
    // Generic tag for anything else
    void *tagData = cmsReadTag(hProfile, tagSig);
    if (tagData) {
        return [[[ICCTag alloc] initWithData:tagData signature:tagSignature] autorelease];
    }
    
    return nil;
#else
    return nil;
#endif
}

@end
