//
//  ProfileInspectorPanel.h
//  SmallICCer
//
//  Displays ICC metadata and tag structure
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;

@interface ProfileInspectorPanel : NSView {
    NSTextView *metadataView;
    NSTableView *tagTableView;
    ICCProfile *currentProfile;
}

- (void)displayProfile:(ICCProfile *)profile;

@end

NS_ASSUME_NONNULL_END
