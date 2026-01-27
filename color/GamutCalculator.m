//
//  GamutCalculator.m
//  SmallICCer
//
//  Gamut Calculator implementation
//

#import "GamutCalculator.h"
#import "ICCProfile.h"
#import "ColorSpace.h"
#import "ColorConverter.h"
#import "StandardColorSpaces.h"

@implementation GamutCalculator

- (NSArray *)computeGamutForProfile:(ICCProfile *)profile {
    // Sample RGB space and convert through profile to Lab
    // This is a simplified implementation - a full version would
    // use the profile's actual transform (LUTs, matrices, etc.)
    
    NSMutableArray *labPoints = [NSMutableArray array];
    NSUInteger resolution = 17; // Sample 17^3 points
    
    NSUInteger r, g, b;
    for (r = 0; r < resolution; r++) {
        for (g = 0; g < resolution; g++) {
            for (b = 0; b < resolution; b++) {
                double rgb[3] = {
                    (double)r / (resolution - 1),
                    (double)g / (resolution - 1),
                    (double)b / (resolution - 1)
                };
                
                // Convert RGB to XYZ (simplified - would use profile transform)
                double xyz[3];
                [ColorConverter rgbToXyz:rgb xyz:xyz 
                              primaries:nil whitePoint:nil];
                
                // Convert XYZ to Lab
                double whitePoint[3] = {0.9642, 1.0, 0.8249}; // D50
                double lab[3];
                [ColorConverter xyzToLab:xyz lab:lab whitePoint:whitePoint];
                
                // Store as NSArray
                NSArray *point = [NSArray arrayWithObjects:
                                 [NSNumber numberWithDouble:lab[0]],
                                 [NSNumber numberWithDouble:lab[1]],
                                 [NSNumber numberWithDouble:lab[2]],
                                 nil];
                [labPoints addObject:point];
            }
        }
    }
    
    return labPoints;
}

- (NSArray *)computeGamutForColorSpace:(ColorSpace *)colorSpace {
    NSMutableArray *labPoints = [NSMutableArray array];
    NSUInteger resolution = 17;
    
    NSUInteger r, g, b;
    for (r = 0; r < resolution; r++) {
        for (g = 0; g < resolution; g++) {
            for (b = 0; b < resolution; b++) {
                double rgb[3] = {
                    (double)r / (resolution - 1),
                    (double)g / (resolution - 1),
                    (double)b / (resolution - 1)
                };
                
                // Convert using color space primaries
                double xyz[3];
                [ColorConverter rgbToXyz:rgb xyz:xyz 
                              primaries:[colorSpace primaries] 
                             whitePoint:[colorSpace whitePoint]];
                
                // Convert to Lab
                NSArray *wp = [colorSpace whitePoint];
                // Convert xy to XYZ white point (simplified)
                double whitePoint[3] = {0.9642, 1.0, 0.8249}; // D50 approximation
                double lab[3];
                [ColorConverter xyzToLab:xyz lab:lab whitePoint:whitePoint];
                
                NSArray *point = [NSArray arrayWithObjects:
                                 [NSNumber numberWithDouble:lab[0]],
                                 [NSNumber numberWithDouble:lab[1]],
                                 [NSNumber numberWithDouble:lab[2]],
                                 nil];
                [labPoints addObject:point];
            }
        }
    }
    
    return labPoints;
}

- (NSArray *)sampleRGBSpaceWithResolution:(NSUInteger)resolution {
    NSMutableArray *points = [NSMutableArray array];
    
    NSUInteger r, g, b;
    for (r = 0; r < resolution; r++) {
        for (g = 0; g < resolution; g++) {
            for (b = 0; b < resolution; b++) {
                NSArray *point = [NSArray arrayWithObjects:
                                 [NSNumber numberWithDouble:(double)r / (resolution - 1)],
                                 [NSNumber numberWithDouble:(double)g / (resolution - 1)],
                                 [NSNumber numberWithDouble:(double)b / (resolution - 1)],
                                 nil];
                [points addObject:point];
            }
        }
    }
    
    return points;
}

@end
