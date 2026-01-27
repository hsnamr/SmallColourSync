//
//  ICCTagTRC.h
//  SmallICCer
//
//  Tone Reproduction Curve (TRC) tag
//

#import "ICCTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICCTagTRC : ICCTag {
    NSArray *curvePoints; // Array of curve values
    NSUInteger curveType; // 0=parametric, 1=table
}

@property (nonatomic, retain) NSArray *curvePoints;
@property (nonatomic) NSUInteger curveType;

- (double)valueAtPosition:(double)position; // 0.0 to 1.0
- (void)loadFromToneCurve:(void *)toneCurve; // Load from cmsToneCurve

@end

NS_ASSUME_NONNULL_END
