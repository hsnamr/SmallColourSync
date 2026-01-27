//
//  CIELABSpaceModel.m
//  SmallICCer
//
//  CIELAB Space Model implementation
//

#import "CIELABSpaceModel.h"

@implementation CIELABSpaceModel

@synthesize axisVertices;
@synthesize gridVertices;
@synthesize showAxes;
@synthesize showGrid;

- (id)init {
    self = [super init];
    if (self) {
        showAxes = YES;
        showGrid = YES;
        [self generateAxes];
        [self generateGrid];
    }
    return self;
}

- (void)generateAxes {
    NSMutableArray *axes = [NSMutableArray array];
    
    // L* axis (0 to 100)
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.0],
                     [NSNumber numberWithDouble:0.0],
                     [NSNumber numberWithDouble:0.0],
                     nil]];
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:100.0],
                     [NSNumber numberWithDouble:0.0],
                     [NSNumber numberWithDouble:0.0],
                     nil]];
    
    // a* axis (-128 to 127)
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:50.0],
                     [NSNumber numberWithDouble:-128.0],
                     [NSNumber numberWithDouble:0.0],
                     nil]];
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:50.0],
                     [NSNumber numberWithDouble:127.0],
                     [NSNumber numberWithDouble:0.0],
                     nil]];
    
    // b* axis (-128 to 127)
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:50.0],
                     [NSNumber numberWithDouble:0.0],
                     [NSNumber numberWithDouble:-128.0],
                     nil]];
    [axes addObject:[NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:50.0],
                     [NSNumber numberWithDouble:0.0],
                     [NSNumber numberWithDouble:127.0],
                     nil]];
    
    axisVertices = [axes retain];
}

- (void)generateGrid {
    NSMutableArray *grid = [NSMutableArray array];
    
    // Generate grid lines in L*a*b* space
    // Simplified - would generate more comprehensive grid in full implementation
    
    // L* = 0, 25, 50, 75, 100 planes
    int l, a, b;
    for (l = 0; l <= 100; l += 25) {
        // Generate grid points in a*b* plane
        for (a = -128; a <= 127; a += 32) {
            for (b = -128; b <= 127; b += 32) {
                [grid addObject:[NSArray arrayWithObjects:
                                 [NSNumber numberWithInt:l],
                                 [NSNumber numberWithInt:a],
                                 [NSNumber numberWithInt:b],
                                 nil]];
            }
        }
    }
    
    gridVertices = [grid retain];
}

- (void)dealloc {
    [axisVertices release];
    [gridVertices release];
    [super dealloc];
}

@end
