//
//  ICCTagLUT.h
//  SmallICCer
//
//  Look-Up Table (LUT) tag
//

#import "ICCTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICCTagLUT : ICCTag {
    NSUInteger inputChannels;
    NSUInteger outputChannels;
    NSUInteger gridPoints;
    NSData *lutData;
}

@property (nonatomic) NSUInteger inputChannels;
@property (nonatomic) NSUInteger outputChannels;
@property (nonatomic) NSUInteger gridPoints;
@property (nonatomic, retain) NSData *lutData;

- (void)lookupInput:(const double *)input output:(double *)output;
- (void)loadFromPipeline:(void *)pipeline; // Load from cmsPipeline

@end

NS_ASSUME_NONNULL_END
