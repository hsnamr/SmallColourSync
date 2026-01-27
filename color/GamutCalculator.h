//
//  GamutCalculator.h
//  SmallICCer
//
//  Computes gamut hull (convex hull or mesh) for color spaces
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class ColorSpace;

@interface GamutCalculator : NSObject

// Compute gamut boundary points in Lab space
- (NSArray *)computeGamutForProfile:(ICCProfile *)profile;
- (NSArray *)computeGamutForColorSpace:(ColorSpace *)colorSpace;

// Generate sample points in RGB space and convert to Lab
- (NSArray *)sampleRGBSpaceWithResolution:(NSUInteger)resolution;

@end

NS_ASSUME_NONNULL_END
