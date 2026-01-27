//
//  TagEditorPanel.h
//  SmallICCer
//
//  Allows editing TRCs, matrices, LUTs, metadata
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;

@interface TagEditorPanel : NSView {
    NSPopUpButton *tagSelector;
    NSView *tagEditorView;
    ICCProfile *currentProfile;
}

- (void)displayProfile:(ICCProfile *)profile;

@end

NS_ASSUME_NONNULL_END
