//
//  FileBrowserPanel.m
//  SmallICCer
//
//  File Browser Panel implementation
//

#import "FileBrowserPanel.h"
#import "AppController.h"

@implementation FileBrowserPanel

- (id)initWithAppController:(AppController *)controller {
    self = [super init];
    if (self) {
        appController = [controller retain];
        
        // Create open/save buttons
        openButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 100, 30)];
        [openButton setTitle:@"Open Profile"];
        [openButton setTarget:self];
        [openButton setAction:@selector(openProfile:)];
        [self addSubview:openButton];
        
        saveButton = [[NSButton alloc] initWithFrame:NSMakeRect(120, 10, 100, 30)];
        [saveButton setTitle:@"Save Profile"];
        [saveButton setTarget:self];
        [saveButton setAction:@selector(saveProfile:)];
        [self addSubview:saveButton];
    }
    return self;
}

- (void)openProfile:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"icc"]];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanChooseDirectories:NO];
    
    if ([openPanel runModal] == NSModalResponseOK) {
        NSString *path = [[openPanel URL] path];
        NSError *error = nil;
        if (![appController loadProfileFromPath:path error:&error]) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }
}

- (void)saveProfile:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"icc"]];
    
    if ([savePanel runModal] == NSModalResponseOK) {
        NSString *path = [[savePanel URL] path];
        NSError *error = nil;
        if (![appController saveProfileToPath:path error:&error]) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }
}

- (void)dealloc {
    [appController release];
    [openButton release];
    [saveButton release];
    [super dealloc];
}

@end
