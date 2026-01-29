//
//  TagEditorPanel.m
//  SmallICCer
//
//  Tag Editor Panel implementation
//

#import "TagEditorPanel.h"
#import "ICCProfile.h"
#import "ICCTag.h"
#import "ICCTagTRC.h"
#import "ICCTagMatrix.h"
#import "ICCTagLUT.h"
#import "ICCTagMetadata.h"

@implementation TagEditorPanel

- (id)init {
    self = [super init];
    if (self) {
        NSRect bounds = [self bounds];
        
        // Create tag selector at top
        tagSelector = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, bounds.size.height - 40, 200, 25)];
        [tagSelector setTarget:self];
        [tagSelector setAction:@selector(tagSelectionChanged:)];
        [tagSelector setAutoresizingMask:NSViewMinYMargin];
        [self addSubview:tagSelector];
        
        // Create container for tag-specific editors
        NSRect editorFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height - 50);
        tagEditorView = [[NSView alloc] initWithFrame:editorFrame];
        [tagEditorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:tagEditorView];
        
        // Initialize all editor views (hidden initially)
        [self setupTRCEditor];
        [self setupMatrixEditor];
        [self setupLUTEditor];
        [self setupMetadataEditor];
        
        currentProfile = nil;
    }
    return self;
}

- (void)setupTRCEditor {
    NSRect bounds = [tagEditorView bounds];
    
    trcEditorView = [[NSView alloc] initWithFrame:bounds];
    [trcEditorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [trcEditorView setHidden:YES];
    [tagEditorView addSubview:trcEditorView];
    
    // Label
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, bounds.size.height - 30, 300, 20)];
    [label setStringValue:@"Tone Reproduction Curve (TRC)"];
    [label setEditable:NO];
    [label setBordered:NO];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setFont:[NSFont boldSystemFontOfSize:12]];
    [trcEditorView addSubview:label];
    [label release];
    
    // Curve display area (simplified - would use custom view for interactive editing)
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, bounds.size.width - 20, bounds.size.height - 50)];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [scrollView setBorderType:NSBezelBorder];
    
    trcCurveView = [[NSTextView alloc] initWithFrame:[[scrollView contentView] bounds]];
    [trcCurveView setEditable:NO];
    [trcCurveView setFont:[NSFont userFixedPitchFontOfSize:10.0]];
    [trcCurveView setTextContainerInset:NSMakeSize(8, 8)];
    [scrollView setDocumentView:trcCurveView];
    [trcEditorView addSubview:scrollView];
    [scrollView release];
}

- (void)setupMatrixEditor {
    NSRect bounds = [tagEditorView bounds];
    
    matrixEditorView = [[NSView alloc] initWithFrame:bounds];
    [matrixEditorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [matrixEditorView setHidden:YES];
    [tagEditorView addSubview:matrixEditorView];
    
    // Label
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, bounds.size.height - 30, 300, 20)];
    [label setStringValue:@"Matrix Transformation"];
    [label setEditable:NO];
    [label setBordered:NO];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setFont:[NSFont boldSystemFontOfSize:12]];
    [matrixEditorView addSubview:label];
    [label release];
    
    // Matrix grid (3x3)
    NSUInteger i, j;
    float startX = 50;
    float startY = bounds.size.height - 80;
    float cellWidth = 80;
    float cellHeight = 22;
    float spacing = 10;
    
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            NSRect fieldRect = NSMakeRect(startX + j * (cellWidth + spacing),
                                          startY - i * (cellHeight + spacing),
                                          cellWidth, cellHeight);
            matrixFields[i][j] = [[NSTextField alloc] initWithFrame:fieldRect];
            [matrixFields[i][j] setStringValue:@"0.0"];
            [matrixFields[i][j] setTarget:self];
            [matrixFields[i][j] setAction:@selector(matrixValueChanged:)];
            [matrixEditorView addSubview:matrixFields[i][j]];
        }
    }
    
    // Offset vector
    NSTextField *offsetLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, startY - 3 * (cellHeight + spacing) - 10, 100, 20)];
    [offsetLabel setStringValue:@"Offset:"];
    [offsetLabel setEditable:NO];
    [offsetLabel setBordered:NO];
    [offsetLabel setBackgroundColor:[NSColor clearColor]];
    [matrixEditorView addSubview:offsetLabel];
    [offsetLabel release];
    
    for (i = 0; i < 3; i++) {
        NSRect fieldRect = NSMakeRect(startX + i * (cellWidth + spacing),
                                      startY - 3 * (cellHeight + spacing) - 10,
                                      cellWidth, cellHeight);
        offsetFields[i] = [[NSTextField alloc] initWithFrame:fieldRect];
        [offsetFields[i] setStringValue:@"0.0"];
        [offsetFields[i] setTarget:self];
        [offsetFields[i] setAction:@selector(matrixValueChanged:)];
        [matrixEditorView addSubview:offsetFields[i]];
    }
}

