//
//  Gamut3DModel.h
//  SmallICCer
//
//  Stores mesh/point cloud representing a gamut in Lab space
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Gamut3DModel : NSObject {
    NSArray *vertices; // Array of NSArray with 3 NSNumber (Lab coordinates)
    NSArray *faces;    // Array of NSArray with vertex indices
    NSString *name;
    float color[3];    // RGB color for rendering
}

@property (nonatomic, retain) NSArray *vertices;
@property (nonatomic, retain) NSArray *faces;
@property (nonatomic, retain) NSString *name;
@property (nonatomic) float *color;

- (id)initWithVertices:(NSArray *)verts faces:(NSArray *)fs name:(NSString *)n;
- (void)setColorRed:(float)r green:(float)g blue:(float)b;

@end

NS_ASSUME_NONNULL_END
