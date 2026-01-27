//
//  ICCTagTRC.m
//  SmallICCer
//
//  TRC Tag implementation
//

#import "ICCTagTRC.h"

#ifdef HAVE_LCMS
#include <lcms2.h>
#endif

@implementation ICCTagTRC

@synthesize curvePoints;
@synthesize curveType;

- (id)initWithData:(void *)data signature:(NSString *)sig {
    self = [super initWithData:data signature:sig];
    if (self) {
        curvePoints = [[NSArray alloc] init];
        curveType = 1; // Default to table
    }
    return self;
}

- (double)valueAtPosition:(double)position {
    if (position < 0.0) position = 0.0;
    if (position > 1.0) position = 1.0;
    
    if ([curvePoints count] == 0) {
        return position; // Linear default
    }
    
    if (curveType == 1) {
        // Table-based interpolation
        NSUInteger count = [curvePoints count];
        double index = position * (count - 1);
        NSUInteger lowerIndex = (NSUInteger)floor(index);
        NSUInteger upperIndex = (NSUInteger)ceil(index);
        
        if (lowerIndex == upperIndex) {
            return [[curvePoints objectAtIndex:lowerIndex] doubleValue];
        }
        
        double lowerValue = [[curvePoints objectAtIndex:lowerIndex] doubleValue];
        double upperValue = [[curvePoints objectAtIndex:upperIndex] doubleValue];
        double t = index - lowerIndex;
        
        return lowerValue + t * (upperValue - lowerValue);
    } else {
        // Parametric curve (simplified - would need full parametric formula)
        return position;
    }
}

- (void)loadFromToneCurve:(void *)toneCurve {
#ifdef HAVE_LCMS
    cmsToneCurve *curve = (cmsToneCurve *)toneCurve;
    if (!curve) return;
    
    // Sample the curve at regular intervals
    NSMutableArray *points = [NSMutableArray array];
    NSUInteger sampleCount = 256; // Sample 256 points
    NSUInteger i;
    
    for (i = 0; i < sampleCount; i++) {
        double input = (double)i / (sampleCount - 1);
        cmsFloat32Number output = cmsEvalToneCurveFloat(curve, input);
        [points addObject:[NSNumber numberWithDouble:output]];
    }
    
    [curvePoints release];
    curvePoints = [points retain];
    curveType = 1; // Table-based
#endif
}

- (void)dealloc {
    [curvePoints release];
    [super dealloc];
}

@end
