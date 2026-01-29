//
//  HistogramAndCurvesPanel.h
//  SmallICCer
//
//  For TRC visualization and editing
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class ICCTagTRC;

@interface HistogramAndCurvesPanel : NSView {
    NSView *curveView;
    ICCProfile *currentProfile;
    ICCTagTRC *redTRC;
    ICCTagTRC *greenTRC;
    ICCTagTRC *blueTRC;
}

- (void)displayProfile:(ICCProfile *)profile;
- (void)drawCurve:(ICCTagTRC *)trc color:(NSColor *)color inRect:(NSRect)rect;

@end

NS_ASSUME_NONNULL_END
