//
//  HistogramAndCurvesPanel.m
//  SmallICCer
//
//  Histogram and Curves Panel implementation
//

#import "HistogramAndCurvesPanel.h"

@implementation HistogramAndCurvesPanel

- (id)init {
    self = [super init];
    if (self) {
        // Initialize curve view
    }
    return self;
}

- (void)dealloc {
    [curveView release];
    [super dealloc];
}

@end
