//
//  OpenGLBackend.m
//  SmallICCer
//
//  OpenGL backend implementation
//

#import "OpenGLBackend.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import <math.h>

#if defined(__APPLE__) && !defined(__GNUSTEP__)
#import <OpenGL/gl.h>
#import <OpenGL/glu.h>
#define HAVE_OPENGL 1
#elif defined(__GNUSTEP__) || defined(__linux__)
#include <GL/gl.h>
#include <GL/glu.h>
#define HAVE_OPENGL 1
#endif

@implementation OpenGLBackend

- (id)init {
    self = [super init];
    if (self) {
        gamutModels = [[NSMutableArray alloc] init];
        rotationX = 0.0;
        rotationY = 0.0;
        zoom = 1.0;
        viewportWidth = 800.0;
        viewportHeight = 600.0;
    }
    return self;
}

- (BOOL)initializeWithView:(NSView *)view {
#if HAVE_OPENGL
    if ([view isKindOfClass:NSClassFromString(@"NSOpenGLView")]) {
        glContext = [(NSOpenGLView *)view openGLContext];
        [glContext retain];
        return YES;
    }
#endif
    return NO;
}

- (void)shutdown {
    [gamutModels removeAllObjects];
    [glContext release];
    glContext = nil;
}

- (void)render {
#if HAVE_OPENGL
    if (!glContext) return;
    
    [glContext makeCurrentContext];
    
    float aspect = viewportWidth / viewportHeight;
    
    glClearColor(0.1, 0.1, 0.1, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    gluPerspective(45.0, aspect, 0.1, 1000.0);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // Calculate camera position
    float camDist = 200.0 / zoom;
    float radX = rotationX * M_PI / 180.0;
    float radY = rotationY * M_PI / 180.0;
    
    float camX = camDist * sin(radY) * cos(radX);
    float camY = camDist * sin(radX);
    float camZ = camDist * cos(radY) * cos(radX);
    
    gluLookAt(camX, camY, camZ, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
    
    // Render Lab space axes and grid
    if (labSpaceModel) {
        if ([labSpaceModel showAxes]) {
            [self renderAxes:[labSpaceModel axisVertices]];
        }
        if ([labSpaceModel showGrid]) {
            [self renderGrid:[labSpaceModel gridVertices]];
        }
    }
    
    // Render gamut models
    for (Gamut3DModel *model in gamutModels) {
        [self renderGamutModel:model];
    }
    
    [glContext flushBuffer];
#endif
}

- (void)renderAxes:(NSArray *)axes {
#if HAVE_OPENGL
    glBegin(GL_LINES);
    glColor3f(1.0, 1.0, 1.0);
    for (NSArray *point in axes) {
        if ([point count] >= 3) {
            glVertex3f([[point objectAtIndex:0] floatValue],
                       [[point objectAtIndex:1] floatValue],
                       [[point objectAtIndex:2] floatValue]);
        }
    }
    glEnd();
#endif
}

- (void)renderGrid:(NSArray *)grid {
#if HAVE_OPENGL
    glBegin(GL_POINTS);
    glColor3f(0.5, 0.5, 0.5);
    for (NSArray *point in grid) {
        if ([point count] >= 3) {
            glVertex3f([[point objectAtIndex:0] floatValue],
                       [[point objectAtIndex:1] floatValue],
                       [[point objectAtIndex:2] floatValue]);
        }
    }
    glEnd();
#endif
}

- (void)renderGamutModel:(Gamut3DModel *)model {
#if HAVE_OPENGL
    float *color = [model color];
    glColor3f(color[0], color[1], color[2]);
    
    NSArray *vertices = [model vertices];
    if ([vertices count] > 0) {
        glBegin(GL_POINTS);
        for (NSArray *point in vertices) {
            if ([point count] >= 3) {
                glVertex3f([[point objectAtIndex:0] floatValue],
                           [[point objectAtIndex:1] floatValue],
                           [[point objectAtIndex:2] floatValue]);
            }
        }
        glEnd();
    }
#endif
}

- (void)setViewportWidth:(float)width height:(float)height {
    viewportWidth = width;
    viewportHeight = height;
}

- (void)setCameraRotationX:(float)rotX rotationY:(float)rotY zoom:(float)z {
    rotationX = rotX;
    rotationY = rotY;
    zoom = z;
    if (zoom < 0.1) zoom = 0.1;
    if (zoom > 10.0) zoom = 10.0;
}

- (void)addGamutModel:(Gamut3DModel *)model {
    [gamutModels addObject:model];
}

- (void)setLabSpaceModel:(CIELABSpaceModel *)model {
    [labSpaceModel release];
    labSpaceModel = [model retain];
}

- (void)clearGamutModels {
    [gamutModels removeAllObjects];
}

- (void)dealloc {
    [self shutdown];
    [gamutModels release];
    [labSpaceModel release];
    [super dealloc];
}

@end
