//
//  GamutComparator.m
//  SmallICCer
//
//  Gamut Comparator implementation
//

#import "GamutComparator.h"
#import "Gamut3DModel.h"
#import <math.h>

@implementation GamutComparator

- (double)computeVolume:(Gamut3DModel *)gamut {
    // Simplified volume calculation - a full implementation would
    // compute the convex hull and calculate its volume
    NSArray *vertices = [gamut vertices];
    if ([vertices count] == 0) return 0.0;
    
    // Placeholder: return approximate volume based on bounding box
    double minL = 100.0, maxL = 0.0;
    double minA = 128.0, maxA = -128.0;
    double minB = 128.0, maxB = -128.0;
    
    for (NSArray *point in vertices) {
        if ([point count] >= 3) {
            double l = [[point objectAtIndex:0] doubleValue];
            double a = [[point objectAtIndex:1] doubleValue];
            double b = [[point objectAtIndex:2] doubleValue];
            
            if (l < minL) minL = l;
            if (l > maxL) maxL = l;
            if (a < minA) minA = a;
            if (a > maxA) maxA = a;
            if (b < minB) minB = b;
            if (b > maxB) maxB = b;
        }
    }
    
    return (maxL - minL) * (maxA - minA) * (maxB - minB);
}

- (double)computeVolumeDifference:(Gamut3DModel *)gamut1 and:(Gamut3DModel *)gamut2 {
    double vol1 = [self computeVolume:gamut1];
    double vol2 = [self computeVolume:gamut2];
    return fabs(vol1 - vol2);
}

- (NSArray *)findOverlap:(Gamut3DModel *)gamut1 and:(Gamut3DModel *)gamut2 {
    // Simplified overlap detection - would need proper intersection calculation
    NSMutableArray *overlap = [NSMutableArray array];
    
    NSArray *vertices1 = [gamut1 vertices];
    NSArray *vertices2 = [gamut2 vertices];
    
    // Find points that are in both gamuts (simplified)
    for (NSArray *point1 in vertices1) {
        for (NSArray *point2 in vertices2) {
            if ([point1 count] >= 3 && [point2 count] >= 3) {
                double dist = sqrt(
                    pow([[point1 objectAtIndex:0] doubleValue] - [[point2 objectAtIndex:0] doubleValue], 2) +
                    pow([[point1 objectAtIndex:1] doubleValue] - [[point2 objectAtIndex:1] doubleValue], 2) +
                    pow([[point1 objectAtIndex:2] doubleValue] - [[point2 objectAtIndex:2] doubleValue], 2)
                );
                if (dist < 1.0) { // Threshold
                    [overlap addObject:point1];
                    break;
                }
            }
        }
    }
    
    return overlap;
}

@end
