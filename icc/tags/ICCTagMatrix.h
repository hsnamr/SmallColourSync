//
//  ICCTagMatrix.h
//  SmallICCer
//
//  Matrix tag for color space transformations
//

#import "ICCTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICCTagMatrix : ICCTag {
    double matrix[3][3]; // 3x3 transformation matrix
    double offset[3];    // Offset vector
}

- (void)transformXYZ:(double *)xyz;
- (void)setMatrixElement:(NSUInteger)row col:(NSUInteger)col value:(double)value;
- (double)matrixElement:(NSUInteger)row col:(NSUInteger)col;

@end

NS_ASSUME_NONNULL_END
