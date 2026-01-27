//
//  ProfileInspectorPanel.h
//  SmallICCer
//
//  Displays ICC metadata and tag structure
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;

@interface ProfileInspectorPanel : NSView <NSTableViewDataSource> {
    NSScrollView *metadataScrollView;
    NSTextView *metadataView;
    NSScrollView *tagTableScrollView;
    NSTableView *tagTableView;
    ICCProfile *currentProfile;
    NSArray *tagSignatures; // Sorted array of tag signatures for table
}

- (void)displayProfile:(ICCProfile *)profile;

@end

NS_ASSUME_NONNULL_END
