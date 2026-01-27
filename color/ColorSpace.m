//
//  ColorSpace.m
//  SmallICCer
//
//  Color Space implementation
//

#import "ColorSpace.h"

@implementation ColorSpace

@synthesize name;
@synthesize primaries;
@synthesize whitePoint;
@synthesize trc;

- (id)initWithName:(NSString *)n 
         primaries:(NSArray *)p 
         whitePoint:(NSArray *)wp 
               trc:(NSArray *)t {
    self = [super init];
    if (self) {
        name = [n retain];
        primaries = [p retain];
        whitePoint = [wp retain];
        trc = [t retain];
    }
    return self;
}

- (void)dealloc {
    [name release];
    [primaries release];
    [whitePoint release];
    [trc release];
    [super dealloc];
}

@end
