//
//  AppController.m
//  SmallICCer
//
//  Main application controller implementation
//

#import "AppController.h"
#import "MainWindow.h"
#import "SettingsManager.h"
#import "ICCProfile.h"
#import "ICCParser.h"
#import "ICCWriter.h"

@implementation AppController

@synthesize mainWindow;
@synthesize activeProfile;
@synthesize settingsManager;

- (id)init {
    self = [super init];
    if (self) {
        settingsManager = [SettingsManager sharedManager];
        activeProfile = nil;
    }
    return self;
}

- (void)applicationDidFinishLaunching {
    mainWindow = [[MainWindow alloc] initWithAppController:self];
    [mainWindow makeKeyAndOrderFront:nil];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(id)sender {
    (void)sender;
    return YES;
}

- (BOOL)loadProfileFromPath:(NSString *)path error:(NSError **)error {
    ICCParser *parser = [[ICCParser alloc] init];
    ICCProfile *profile = [parser parseProfileFromPath:path error:error];
    
    if (profile) {
        self.activeProfile = profile;
        [mainWindow profileDidLoad:profile];
        [parser release];
        return YES;
    } else {
        [parser release];
        return NO;
    }
}

- (BOOL)saveProfileToPath:(NSString *)path error:(NSError **)error {
    if (!activeProfile) {
        if (error) {
            *error = [NSError errorWithDomain:@"SmallICCer" 
                                         code:1 
                                     userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                               @"No profile loaded", NSLocalizedDescriptionKey, nil]];
        }
        return NO;
    }
    
    ICCWriter *writer = [[ICCWriter alloc] init];
    BOOL success = [writer writeProfile:activeProfile toPath:path error:error];
    [writer release];
    return success;
}

- (void)dealloc {
    [mainWindow release];
    [activeProfile release];
    /* settingsManager is shared singleton, do not release */
    [super dealloc];
}

@end
