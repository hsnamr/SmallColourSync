//
//  ProfileInspectorPanel.m
//  SmallICCer
//
//  Profile Inspector Panel implementation
//

#import "ProfileInspectorPanel.h"
#import "ICCProfile.h"
#import "ICCTag.h"
#import "ICCTagTRC.h"
#import "ICCTagMatrix.h"
#import "ICCTagLUT.h"
#import "ICCTagMetadata.h"

@implementation ProfileInspectorPanel

- (id)init {
    self = [super init];
    if (self) {
        NSRect bounds = [self bounds];
        
        // Create split view to divide metadata and tag table
        NSSplitView *splitView = [[NSSplitView alloc] initWithFrame:bounds];
        [splitView setVertical:NO];
        [splitView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [splitView setDividerStyle:NSSplitViewDividerStyleThin];
        
        // Create metadata section (top half)
        NSRect metadataFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height / 2);
        metadataScrollView = [[NSScrollView alloc] initWithFrame:metadataFrame];
        [metadataScrollView setHasHorizontalScroller:YES];
        [metadataScrollView setHasVerticalScroller:YES];
        [metadataScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [metadataScrollView setBorderType:NSBezelBorder];
        
        metadataView = [[NSTextView alloc] initWithFrame:[[metadataScrollView contentView] bounds]];
        [metadataView setEditable:NO];
        [metadataView setSelectable:YES];
        [metadataView setFont:[NSFont userFixedPitchFontOfSize:11.0]];
        [metadataView setTextContainerInset:NSMakeSize(8, 8)];
        [metadataScrollView setDocumentView:metadataView];
        
        // Create tag table section (bottom half)
        NSRect tableFrame = NSMakeRect(0, 0, bounds.size.width, bounds.size.height / 2);
        tagTableScrollView = [[NSScrollView alloc] initWithFrame:tableFrame];
        [tagTableScrollView setHasHorizontalScroller:YES];
        [tagTableScrollView setHasVerticalScroller:YES];
        [tagTableScrollView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [tagTableScrollView setBorderType:NSBezelBorder];
        
        // Create table view with columns
        tagTableView = [[NSTableView alloc] initWithFrame:[[tagTableScrollView contentView] bounds]];
        
        // Tag Signature column
        NSTableColumn *signatureColumn = [[NSTableColumn alloc] initWithIdentifier:@"signature"];
        [[signatureColumn headerCell] setStringValue:@"Tag Signature"];
        [signatureColumn setWidth:150];
        [signatureColumn setMinWidth:100];
        [tagTableView addTableColumn:signatureColumn];
        [signatureColumn release];
        
        // Tag Type column
        NSTableColumn *typeColumn = [[NSTableColumn alloc] initWithIdentifier:@"type"];
        [[typeColumn headerCell] setStringValue:@"Type"];
        [typeColumn setWidth:120];
        [typeColumn setMinWidth:80];
        [tagTableView addTableColumn:typeColumn];
        [typeColumn release];
        
        // Tag Size column
        NSTableColumn *sizeColumn = [[NSTableColumn alloc] initWithIdentifier:@"size"];
        [[sizeColumn headerCell] setStringValue:@"Size"];
        [sizeColumn setWidth:80];
        [sizeColumn setMinWidth:60];
        [tagTableView addTableColumn:sizeColumn];
        [sizeColumn release];
        
        [tagTableView setDataSource:self];
        [tagTableView setAllowsColumnReordering:YES];
        [tagTableView setAllowsColumnResizing:YES];
        [tagTableView setUsesAlternatingRowBackgroundColors:YES];
        [tagTableView setGridStyleMask:NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask];
        
        [tagTableScrollView setDocumentView:tagTableView];
        
        // Add both sections to split view
        [splitView addSubview:metadataScrollView];
        [splitView addSubview:tagTableScrollView];
        [splitView adjustSubviews];
        
        // Add split view to our view
        [self addSubview:splitView];
        [splitView release];
        
        // Initialize tag signatures array
        tagSignatures = [[NSArray alloc] init];
    }
    return self;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = [profile retain];
    
    // Update metadata view with formatted text
    NSMutableAttributedString *metadata = [[NSMutableAttributedString alloc] init];
    
    // Header section
    NSDictionary *headerAttrs = @{
        NSFontAttributeName: [NSFont boldSystemFontOfSize:12.0],
        NSForegroundColorAttributeName: [NSColor labelColor]
    };
    NSDictionary *valueAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:11.0],
        NSForegroundColorAttributeName: [NSColor labelColor]
    };
    
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Profile Information\n" attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"─────────────────\n\n" attributes:valueAttrs] autorelease]];
    
    // Basic information
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Size: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu bytes\n", (unsigned long)[profile profileSize]] attributes:valueAttrs] autorelease]];
    
    // Format version (major.minor.bugfix)
    NSUInteger version = [profile version];
    NSUInteger major = (version >> 24) & 0xFF;
    NSUInteger minor = (version >> 16) & 0xFF;
    NSUInteger bugfix = (version >> 8) & 0xFF;
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Version: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%lu.%lu.%lu\n", major, minor, bugfix] attributes:valueAttrs] autorelease]];
    
    // Device class
    NSString *deviceClassStr = @"Unknown";
    NSUInteger deviceClass = [profile deviceClass];
    if (deviceClass == 0x73636E72) deviceClassStr = @"Input Device (scnr)";
    else if (deviceClass == 0x6D6E7472) deviceClassStr = @"Display Device (mntr)";
    else if (deviceClass == 0x70727472) deviceClassStr = @"Output Device (prtr)";
    else if (deviceClass == 0x6C696E6B) deviceClassStr = @"Device Link (link)";
    else if (deviceClass == 0x73706163) deviceClassStr = @"Color Space (spac)";
    else if (deviceClass == 0x61627374) deviceClassStr = @"Abstract (abst)";
    else if (deviceClass == 0x6E6D636C) deviceClassStr = @"Named Color (nmcl)";
    
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Device Class: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (0x%08lX)\n", deviceClassStr, (unsigned long)deviceClass] attributes:valueAttrs] autorelease]];
    
    // Color spaces
    NSString *dataColorSpaceStr = [self stringForColorSpace:[profile dataColorSpace]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Data Color Space: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (0x%08lX)\n", dataColorSpaceStr, (unsigned long)[profile dataColorSpace]] attributes:valueAttrs] autorelease]];
    
    NSString *pcsColorSpaceStr = [self stringForColorSpace:[profile pcsColorSpace]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"PCS Color Space: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (0x%08lX)\n", pcsColorSpaceStr, (unsigned long)[profile pcsColorSpace]] attributes:valueAttrs] autorelease]];
    
    // Creation date
    if ([profile creationDate]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Creation Date: " attributes:headerAttrs] autorelease]];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [formatter stringFromDate:[profile creationDate]]] attributes:valueAttrs] autorelease]];
        [formatter release];
    }
    
    // Rendering intent
    NSString *intentStr = @"Unknown";
    NSUInteger intent = [profile renderingIntent];
    if (intent == 0) intentStr = @"Perceptual";
    else if (intent == 1) intentStr = @"Relative Colorimetric";
    else if (intent == 2) intentStr = @"Saturation";
    else if (intent == 3) intentStr = @"Absolute Colorimetric";
    
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Rendering Intent: " attributes:headerAttrs] autorelease]];
    [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ (%lu)\n", intentStr, (unsigned long)intent] attributes:valueAttrs] autorelease]];
    
    // PCS Illuminant
    if ([profile pcsIlluminant] && [[profile pcsIlluminant] count] >= 3) {
        NSArray *illuminant = [profile pcsIlluminant];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"PCS Illuminant (XYZ): " attributes:headerAttrs] autorelease]];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"X=%.4f Y=%.4f Z=%.4f\n", 
                                                                                      [[illuminant objectAtIndex:0] doubleValue],
                                                                                      [[illuminant objectAtIndex:1] doubleValue],
                                                                                      [[illuminant objectAtIndex:2] doubleValue]] attributes:valueAttrs] autorelease]];
    }
    
    // Device info
    if ([profile deviceManufacturer]) {
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Device Manufacturer: " attributes:headerAttrs] autorelease]];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [profile deviceManufacturer]] attributes:valueAttrs] autorelease]];
    }
    
    if ([profile deviceModel]) {
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:@"Device Model: " attributes:headerAttrs] autorelease]];
        [metadata appendAttributedString:[[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", [profile deviceModel]] attributes:valueAttrs] autorelease]];
    }
    
    // Set the attributed string to the text view
    [[metadataView textStorage] setAttributedString:metadata];
    [metadata release];
    
    // Update tag table
    NSArray *allSignatures = [profile allTagSignatures];
    tagSignatures = [[allSignatures sortedArrayUsingSelector:@selector(compare:)] retain];
    [tagTableView reloadData];
}

- (NSString *)stringForColorSpace:(NSUInteger)colorSpace {
    if (colorSpace == 0x52474220) return @"RGB";
    if (colorSpace == 0x434D594B) return @"CMYK";
    if (colorSpace == 0x47524159) return @"Gray";
    if (colorSpace == 0x4C616220) return @"Lab";
    if (colorSpace == 0x58595A20) return @"XYZ";
    if (colorSpace == 0x48735620) return @"HSV";
    if (colorSpace == 0x484C5320) return @"HLS";
    if (colorSpace == 0x59436272) return @"YCbCr";
    if (colorSpace == 0x59756272) return @"YUV";
    return [NSString stringWithFormat:@"Unknown (0x%08lX)", (unsigned long)colorSpace];
}

// NSTableViewDataSource methods
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [tagSignatures count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if (row < 0 || row >= [tagSignatures count] || !currentProfile) {
        return nil;
    }
    
    NSString *signature = [tagSignatures objectAtIndex:row];
    ICCTag *tag = [currentProfile tagWithSignature:signature];
    
    if (!tag) {
        return nil;
    }
    
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"signature"]) {
        return signature;
    } else if ([identifier isEqualToString:@"type"]) {
        // Determine tag type from class
        if ([tag isKindOfClass:[ICCTagTRC class]]) {
            return @"TRC";
        } else if ([tag isKindOfClass:[ICCTagMatrix class]]) {
            return @"Matrix";
        } else if ([tag isKindOfClass:[ICCTagLUT class]]) {
            return @"LUT";
        } else if ([tag isKindOfClass:[ICCTagMetadata class]]) {
            return @"Metadata";
        } else {
            return @"Generic";
        }
    } else if ([identifier isEqualToString:@"size"]) {
        NSData *data = [tag rawData];
        if (data) {
            return [NSString stringWithFormat:@"%lu bytes", (unsigned long)[data length]];
        } else {
            return @"N/A";
        }
    }
    
    return nil;
}

- (void)dealloc {
    [metadataScrollView release];
    [metadataView release];
    [tagTableScrollView release];
    [tagTableView release];
    [currentProfile release];
    [tagSignatures release];
    [super dealloc];
}

@end
