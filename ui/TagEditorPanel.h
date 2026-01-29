//
//  TagEditorPanel.h
//  SmallICCer
//
//  Allows editing TRCs, matrices, LUTs, metadata
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class ICCTag;

@interface TagEditorPanel : NSView <NSTextViewDelegate> {
    NSPopUpButton *tagSelector;
    NSView *tagEditorView;
    ICCProfile *currentProfile;
    
    // TRC Editor
    NSView *trcEditorView;
    NSTextView *trcCurveView;
    
    // Matrix Editor
    NSView *matrixEditorView;
    NSTextField *matrixFields[3][3];
    NSTextField *offsetFields[3];
    
    // LUT Editor
    NSView *lutEditorView;
    NSTextField *lutInfoView;
    
    // Metadata Editor
    NSView *metadataEditorView;
    NSTextView *metadataTextView;
}

- (void)displayProfile:(ICCProfile *)profile;
- (void)tagSelectionChanged:(id)sender;

@end

NS_ASSUME_NONNULL_END