- (void)setupLUTEditor {
    NSRect bounds = [tagEditorView bounds];
    
    lutEditorView = [[NSView alloc] initWithFrame:bounds];
    [lutEditorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [lutEditorView setHidden:YES];
    [tagEditorView addSubview:lutEditorView];
    
    // Label
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, bounds.size.height - 30, 300, 20)];
    [label setStringValue:@"Look-Up Table (LUT)"];
    [label setEditable:NO];
    [label setBordered:NO];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setFont:[NSFont boldSystemFontOfSize:12]];
    [lutEditorView addSubview:label];
    [label release];
    
    // LUT info display (read-only for now - full editing is complex)
    lutInfoView = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, bounds.size.width - 20, bounds.size.height - 50)];
    [lutInfoView setEditable:NO];
    [lutInfoView setBordered:YES];
    [lutInfoView setBackgroundColor:[NSColor textBackgroundColor]];
    [lutInfoView setFont:[NSFont userFixedPitchFontOfSize:11.0]];
    [lutEditorView addSubview:lutInfoView];
}

- (void)setupMetadataEditor {
    NSRect bounds = [tagEditorView bounds];
    
    metadataEditorView = [[NSView alloc] initWithFrame:bounds];
    [metadataEditorView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [metadataEditorView setHidden:YES];
    [tagEditorView addSubview:metadataEditorView];
    
    // Label
    NSTextField *label = [[NSTextField alloc] initWithFrame:NSMakeRect(10, bounds.size.height - 30, 300, 20)];
    [label setStringValue:@"Metadata"];
    [label setEditable:NO];
    [label setBordered:NO];
    [label setBackgroundColor:[NSColor clearColor]];
    [label setFont:[NSFont boldSystemFontOfSize:12]];
    [metadataEditorView addSubview:label];
    [label release];
    
    // Text view for metadata
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, bounds.size.width - 20, bounds.size.height - 50)];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    [scrollView setBorderType:NSBezelBorder];
    
    metadataTextView = [[NSTextView alloc] initWithFrame:[[scrollView contentView] bounds]];
    [metadataTextView setEditable:YES];
    [metadataTextView setFont:[NSFont systemFontOfSize:11.0]];
    [metadataTextView setTextContainerInset:NSMakeSize(8, 8)];
    [metadataTextView setDelegate:self];
    [scrollView setDocumentView:metadataTextView];
    [metadataEditorView addSubview:scrollView];
    [scrollView release];
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = [profile retain];
    
    // Populate tag selector
    [tagSelector removeAllItems];
    NSArray *tagSignatures = [profile allTagSignatures];
    
    if ([tagSignatures count] == 0) {
        [tagSelector addItemWithTitle:@"No tags available"];
        [tagSelector setEnabled:NO];
    } else {
        [tagSelector addItemWithTitle:@"Select a tag..."];
        for (NSString *signature in tagSignatures) {
            [tagSelector addItemWithTitle:signature];
        }
        [tagSelector setEnabled:YES];
    }
    
    // Show "no tag selected" state
    [self showNoTagSelected];
}

- (void)tagSelectionChanged:(id)sender {
    NSInteger selectedIndex = [tagSelector indexOfSelectedItem];
    if (selectedIndex <= 0 || !currentProfile) {
        [self showNoTagSelected];
        return;
    }
    
    NSString *selectedSignature = [[tagSelector itemTitleAtIndex:selectedIndex] retain];
    ICCTag *tag = [currentProfile tagWithSignature:selectedSignature];
    
    if (!tag) {
        [self showNoTagSelected];
        [selectedSignature release];
        return;
    }
    
    // Hide all editors
    [trcEditorView setHidden:YES];
    [matrixEditorView setHidden:YES];
    [lutEditorView setHidden:YES];
    [metadataEditorView setHidden:YES];
    
    // Show appropriate editor
    if ([tag isKindOfClass:[ICCTagTRC class]]) {
        [self displayTRCTag:(ICCTagTRC *)tag];
    } else if ([tag isKindOfClass:[ICCTagMatrix class]]) {
        [self displayMatrixTag:(ICCTagMatrix *)tag];
    } else if ([tag isKindOfClass:[ICCTagLUT class]]) {
        [self displayLUTTag:(ICCTagLUT *)tag];
    } else if ([tag isKindOfClass:[ICCTagMetadata class]]) {
        [self displayMetadataTag:(ICCTagMetadata *)tag];
    } else {
        [self showNoTagSelected];
    }
    
    [selectedSignature release];
}

