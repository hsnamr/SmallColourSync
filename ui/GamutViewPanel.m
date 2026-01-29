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
#import "SettingsManager.h"

@implementation GamutViewPanel

- (id)init {
    return [self initWithBackendType:[RenderBackendFactory defaultBackendType]];
}

- (id)initWithBackendType:(RenderBackendType)backendType {
    self = [super initWithFrame:NSMakeRect(0, 0, 800, 600)];
    if (self) {
        preferredBackend = backendType;
        
        // For OpenGL, we need NSOpenGLView
        if (backendType == RenderBackendTypeOpenGL) {
            NSOpenGLPixelFormatAttribute attrs[] = {
                NSOpenGLPFADoubleBuffer,
                NSOpenGLPFADepthSize, 24,
                0
            };
            NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
            NSOpenGLView *glView = [[NSOpenGLView alloc] initWithFrame:[self bounds] pixelFormat:pixelFormat];
            [pixelFormat release];
            [glView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [self addSubview:glView];
            [glView release];
        }
        
        renderer = [[Renderer3D alloc] initWithView:self backendType:backendType];
    }
    return self;
}

- (void)setPreferredBackend:(RenderBackendType)backendType {
    preferredBackend = backendType;
    [renderer release];
    renderer = [[Renderer3D alloc] initWithView:self backendType:backendType];
    [renderer applySettings];
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
    
    // Set up Lab space model (grid/axes from settings)
    CIELABSpaceModel *labModel = [[CIELABSpaceModel alloc] init];
    SettingsManager *settings = [SettingsManager sharedManager];
    [settings loadSettings];
    [labModel setShowAxes:[settings showAxes]];
    [labModel setShowGrid:[settings showGrid]];
    [renderer setLabSpaceModel:labModel];
    [labModel release];
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    [renderer setViewportWidth:bounds.size.width height:bounds.size.height];
    [renderer render];
}

- (void)mouseDown:(NSEvent *)event {
    lastMouseLocation = [event locationInWindow];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint currentLocation = [event locationInWindow];
    NSPoint delta = NSMakePoint(currentLocation.x - lastMouseLocation.x,
                                currentLocation.y - lastMouseLocation.y);
    [renderer handleMouseDrag:delta];
    lastMouseLocation = currentLocation;
    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)event {
    float delta = [event deltaY] * 0.1;
    [renderer handleZoom:delta];
    [self setNeedsDisplay:YES];
}

- (void)refreshFromSettings {
    [renderer applySettings];
    if (currentProfile) {
        [self displayProfile:currentProfile]; // Rebuild lab model with current showGrid/showAxes
    }
    [self setNeedsDisplay:YES];
}

- (void)dealloc {
    [renderer release];
    [super dealloc];
}

@end
