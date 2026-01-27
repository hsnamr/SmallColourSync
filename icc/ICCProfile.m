//
//  ICCProfile.m
//  SmallICCer
//
//  ICC Profile implementation
//

#import "ICCProfile.h"
#import "ICCTag.h"

@implementation ICCProfile

@synthesize profileSize;
@synthesize preferredCMM;
@synthesize version;
@synthesize deviceClass;
@synthesize dataColorSpace;
@synthesize pcsColorSpace;
@synthesize creationDate;
@synthesize platformSignature;
@synthesize flags;
@synthesize deviceManufacturer;
@synthesize deviceModel;
@synthesize deviceAttributes;
@synthesize renderingIntent;
@synthesize pcsIlluminant;
@synthesize profileCreator;
@synthesize tags;

- (id)init {
    self = [super init];
    if (self) {
        tags = [[NSMutableDictionary alloc] init];
        pcsIlluminant = [[NSArray arrayWithObjects:
                         [NSNumber numberWithDouble:0.9642],
                         [NSNumber numberWithDouble:1.0],
                         [NSNumber numberWithDouble:0.8249],
                         nil] retain];
    }
    return self;
}

- (ICCTag *)tagWithSignature:(NSString *)signature {
    return [tags objectForKey:signature];
}

- (void)setTag:(ICCTag *)tag withSignature:(NSString *)signature {
    [tags setObject:tag forKey:signature];
}

- (NSArray *)allTagSignatures {
    return [tags allKeys];
}

- (void)dealloc {
    [preferredCMM release];
    [creationDate release];
    [platformSignature release];
    [deviceManufacturer release];
    [deviceModel release];
    [pcsIlluminant release];
    [profileCreator release];
    [tags release];
    [super dealloc];
}

@end
