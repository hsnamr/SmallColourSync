//
//  ICCTagLUT.m
//  SmallICCer
//
//  LUT Tag implementation
//

#import "ICCTagLUT.h"

@implementation ICCTagLUT

@synthesize inputChannels;
@synthesize outputChannels;
@synthesize gridPoints;
@synthesize lutData;

- (id)initWithData:(void *)data signature:(NSString *)sig {
    self = [super initWithData:data signature:sig];
    if (self) {
        inputChannels = 3;
        outputChannels = 3;
        gridPoints = 17; // Common default
        lutData = [[NSData alloc] init];
    }
    return self;
}

- (void)lookupInput:(const double *)input output:(double *)output {
    // Simplified LUT lookup - would need proper trilinear interpolation
    // for a full implementation
    NSUInteger i;
    for (i = 0; i < outputChannels; i++) {
        output[i] = input[i % inputChannels]; // Pass-through for now
    }
}

- (void)dealloc {
    [lutData release];
    [super dealloc];
}

@end
