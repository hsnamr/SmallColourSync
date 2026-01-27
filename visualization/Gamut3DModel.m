//
//  Gamut3DModel.m
//  SmallICCer
//
//  Gamut 3D Model implementation
//

#import "Gamut3DModel.h"

@implementation Gamut3DModel

@synthesize vertices;
@synthesize faces;
@synthesize name;

- (id)initWithVertices:(NSArray *)verts faces:(NSArray *)fs name:(NSString *)n {
    self = [super init];
    if (self) {
        vertices = [verts retain];
        faces = [fs retain];
        name = [n retain];
        color[0] = 1.0;
        color[1] = 0.0;
        color[2] = 0.0; // Default red
    }
    return self;
}

- (float *)color {
    return color;
}

- (void)setColorRed:(float)r green:(float)g blue:(float)b {
    color[0] = r;
    color[1] = g;
    color[2] = b;
}

- (void)dealloc {
    [vertices release];
    [faces release];
    [name release];
    [super dealloc];
}

@end
