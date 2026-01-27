//
//  SettingsManager.m
//  SmallICCer
//
//  Settings manager implementation
//

#import "SettingsManager.h"

static SettingsManager *sharedInstance = nil;

@implementation SettingsManager

+ (SettingsManager *)sharedManager {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
        }
    }
    return sharedInstance;
}

@synthesize renderingQuality;
@synthesize comparisonColorSpaces;
@synthesize showGrid;
@synthesize showAxes;
@synthesize backgroundColorRed;
@synthesize backgroundColorGreen;
@synthesize backgroundColorBlue;

- (id)init {
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
        [self loadSettings];
    }
    return self;
}

- (void)loadSettings {
    renderingQuality = [defaults integerForKey:@"RenderingQuality"];
    if (renderingQuality == 0 && ![defaults objectForKey:@"RenderingQuality"]) {
        renderingQuality = 1; // Default to medium
    }
    
    comparisonColorSpaces = [defaults arrayForKey:@"ComparisonColorSpaces"];
    if (!comparisonColorSpaces) {
        comparisonColorSpaces = [[NSArray arrayWithObjects:@"sRGB", @"Adobe RGB", @"Display-P3", nil] retain];
    } else {
        [comparisonColorSpaces retain];
    }
    
    showGrid = [defaults boolForKey:@"ShowGrid"];
    if (![defaults objectForKey:@"ShowGrid"]) {
        showGrid = YES; // Default to showing grid
    }
    
    showAxes = [defaults boolForKey:@"ShowAxes"];
    if (![defaults objectForKey:@"ShowAxes"]) {
        showAxes = YES; // Default to showing axes
    }
    
    backgroundColorRed = [defaults floatForKey:@"BackgroundColorRed"];
    backgroundColorGreen = [defaults floatForKey:@"BackgroundColorGreen"];
    backgroundColorBlue = [defaults floatForKey:@"BackgroundColorBlue"];
    if (![defaults objectForKey:@"BackgroundColorRed"]) {
        backgroundColorRed = 0.1;
        backgroundColorGreen = 0.1;
        backgroundColorBlue = 0.1; // Dark gray default
    }
}

- (void)saveSettings {
    [defaults setInteger:renderingQuality forKey:@"RenderingQuality"];
    [defaults setObject:comparisonColorSpaces forKey:@"ComparisonColorSpaces"];
    [defaults setBool:showGrid forKey:@"ShowGrid"];
    [defaults setBool:showAxes forKey:@"ShowAxes"];
    [defaults setFloat:backgroundColorRed forKey:@"BackgroundColorRed"];
    [defaults setFloat:backgroundColorGreen forKey:@"BackgroundColorGreen"];
    [defaults setFloat:backgroundColorBlue forKey:@"BackgroundColorBlue"];
    [defaults synchronize];
}

- (void)dealloc {
    [comparisonColorSpaces release];
    [super dealloc];
}

@end
