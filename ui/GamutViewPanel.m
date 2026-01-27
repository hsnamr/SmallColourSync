//
//  GamutViewPanel.m
//  SmallICCer
//
//  Gamut View Panel implementation
//

#import "GamutViewPanel.h"
#import "ICCProfile.h"
#import "Renderer3D.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import "GamutCalculator.h"

@implementation GamutViewPanel

- (id)init {
    NSOpenGLPixelFormatAttribute attrs[] = {
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 24,
        0
    };
    NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    self = [super initWithFrame:NSMakeRect(0, 0, 800, 600) pixelFormat:pixelFormat];
    [pixelFormat release];
    
    if (self) {
        renderer = [[Renderer3D alloc] initWithView:self];
    }
    return self;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = profile;
    
    // Compute gamut
    GamutCalculator *calculator = [[GamutCalculator alloc] init];
    NSArray *gamutPoints = [calculator computeGamutForProfile:profile];
    [calculator release];
    
    // Create gamut model
    Gamut3DModel *gamutModel = [[Gamut3DModel alloc] initWithVertices:gamutPoints 
                                                                 faces:nil 
                                                                  name:[NSString stringWithFormat:@"Profile Gamut"]];
    [gamutModel setColorRed:1.0 green:0.0 blue:0.0];
    
    [renderer addGamutModel:gamutModel];
    [gamutModel release];
    
    // Set up Lab space model
    CIELABSpaceModel *labModel = [[CIELABSpaceModel alloc] init];
    [renderer setLabSpaceModel:labModel];
    [labModel release];
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [renderer render];
}

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

@end
