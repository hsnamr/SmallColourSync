//
//  GamutViewPanel.m
//  SmallICCer
//
//  Gamut View Panel with GamutComparator UI (add standard spaces, visibility, colors, stats).
//

#import "GamutViewPanel.h"
#import "ICCProfile.h"
#import "Renderer3D.h"
#import "Gamut3DModel.h"
#import "CIELABSpaceModel.h"
#import "GamutCalculator.h"
#import "GamutComparator.h"
#import "StandardColorSpaces.h"
#import "ColorSpace.h"
#import "SettingsManager.h"

#define COMPARISON_PANEL_WIDTH 220.0f

// Default colors for standard space gamuts (R,G,B 0-1)
static const float kComparisonColors[][3] = {
    {0.0f, 0.8f, 0.0f},   // sRGB - green
    {0.2f, 0.4f, 1.0f},    // Adobe RGB - blue
    {0.0f, 0.8f, 0.8f},   // Display P3 - cyan
    {0.9f, 0.7f, 0.0f},   // ProPhoto RGB - yellow
    {0.9f, 0.0f, 0.5f},   // Rec. 2020 - magenta
};

@implementation GamutViewPanel

- (id)init {
    return [self initWithBackendType:[RenderBackendFactory defaultBackendType]];
}

- (void)layoutComparisonPanel {
    NSRect bounds = [self bounds];
    CGFloat w = bounds.size.width;
    CGFloat h = bounds.size.height;
    if (comparisonPanel && w > COMPARISON_PANEL_WIDTH) {
        [comparisonPanel setFrame:NSMakeRect(w - COMPARISON_PANEL_WIDTH, 0, COMPARISON_PANEL_WIDTH, h)];
        if (glContentView) {
            [glContentView setFrame:NSMakeRect(0, 0, w - COMPARISON_PANEL_WIDTH, h)];
        }
    }
}

