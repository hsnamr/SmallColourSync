//
//  ICCTag.m
//  SmallICCer
//
//  Base ICC Tag implementation
//

#import "ICCTag.h"

@implementation ICCTag

@synthesize signature;
@synthesize rawData;

- (id)initWithData:(void *)data signature:(NSString *)sig {
    self = [super init];
    if (self) {
        signature = [sig retain];
        // Store raw data - size will depend on tag type
        // For now, we'll store a minimal representation
        rawData = [[NSData alloc] initWithBytes:data length:0]; // Placeholder
    }
    return self;
}

- (NSData *)serialize {
    return rawData;
}

- (void)dealloc {
    [signature release];
    [rawData release];
    [super dealloc];
}

@end
