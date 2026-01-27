//
//  ICCTagMetadata.m
//  SmallICCer
//
//  Metadata Tag implementation
//

#import "ICCTagMetadata.h"

@implementation ICCTagMetadata

@synthesize textValue;
@synthesize locale;

- (id)initWithData:(void *)data signature:(NSString *)sig {
    self = [super initWithData:data signature:sig];
    if (self) {
        textValue = [[NSString alloc] init];
        locale = @"en_US";
    }
    return self;
}

- (void)dealloc {
    [textValue release];
    [locale release];
    [super dealloc];
}

@end
