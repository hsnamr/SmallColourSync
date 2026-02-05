//
//  AppController.h
//  SmallICCer
//
//  Main application controller (SSAppDelegate).
//  Coordinates UI, file I/O, and rendering
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>
#import "SSAppDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;
@class MainWindow;
@class SettingsManager;

@interface AppController : NSObject <SSAppDelegate> {
    MainWindow *mainWindow;
    ICCProfile *activeProfile;
    SettingsManager *settingsManager;
}

@property (retain, nonatomic) MainWindow *mainWindow;
@property (retain, nonatomic, nullable) ICCProfile *activeProfile;
@property (retain, nonatomic) SettingsManager *settingsManager;

- (BOOL)loadProfileFromPath:(NSString *)path error:(NSError **)error;
- (BOOL)saveProfileToPath:(NSString *)path error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