- (id)initWithBackendType:(RenderBackendType)backendType {
    self = [super initWithFrame:NSMakeRect(0, 0, 800, 600)];
    if (self) {
        preferredBackend = backendType;
        comparisonEntries = [[NSMutableArray alloc] init];
        comparisonPanelWidth = COMPARISON_PANEL_WIDTH;
        glContentView = nil;

        if (backendType == RenderBackendTypeOpenGL) {
            NSOpenGLPixelFormatAttribute attrs[] = {
                NSOpenGLPFADoubleBuffer,
                NSOpenGLPFADepthSize, 24,
                0
            };
            NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
            NSOpenGLView *glView = [[NSOpenGLView alloc] initWithFrame:[self bounds] pixelFormat:pixelFormat];
            [pixelFormat release];
            [glView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
            [self addSubview:glView];
            glContentView = glView;
            [glView release];

            [self layoutComparisonPanel];

            renderer = [[Renderer3D alloc] initWithView:glContentView backendType:backendType];
            [renderer applySettings];

            NSRect bounds = [self bounds];
            CGFloat panelX = bounds.size.width - COMPARISON_PANEL_WIDTH;
            if (panelX < 0) panelX = 0;
            comparisonPanel = [[NSView alloc] initWithFrame:NSMakeRect(panelX, 0, COMPARISON_PANEL_WIDTH, bounds.size.height)];
            [comparisonPanel setAutoresizingMask:NSViewMinXMargin | NSViewHeightSizable];
            [comparisonPanel setBounds:NSMakeRect(0, 0, COMPARISON_PANEL_WIDTH, bounds.size.height)];

            addComparisonPopUp = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(8, bounds.size.height - 36, COMPARISON_PANEL_WIDTH - 16, 24)];
            [addComparisonPopUp addItemWithTitle:@"Add comparison..."];
            [[addComparisonPopUp menu] addItem:[NSMenuItem separatorItem]];
            [addComparisonPopUp addItemWithTitle:@"sRGB"];
            [addComparisonPopUp addItemWithTitle:@"Adobe RGB"];
            [addComparisonPopUp addItemWithTitle:@"Display P3"];
            [addComparisonPopUp addItemWithTitle:@"ProPhoto RGB"];
            [addComparisonPopUp addItemWithTitle:@"Rec. 2020"];
            [addComparisonPopUp setTarget:self];
            [addComparisonPopUp setAction:@selector(addComparisonSelected:)];
            [addComparisonPopUp setPullsDown:NO];
            [comparisonPanel addSubview:addComparisonPopUp];
            [addComparisonPopUp release];

            NSScrollView *tableScroll = [[NSScrollView alloc] initWithFrame:NSMakeRect(8, 76, COMPARISON_PANEL_WIDTH - 16, bounds.size.height - 76 - 78)];
            [tableScroll setHasVerticalScroller:YES];
            [tableScroll setBorderType:NSBezelBorder];
            [tableScroll setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];

            comparisonTableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, COMPARISON_PANEL_WIDTH - 24, 100)];
            NSTableColumn *nameCol = [[NSTableColumn alloc] initWithIdentifier:@"name"];
            [[nameCol headerCell] setStringValue:@"Gamut"];
            [nameCol setWidth:90];
            [comparisonTableView addTableColumn:nameCol];
            [nameCol release];
            NSTableColumn *visCol = [[NSTableColumn alloc] initWithIdentifier:@"visible"];
            [[visCol headerCell] setStringValue:@"Show"];
            [visCol setWidth:40];
            NSButtonCell *checkCell = [[NSButtonCell alloc] init];
            [checkCell setButtonType:NSButtonTypeSwitch];
            [checkCell setTitle:@""];
            [visCol setDataCell:checkCell];
            [checkCell release];
            [comparisonTableView addTableColumn:visCol];
            [visCol release];
            [comparisonTableView setDataSource:self];
            [comparisonTableView setDelegate:self];
            [comparisonTableView setHeaderView:[[NSTableHeaderView alloc] init]];
            [tableScroll setDocumentView:comparisonTableView];
            [comparisonPanel addSubview:tableScroll];
            [comparisonTableView release];
            [tableScroll release];

            NSButton *removeButton = [[NSButton alloc] initWithFrame:NSMakeRect(8, 52, COMPARISON_PANEL_WIDTH - 16, 24)];
            [removeButton setTitle:@"Remove selected"];
            [removeButton setTarget:self];
            [removeButton setAction:@selector(removeSelectedComparison:)];
            [removeButton setButtonType:NSButtonTypeMomentaryPushIn];
            [comparisonPanel addSubview:removeButton];
            [removeButton release];

            statsTextField = [[NSTextField alloc] initWithFrame:NSMakeRect(8, 8, COMPARISON_PANEL_WIDTH - 16, 60)];
            [statsTextField setEditable:NO];
            [statsTextField setBordered:NO];
            [statsTextField setDrawsBackground:NO];
            [statsTextField setFont:[NSFont systemFontOfSize:10.0]];
            [statsTextField setAlignment:NSTextAlignmentLeft];
            [statsTextField setStringValue:@"Load a profile and add comparisons to see volume stats."];
            [comparisonPanel addSubview:statsTextField];
            [statsTextField release];

            [self addSubview:comparisonPanel];
            [comparisonPanel release];
        } else {
            glContentView = nil;
            comparisonPanel = nil;
            addComparisonPopUp = nil;
            comparisonTableView = nil;
            statsTextField = nil;
            renderer = [[Renderer3D alloc] initWithView:self backendType:backendType];
            [renderer applySettings];
        }
    }
    return self;
}

- (void)setPreferredBackend:(RenderBackendType)backendType {
    preferredBackend = backendType;
    [renderer release];
    if (backendType == RenderBackendTypeOpenGL && glContentView) {
        renderer = [[Renderer3D alloc] initWithView:glContentView backendType:backendType];
    } else {
        renderer = [[Renderer3D alloc] initWithView:self backendType:backendType];
    }
    [renderer applySettings];
}

