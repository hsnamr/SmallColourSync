//
//  GamutComparator.h
//  SmallICCer
//
//  Computes relative volume differences and overlays multiple gamuts
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Gamut3DModel;

@interface GamutComparator : NSObject

- (double)computeVolume:(Gamut3DModel *)gamut;
- (double)computeVolumeDifference:(Gamut3DModel *)gamut1 and:(Gamut3DModel *)gamut2;
- (NSArray *)findOverlap:(Gamut3DModel *)gamut1 and:(Gamut3DModel *)gamut2;

@end

NS_ASSUME_NONNULL_END
