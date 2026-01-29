//
//  test_CIELABSpaceModel.m
//  SmallICCer Tests
//
//  Unit tests for CIELAB space model visualization
//

#import <Foundation/Foundation.h>
#import "CIELABSpaceModel.h"

int testCIELABSpaceModelInitialization() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    if (!model) {
        NSLog(@"ERROR: Failed to create CIELABSpaceModel");
        return 1;
    }
    
    // Verify default properties
    if (![model showAxes]) {
        NSLog(@"ERROR: showAxes should default to YES");
        [model release];
        return 1;
    }
    
    if (![model showGrid]) {
        NSLog(@"ERROR: showGrid should default to YES");
        [model release];
        return 1;
    }
    
    [model release];
    NSLog(@"PASS: CIELABSpaceModel initialization");
    return 0;
}

int testGenerateAxes() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    [model generateAxes];
    
    NSArray *axes = [model axisVertices];
    
    if (!axes) {
        NSLog(@"ERROR: Axes should be generated");
        [model release];
        return 1;
    }
    
    if ([axes count] == 0) {
        NSLog(@"ERROR: Axes should have vertices");
        [model release];
        return 1;
    }
    
    // Verify axes have 3 coordinates (Lab)
    NSArray *firstAxis = [axes objectAtIndex:0];
    if ([firstAxis count] != 3) {
        NSLog(@"ERROR: Axis vertices should have 3 coordinates (Lab)");
        [model release];
        return 1;
    }
    
    [model release];
    NSLog(@"PASS: Axes generation");
    return 0;
}

int testGenerateGrid() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    [model generateGrid];
    
    NSArray *grid = [model gridVertices];
    
    if (!grid) {
        NSLog(@"ERROR: Grid should be generated");
        [model release];
        return 1;
    }
    
    // Grid may be empty, that's OK
    if ([grid count] > 0) {
        // Verify grid vertices have 3 coordinates
        NSArray *firstVertex = [grid objectAtIndex:0];
        if ([firstVertex count] != 3) {
            NSLog(@"ERROR: Grid vertices should have 3 coordinates (Lab)");
            [model release];
            return 1;
        }
    }
    
    [model release];
    NSLog(@"PASS: Grid generation");
    return 0;
}

int testLabSpaceBounds() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    [model generateAxes];
    [model generateGrid];
    
    NSArray *axes = [model axisVertices];
    
    if ([axes count] == 0) {
        NSLog(@"ERROR: Should have axes");
        [model release];
        return 1;
    }
    
    // Check that L* values are in valid range (0-100)
    for (NSArray *vertex in axes) {
        if ([vertex count] >= 1) {
            NSNumber *lValue = [vertex objectAtIndex:0];
            double l = [lValue doubleValue];
            if (l < -10.0 || l > 110.0) { // Allow some margin
                NSLog(@"ERROR: L* value out of reasonable range: %f", l);
                [model release];
                return 1;
            }
        }
    }
    
    [model release];
    NSLog(@"PASS: Lab space bounds validation");
    return 0;
}

int testShowAxesProperty() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    [model setShowAxes:NO];
    if ([model showAxes]) {
        NSLog(@"ERROR: showAxes should be NO");
        [model release];
        return 1;
    }
    
    [model setShowAxes:YES];
    if (![model showAxes]) {
        NSLog(@"ERROR: showAxes should be YES");
        [model release];
        return 1;
    }
    
    [model release];
    NSLog(@"PASS: showAxes property");
    return 0;
}

int testShowGridProperty() {
    CIELABSpaceModel *model = [[CIELABSpaceModel alloc] init];
    
    [model setShowGrid:NO];
    if ([model showGrid]) {
        NSLog(@"ERROR: showGrid should be NO");
        [model release];
        return 1;
    }
    
    [model setShowGrid:YES];
    if (![model showGrid]) {
        NSLog(@"ERROR: showGrid should be YES");
        [model release];
        return 1;
    }
    
    [model release];
    NSLog(@"PASS: showGrid property");
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testCIELABSpaceModelInitialization();
    failures += testGenerateAxes();
    failures += testGenerateGrid();
    failures += testLabSpaceBounds();
    failures += testShowAxesProperty();
    failures += testShowGridProperty();
    
    if (failures == 0) {
        NSLog(@"All CIELAB space model tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