- (void)addComparisonSelected:(id)sender {
    NSPopUpButton *pop = (NSPopUpButton *)sender;
    NSInteger idx = [pop indexOfSelectedItem];
    if (idx < 2) return;
    NSArray *titles = [NSArray arrayWithObjects:@"sRGB", @"Adobe RGB", @"Display P3", @"ProPhoto RGB", @"Rec. 2020", nil];
    NSInteger spaceIdx = idx - 2;
    if (spaceIdx < 0 || spaceIdx >= (NSInteger)[titles count]) return;
    ColorSpace *space = nil;
    NSArray *all = [StandardColorSpaces allStandardSpaces];
    if (spaceIdx < (NSInteger)[all count]) {
        space = [all objectAtIndex:spaceIdx];
    }
    if (!space) return;
    NSString *name = [titles objectAtIndex:spaceIdx];
    GamutCalculator *calc = [[GamutCalculator alloc] init];
    NSArray *points = [calc computeGamutForColorSpace:space];
    [calc release];
    Gamut3DModel *model = [[Gamut3DModel alloc] initWithVertices:points faces:nil name:name];
    const float *rgb = kComparisonColors[spaceIdx % 5];
    [model setColorRed:rgb[0] green:rgb[1] blue:rgb[2]];
    NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        model, @"model",
        [NSNumber numberWithBool:YES], @"visible",
        nil];
    [model release];
    [comparisonEntries addObject:entry];
    [comparisonTableView reloadData];
    [self refreshGamuts];
    [pop selectItemAtIndex:0];
}

- (void)refreshGamuts {
    [renderer clearGamutModels];
    if (currentProfile) {
        GamutCalculator *calculator = [[GamutCalculator alloc] init];
        NSArray *gamutPoints = [calculator computeGamutForProfile:currentProfile];
        [calculator release];
        Gamut3DModel *profileModel = [[Gamut3DModel alloc] initWithVertices:gamutPoints faces:nil name:@"Profile Gamut"];
        [profileModel setColorRed:1.0 green:0.0 blue:0.0];
        [renderer addGamutModel:profileModel];
        [profileModel release];
    }
    NSUInteger i, count = [comparisonEntries count];
    for (i = 0; i < count; i++) {
        NSDictionary *entry = [comparisonEntries objectAtIndex:i];
        if ([[entry objectForKey:@"visible"] boolValue]) {
            [renderer addGamutModel:[entry objectForKey:@"model"]];
        }
    }
    CIELABSpaceModel *labModel = [[CIELABSpaceModel alloc] init];
    SettingsManager *settings = [SettingsManager sharedManager];
    [settings loadSettings];
    [labModel setShowAxes:[settings showAxes]];
    [labModel setShowGrid:[settings showGrid]];
    [renderer setLabSpaceModel:labModel];
    [labModel release];
    [self updateStats];
    [self setNeedsDisplay:YES];
}

- (void)updateStats {
    if (!statsTextField) return;
    GamutComparator *comp = [[GamutComparator alloc] init];
    NSMutableString *text = [NSMutableString string];
    NSArray *models = [self visibleGamutModelsForStats];
    if ([models count] == 0) {
        [text setString:@"Add a profile and/or comparisons to see volume stats."];
    } else {
        NSUInteger i;
        for (i = 0; i < [models count]; i++) {
            Gamut3DModel *m = [models objectAtIndex:i];
            double vol = [comp computeVolume:m];
            if (i > 0) [text appendString:@"\n"];
            [text appendFormat:@"%@: %.0f (approx. vol)", [m name], vol];
        }
        if ([models count] >= 2) {
            double v0 = [comp computeVolume:[models objectAtIndex:0]];
            double v1 = [comp computeVolume:[models objectAtIndex:1]];
            double diff = [comp computeVolumeDifference:[models objectAtIndex:0] and:[models objectAtIndex:1]];
            double pct = (v0 > 0) ? (diff / v0 * 100.0) : 0;
            [text appendFormat:@"\nDifference: %.0f (%.1f%%)", diff, pct];
        }
    }
    [comp release];
    [statsTextField setStringValue:text];
}

