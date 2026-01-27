//
//  TagEditorPanel.m
//  SmallICCer
//
//  Tag Editor Panel implementation
//

#import "TagEditorPanel.h"
#import "ICCProfile.h"

@implementation TagEditorPanel

- (id)init {
    self = [super init];
    if (self) {
        // Initialize UI components
    }
    return self;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = profile;
    
    // Update tag selector with available tags
    NSArray *tagSignatures = [profile allTagSignatures];
    // (Would populate NSPopUpButton with tag list)
}

- (void)dealloc {
    [tagSelector release];
    [tagEditorView release];
    [super dealloc];
}

@end