- (void)showNoTagSelected {
    [trcEditorView setHidden:YES];
    [matrixEditorView setHidden:YES];
    [lutEditorView setHidden:YES];
    [metadataEditorView setHidden:YES];
}

- (void)displayTRCTag:(ICCTagTRC *)tag {
    [trcEditorView setHidden:NO];
    
    // Display curve information
    NSMutableString *curveInfo = [NSMutableString string];
    [curveInfo appendFormat:@"TRC Tag: %@\n", [tag signature]];
    [curveInfo appendFormat:@"Curve Type: %s\n", [tag curveType] == 0 ? "Parametric" : "Table"];
    [curveInfo appendString:@"\nCurve Points:\n"];
    
    NSArray *points = [tag curvePoints];
    if ([points count] > 0) {
        NSUInteger sampleCount = MIN(20, [points count]); // Show first 20 points
        NSUInteger i;
        for (i = 0; i < sampleCount; i++) {
            double input = (double)i / (sampleCount - 1);
            double output = [[points objectAtIndex:i] doubleValue];
            [curveInfo appendFormat:@"  Input: %.3f -> Output: %.6f\n", input, output];
        }
        if ([points count] > sampleCount) {
            [curveInfo appendFormat:@"  ... (%lu more points)\n", (unsigned long)([points count] - sampleCount)];
        }
    } else {
        [curveInfo appendString:@"  (No curve points)\n"];
    }
    
    [[trcCurveView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:curveInfo] autorelease]];
}

- (void)displayMatrixTag:(ICCTagMatrix *)tag {
    [matrixEditorView setHidden:NO];
    
    // Populate matrix fields
    NSUInteger i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            double value = [tag matrixElement:i col:j];
            [[matrixFields[i][j] cell] setStringValue:[NSString stringWithFormat:@"%.6f", value]];
        }
    }
    
    // Note: Offset fields would need to be added to ICCTagMatrix interface
    // For now, just show matrix
}

- (void)displayLUTTag:(ICCTagLUT *)tag {
    [lutEditorView setHidden:NO];
    
    NSMutableString *lutInfo = [NSMutableString string];
    [lutInfo appendFormat:@"LUT Tag: %@\n", [tag signature]];
    [lutInfo appendFormat:@"Input Channels: %lu\n", (unsigned long)[tag inputChannels]];
    [lutInfo appendFormat:@"Output Channels: %lu\n", (unsigned long)[tag outputChannels]];
    [lutInfo appendFormat:@"Grid Points: %lu\n", (unsigned long)[tag gridPoints]];
    
    NSData *data = [tag lutData];
    if (data) {
        [lutInfo appendFormat:@"LUT Data Size: %lu bytes\n", (unsigned long)[data length]];
    } else {
        [lutInfo appendString:@"LUT Data: Not available\n"];
    }
    
    [lutInfo appendString:@"\nNote: Full LUT editing is complex and not yet implemented.\n"];
    [lutInfo appendString:@"LUT data is read-only in this version."];
    
    [lutInfoView setStringValue:lutInfo];
}

- (void)displayMetadataTag:(ICCTagMetadata *)tag {
    [metadataEditorView setHidden:NO];
    
    NSString *text = [tag textValue];
    if (text) {
        [[metadataTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:text] autorelease]];
    } else {
        [[metadataTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:@""] autorelease]];
    }
}

- (void)matrixValueChanged:(id)sender {
    // Find which field changed and update the tag
    // This would need to be connected to the profile update mechanism
    // For now, just a placeholder
}

- (void)textDidChange:(NSNotification *)notification {
    if ([notification object] == metadataTextView) {
        // Update metadata tag when text changes
        NSInteger selectedIndex = [tagSelector indexOfSelectedItem];
        if (selectedIndex > 0 && currentProfile) {
            NSString *signature = [tagSelector itemTitleAtIndex:selectedIndex];
            ICCTag *tag = [currentProfile tagWithSignature:signature];
            if ([tag isKindOfClass:[ICCTagMetadata class]]) {
                NSString *newText = [[metadataTextView string] copy];
                [(ICCTagMetadata *)tag setTextValue:newText];
                [newText release];
            }
        }
    }
}

- (void)dealloc {
    [tagSelector release];
    [tagEditorView release];
    [trcEditorView release];
    [trcCurveView release];
    [matrixEditorView release];
    NSUInteger i, j;
    for (i = 0; i < 3; i++) {
        for (j = 0; j < 3; j++) {
            [matrixFields[i][j] release];
        }
        [offsetFields[i] release];
    }
    [lutEditorView release];
    [lutInfoView release];
    [metadataEditorView release];
    [metadataTextView release];
    [currentProfile release];
    [super dealloc];
}

@end
