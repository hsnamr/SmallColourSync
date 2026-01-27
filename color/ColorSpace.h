//
//  ColorSpace.h
//  SmallICCer
//
//  Abstract representation of a color space
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorSpace : NSObject {
    NSString *name;
    NSArray *primaries; // Array of 3 arrays, each with 2 xy coordinates
    NSArray *whitePoint; // Array with 2 xy coordinates
    NSArray *trc; // Tone reproduction curve parameters
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSArray *primaries;
@property (nonatomic, retain) NSArray *whitePoint;
@property (nonatomic, retain) NSArray *trc;

- (id)initWithName:(NSString *)name 
         primaries:(NSArray *)primaries 
         whitePoint:(NSArray *)whitePoint 
               trc:(NSArray *)trc;

@end

NS_ASSUME_NONNULL_END
