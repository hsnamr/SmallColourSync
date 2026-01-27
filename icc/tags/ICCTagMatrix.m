//
//  ICCTagMatrix.m
//  SmallICCer
//
//  Matrix Tag implementation
//

#import "ICCTagMatrix.h"

@implementation ICCTagMatrix

- (id)initWithData:(void *)data signature:(NSString *)sig {
    self = [super initWithData:data signature:sig];
    if (self) {
        // Initialize to identity matrix
        NSUInteger i, j;
        for (i = 0; i < 3; i++) {
            for (j = 0; j < 3; j++) {
                matrix[i][j] = (i == j) ? 1.0 : 0.0;
            }
            offset[i] = 0.0;
        }
    }
    return self;
}

- (void)transformXYZ:(double *)xyz {
    double result[3];
    NSUInteger i, j;
    for (i = 0; i < 3; i++) {
        result[i] = offset[i];
        for (j = 0; j < 3; j++) {
            result[i] += matrix[i][j] * xyz[j];
        }
    }
    xyz[0] = result[0];
    xyz[1] = result[1];
    xyz[2] = result[2];
}

- (void)setMatrixElement:(NSUInteger)row col:(NSUInteger)col value:(double)value {
    if (row < 3 && col < 3) {
        matrix[row][col] = value;
    }
}

- (double)matrixElement:(NSUInteger)row col:(NSUInteger)col {
    if (row < 3 && col < 3) {
        return matrix[row][col];
    }
    return 0.0;
}

@end