- (NSArray *)visibleGamutModelsForStats {
    NSMutableArray *arr = [NSMutableArray array];
    if (currentProfile) {
        GamutCalculator *calc = [[GamutCalculator alloc] init];
        NSArray *pts = [calc computeGamutForProfile:currentProfile];
        [calc release];
        Gamut3DModel *pm = [[Gamut3DModel alloc] initWithVertices:pts faces:nil name:@"Profile"];
        [arr addObject:pm];
        [pm release];
    }
    NSUInteger i, c = [comparisonEntries count];
    for (i = 0; i < c; i++) {
        NSDictionary *e = [comparisonEntries objectAtIndex:i];
        if ([[e objectForKey:@"visible"] boolValue]) {
            [arr addObject:[e objectForKey:@"model"]];
        }
    }
    return arr;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = profile;
    [self refreshGamuts];
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    NSView *viewForViewport = glContentView ? glContentView : self;
    [renderer setViewportWidth:[viewForViewport bounds].size.width height:[viewForViewport bounds].size.height];
    [renderer render];
}

- (void)mouseDown:(NSEvent *)event {
    lastMouseLocation = [event locationInWindow];
}

- (void)mouseDragged:(NSEvent *)event {
    NSPoint currentLocation = [event locationInWindow];
    NSPoint delta = NSMakePoint(currentLocation.x - lastMouseLocation.x, currentLocation.y - lastMouseLocation.y);
    [renderer handleMouseDrag:delta];
    lastMouseLocation = currentLocation;
    [self setNeedsDisplay:YES];
}

- (void)scrollWheel:(NSEvent *)event {
    float delta = [event deltaY] * 0.1;
    [renderer handleZoom:delta];
    [self setNeedsDisplay:YES];
}

- (void)refreshFromSettings {
    [renderer applySettings];
    if (currentProfile) {
        [self displayProfile:currentProfile];
    }
    [self setNeedsDisplay:YES];
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];
    [self layoutComparisonPanel];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return (NSInteger)[comparisonEntries count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || row >= (NSInteger)[comparisonEntries count]) return nil;
    NSDictionary *entry = [comparisonEntries objectAtIndex:(NSUInteger)row];
    NSString *ident = [tableColumn identifier];
    if ([ident isEqual:@"name"]) {
        return [[entry objectForKey:@"model"] name];
    }
    if ([ident isEqual:@"visible"]) {
        return [entry objectForKey:@"visible"];
    }
    return nil;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || row >= (NSInteger)[comparisonEntries count]) return;
    if (![[tableColumn identifier] isEqual:@"visible"]) return;
    NSMutableDictionary *entry = [comparisonEntries objectAtIndex:(NSUInteger)row];
    [entry setObject:object forKey:@"visible"];
    [self refreshGamuts];
}

#pragma mark - NSTableViewDelegate

- (BOOL)tableView:(NSTableView *)tableView shouldEditTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [[tableColumn identifier] isEqual:@"visible"];
}

- (void)removeSelectedComparison:(id)sender {
    if (!comparisonTableView) return;
    NSInteger row = [comparisonTableView selectedRow];
    if (row < 0 || row >= (NSInteger)[comparisonEntries count]) return;
    [comparisonEntries removeObjectAtIndex:(NSUInteger)row];
    [comparisonTableView reloadData];
    [self refreshGamuts];
}

- (void)dealloc {
    [comparisonEntries release];
    [renderer release];
    [super dealloc];
}

@end
