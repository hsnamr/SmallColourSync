//
//  MainWindow.h
//  SmallICCer
//
//  Main application window
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AppController;
@class ICCProfile;
@class ProfileInspectorPanel;
@class TagEditorPanel;
@class GamutViewPanel;
@class HistogramAndCurvesPanel;
@class FileBrowserPanel;

@interface MainWindow : NSWindow {
    AppController *appController;
    ProfileInspectorPanel *profileInspector;
    TagEditorPanel *tagEditor;
    GamutViewPanel *gamutView;
    HistogramAndCurvesPanel *histogramCurves;
    FileBrowserPanel *fileBrowser;
}

@property (nonatomic, retain) AppController *appController;
@property (nonatomic, retain) ProfileInspectorPanel *profileInspector;
@property (nonatomic, retain) TagEditorPanel *tagEditor;
@property (nonatomic, retain) GamutViewPanel *gamutView;
@property (nonatomic, retain) HistogramAndCurvesPanel *histogramCurves;
@property (nonatomic, retain) FileBrowserPanel *fileBrowser;

- (id)initWithAppController:(AppController *)controller;
- (void)profileDidLoad:(ICCProfile *)profile;

@end

NS_ASSUME_NONNULL_END
