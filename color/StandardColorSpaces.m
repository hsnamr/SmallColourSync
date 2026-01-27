//
//  StandardColorSpaces.m
//  SmallICCer
//
//  Standard Color Spaces implementation
//

#import "StandardColorSpaces.h"

@implementation StandardColorSpaces

+ (ColorSpace *)sRGB {
    // sRGB primaries (xy coordinates)
    NSArray *red = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:0.6400],
                   [NSNumber numberWithDouble:0.3300],
                   nil];
    NSArray *green = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.3000],
                     [NSNumber numberWithDouble:0.6000],
                     nil];
    NSArray *blue = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:0.1500],
                    [NSNumber numberWithDouble:0.0600],
                    nil];
    NSArray *primaries = [NSArray arrayWithObjects:red, green, blue, nil];
    
    // D65 white point
    NSArray *whitePoint = [NSArray arrayWithObjects:
                          [NSNumber numberWithDouble:0.3127],
                          [NSNumber numberWithDouble:0.3290],
                          nil];
    
    // sRGB TRC (gamma 2.2 approximation)
    NSArray *trc = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:2.2],
                   nil];
    
    return [[[ColorSpace alloc] initWithName:@"sRGB" 
                                   primaries:primaries 
                                  whitePoint:whitePoint 
                                         trc:trc] autorelease];
}

+ (ColorSpace *)adobeRGB {
    // Adobe RGB primaries
    NSArray *red = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:0.6400],
                   [NSNumber numberWithDouble:0.3300],
                   nil];
    NSArray *green = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.2100],
                     [NSNumber numberWithDouble:0.7100],
                     nil];
    NSArray *blue = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:0.1500],
                    [NSNumber numberWithDouble:0.0600],
                    nil];
    NSArray *primaries = [NSArray arrayWithObjects:red, green, blue, nil];
    
    // D65 white point
    NSArray *whitePoint = [NSArray arrayWithObjects:
                          [NSNumber numberWithDouble:0.3127],
                          [NSNumber numberWithDouble:0.3290],
                          nil];
    
    // Adobe RGB TRC (gamma 2.2)
    NSArray *trc = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:2.2],
                   nil];
    
    return [[[ColorSpace alloc] initWithName:@"Adobe RGB" 
                                   primaries:primaries 
                                  whitePoint:whitePoint 
                                         trc:trc] autorelease];
}

+ (ColorSpace *)displayP3 {
    // Display P3 primaries
    NSArray *red = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:0.6800],
                   [NSNumber numberWithDouble:0.3200],
                   nil];
    NSArray *green = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.2650],
                     [NSNumber numberWithDouble:0.6900],
                     nil];
    NSArray *blue = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:0.1500],
                    [NSNumber numberWithDouble:0.0600],
                    nil];
    NSArray *primaries = [NSArray arrayWithObjects:red, green, blue, nil];
    
    // D65 white point
    NSArray *whitePoint = [NSArray arrayWithObjects:
                          [NSNumber numberWithDouble:0.3127],
                          [NSNumber numberWithDouble:0.3290],
                          nil];
    
    // Display P3 TRC (gamma 2.2)
    NSArray *trc = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:2.2],
                   nil];
    
    return [[[ColorSpace alloc] initWithName:@"Display P3" 
                                   primaries:primaries 
                                  whitePoint:whitePoint 
                                         trc:trc] autorelease];
}

+ (ColorSpace *)proPhotoRGB {
    // ProPhoto RGB primaries
    NSArray *red = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:0.7347],
                   [NSNumber numberWithDouble:0.2653],
                   nil];
    NSArray *green = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.1596],
                     [NSNumber numberWithDouble:0.8404],
                     nil];
    NSArray *blue = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:0.0366],
                    [NSNumber numberWithDouble:0.0001],
                    nil];
    NSArray *primaries = [NSArray arrayWithObjects:red, green, blue, nil];
    
    // D50 white point
    NSArray *whitePoint = [NSArray arrayWithObjects:
                          [NSNumber numberWithDouble:0.3457],
                          [NSNumber numberWithDouble:0.3585],
                          nil];
    
    // ProPhoto RGB TRC (gamma 1.8)
    NSArray *trc = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:1.8],
                   nil];
    
    return [[[ColorSpace alloc] initWithName:@"ProPhoto RGB" 
                                   primaries:primaries 
                                  whitePoint:whitePoint 
                                         trc:trc] autorelease];
}

+ (ColorSpace *)rec2020 {
    // Rec. 2020 primaries
    NSArray *red = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:0.7080],
                   [NSNumber numberWithDouble:0.2920],
                   nil];
    NSArray *green = [NSArray arrayWithObjects:
                     [NSNumber numberWithDouble:0.1700],
                     [NSNumber numberWithDouble:0.7970],
                     nil];
    NSArray *blue = [NSArray arrayWithObjects:
                    [NSNumber numberWithDouble:0.1310],
                    [NSNumber numberWithDouble:0.0460],
                    nil];
    NSArray *primaries = [NSArray arrayWithObjects:red, green, blue, nil];
    
    // D65 white point
    NSArray *whitePoint = [NSArray arrayWithObjects:
                          [NSNumber numberWithDouble:0.3127],
                          [NSNumber numberWithDouble:0.3290],
                          nil];
    
    // Rec. 2020 TRC (PQ or HLG, simplified to gamma 2.4)
    NSArray *trc = [NSArray arrayWithObjects:
                   [NSNumber numberWithDouble:2.4],
                   nil];
    
    return [[[ColorSpace alloc] initWithName:@"Rec. 2020" 
                                   primaries:primaries 
                                  whitePoint:whitePoint 
                                         trc:trc] autorelease];
}

+ (NSArray *)allStandardSpaces {
    return [NSArray arrayWithObjects:
           [self sRGB],
           [self adobeRGB],
           [self displayP3],
           [self proPhotoRGB],
           [self rec2020],
           nil];
}

@end
