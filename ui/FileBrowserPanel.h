//
//  FileBrowserPanel.h
//  SmallICCer
//
//  For loading/saving ICC profiles
//

#import <AppKit/AppKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AppController;

@interface FileBrowserPanel : NSView {
    AppController *appController;
    NSButton *openButton;
    NSButton *saveButton;
}

- (id)initWithAppController:(AppController *)controller;

@end

NS_ASSUME_NONNULL_END
