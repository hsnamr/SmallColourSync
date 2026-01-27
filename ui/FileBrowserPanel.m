//
//  FileBrowserPanel.m
//  SmallICCer
//
//  File Browser Panel implementation
//

#import "FileBrowserPanel.h"
#import "AppController.h"
#import "SSFileDialog.h"

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
    SSFileDialog *openDialog = [SSFileDialog openDialog];
    [openDialog setAllowedFileTypes:[NSArray arrayWithObject:@"icc"]];
    [openDialog setCanChooseFiles:YES];
    [openDialog setCanChooseDirectories:NO];
    
    NSArray *urls = [openDialog showModal];
    if (urls && [urls count] > 0) {
        NSString *path = [[urls objectAtIndex:0] path];
        NSError *error = nil;
        if (![appController loadProfileFromPath:path error:&error]) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }
}

- (void)saveProfile:(id)sender {
    SSFileDialog *saveDialog = [SSFileDialog saveDialog];
    [saveDialog setAllowedFileTypes:[NSArray arrayWithObject:@"icc"]];
    
    NSArray *urls = [saveDialog showModal];
    if (urls && [urls count] > 0) {
        NSString *path = [[urls objectAtIndex:0] path];
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
