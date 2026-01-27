//
//  CIELABSpaceModel.h
//  SmallICCer
//
//  Generates the 3D axes and bounding surfaces for the Lab space
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CIELABSpaceModel : NSObject {
    NSArray *axisVertices;
    NSArray *gridVertices;
    BOOL showAxes;
    BOOL showGrid;
}

@property (nonatomic, retain) NSArray *axisVertices;
@property (nonatomic, retain) NSArray *gridVertices;
@property (nonatomic) BOOL showAxes;
@property (nonatomic) BOOL showGrid;

- (void)generateAxes;
- (void)generateGrid;

@end

NS_ASSUME_NONNULL_END
