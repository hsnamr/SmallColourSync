//
//  ProfileInspectorPanel.m
//  SmallICCer
//
//  Profile Inspector Panel implementation
//

#import "ProfileInspectorPanel.h"
#import "ICCProfile.h"

@implementation ProfileInspectorPanel

- (id)init {
    self = [super init];
    if (self) {
        // Initialize UI components
        // (Simplified - would create proper UI layout)
    }
    return self;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = profile;
    
    // Update metadata view
    NSMutableString *metadata = [NSMutableString string];
    [metadata appendFormat:@"Profile Size: %lu bytes\n", (unsigned long)[profile profileSize]];
    [metadata appendFormat:@"Version: %lu\n", (unsigned long)[profile version]];
    [metadata appendFormat:@"Device Class: %lu\n", (unsigned long)[profile deviceClass]];
    [metadata appendFormat:@"Data Color Space: %lu\n", (unsigned long)[profile dataColorSpace]];
    [metadata appendFormat:@"PCS Color Space: %lu\n", (unsigned long)[profile pcsColorSpace]];
    
    if ([profile creationDate]) {
        [metadata appendFormat:@"Creation Date: %@\n", [profile creationDate]];
    }
    
    // Update tag table
    // (Would update NSTableView with tag list)
}

- (void)dealloc {
    [metadataView release];
    [tagTableView release];
    [super dealloc];
}

@end
