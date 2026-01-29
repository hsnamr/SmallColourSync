//
//  test_GamutComparator.m
//  SmallICCer Tests
//
//  Unit tests for GamutComparator (volume, volume difference, overlap).
//

#import <Foundation/Foundation.h>
#import "GamutComparator.h"
#import "Gamut3DModel.h"
#import <math.h>

static NSArray *makeVertices(double minL, double maxL, double minA, double maxA, double minB, double maxB) {
    NSMutableArray *arr = [NSMutableArray array];
    double l, a, b;
    for (l = minL; l <= maxL; l += 10.0) {
        for (a = minA; a <= maxA; a += 10.0) {
            for (b = minB; b <= maxB; b += 10.0) {
                [arr addObject:[NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:l],
                    [NSNumber numberWithDouble:a],
                    [NSNumber numberWithDouble:b],
                    nil]];
            }
        }
    }
    return arr;
}

int testComputeVolume() {
    GamutComparator *comp = [[GamutComparator alloc] init];
    NSArray *verts = makeVertices(0, 50, -50, 50, -50, 50);
    Gamut3DModel *model = [[Gamut3DModel alloc] initWithVertices:verts faces:nil name:@"Test"];
    double vol = [comp computeVolume:model];
    [model release];
    [comp release];
    if (vol <= 0) {
        NSLog(@"ERROR: volume should be positive, got %f", vol);
        return 1;
    }
    if (vol != (50 - 0) * (50 - (-50)) * (50 - (-50))) {
        NSLog(@"ERROR: volume should be bounding box L*50 * a*100 * b*100, got %f", vol);
        return 1;
    }
    NSLog(@"PASS: computeVolume");
    return 0;
}

int testComputeVolumeEmpty() {
    GamutComparator *comp = [[GamutComparator alloc] init];
    Gamut3DModel *model = [[Gamut3DModel alloc] initWithVertices:[NSArray array] faces:nil name:@"Empty"];
    double vol = [comp computeVolume:model];
    [model release];
    [comp release];
    if (vol != 0.0) {
        NSLog(@"ERROR: empty gamut volume should be 0, got %f", vol);
        return 1;
    }
    NSLog(@"PASS: computeVolume (empty)");
    return 0;
}

int testComputeVolumeDifference() {
    GamutComparator *comp = [[GamutComparator alloc] init];
    NSArray *v1 = makeVertices(0, 30, -30, 30, -30, 30);
    NSArray *v2 = makeVertices(0, 60, -60, 60, -60, 60);
    Gamut3DModel *m1 = [[Gamut3DModel alloc] initWithVertices:v1 faces:nil name:@"A"];
    Gamut3DModel *m2 = [[Gamut3DModel alloc] initWithVertices:v2 faces:nil name:@"B"];
    double diff = [comp computeVolumeDifference:m1 and:m2];
    [m1 release];
    [m2 release];
    [comp release];
    if (diff < 0) {
        NSLog(@"ERROR: volume difference should be non-negative, got %f", diff);
        return 1;
    }
    NSLog(@"PASS: computeVolumeDifference");
    return 0;
}

int testFindOverlap() {
    GamutComparator *comp = [[GamutComparator alloc] init];
    NSArray *v1 = makeVertices(10, 20, 0, 10, 0, 10);
    NSArray *v2 = makeVertices(15, 25, 0, 10, 0, 10);
    Gamut3DModel *m1 = [[Gamut3DModel alloc] initWithVertices:v1 faces:nil name:@"A"];
    Gamut3DModel *m2 = [[Gamut3DModel alloc] initWithVertices:v2 faces:nil name:@"B"];
    NSArray *overlap = [comp findOverlap:m1 and:m2];
    [m1 release];
    [m2 release];
    [comp release];
    if (overlap == nil) {
        NSLog(@"ERROR: findOverlap returned nil");
        return 1;
    }
    if (![overlap isKindOfClass:[NSArray class]]) {
        NSLog(@"ERROR: findOverlap should return NSArray");
        return 1;
    }
    NSLog(@"PASS: findOverlap (returns array, count=%lu)", (unsigned long)[overlap count]);
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int failures = 0;
    failures += testComputeVolume();
    failures += testComputeVolumeEmpty();
    failures += testComputeVolumeDifference();
    failures += testFindOverlap();
    if (failures == 0) {
        NSLog(@"All GamutComparator tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    [pool release];
    return failures;
}
