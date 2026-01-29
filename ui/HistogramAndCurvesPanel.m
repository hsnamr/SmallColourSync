//
//  HistogramAndCurvesPanel.m
//  SmallICCer
//
//  Histogram and Curves Panel implementation
//

#import "HistogramAndCurvesPanel.h"
#import "ICCProfile.h"
#import "ICCTagTRC.h"

@implementation HistogramAndCurvesPanel

- (id)init {
    self = [super init];
    if (self) {
        NSRect bounds = [self bounds];
        
        // Create curve view
        curveView = [[NSView alloc] initWithFrame:bounds];
        [curveView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        [self addSubview:curveView];
        
        currentProfile = nil;
        redTRC = nil;
        greenTRC = nil;
        blueTRC = nil;
    }
    return self;
}

- (void)displayProfile:(ICCProfile *)profile {
    currentProfile = [profile retain];
    
    // Get TRC tags
    [redTRC release];
    [greenTRC release];
    [blueTRC release];
    
    ICCTag *tag = [profile tagWithSignature:@"rTRC"];
    redTRC = ([tag isKindOfClass:[ICCTagTRC class]]) ? [(ICCTagTRC *)tag retain] : nil;
    
    tag = [profile tagWithSignature:@"gTRC"];
    greenTRC = ([tag isKindOfClass:[ICCTagTRC class]]) ? [(ICCTagTRC *)tag retain] : nil;
    
    tag = [profile tagWithSignature:@"bTRC"];
    blueTRC = ([tag isKindOfClass:[ICCTagTRC class]]) ? [(ICCTagTRC *)tag retain] : nil;
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    NSRect bounds = [self bounds];
    
    // Clear background
    [[NSColor whiteColor] set];
    NSRectFill(bounds);
    
    if (!redTRC && !greenTRC && !blueTRC) {
        // No TRC data to display
        NSDictionary *attrs = @{
            NSFontAttributeName: [NSFont systemFontOfSize:14.0],
            NSForegroundColorAttributeName: [NSColor grayColor]
        };
        NSString *message = @"No TRC curves available";
        NSSize textSize = [message sizeWithAttributes:attrs];
        NSPoint textPoint = NSMakePoint(
            (bounds.size.width - textSize.width) / 2,
            (bounds.size.height - textSize.height) / 2
        );
        [message drawAtPoint:textPoint withAttributes:attrs];
        return;
    }
    
    // Draw axes
    [[NSColor blackColor] set];
    NSBezierPath *axes = [NSBezierPath bezierPath];
    
    // X axis (input: 0.0 to 1.0)
    float margin = 40;
    float plotWidth = bounds.size.width - 2 * margin;
    float plotHeight = bounds.size.height - 2 * margin;
    float plotX = margin;
    float plotY = margin;
    
    // Horizontal axis
    [axes moveToPoint:NSMakePoint(plotX, plotY)];
    [axes lineToPoint:NSMakePoint(plotX + plotWidth, plotY)];
    
    // Vertical axis
    [axes moveToPoint:NSMakePoint(plotX, plotY)];
    [axes lineToPoint:NSMakePoint(plotX, plotY + plotHeight)];
    
    [axes setLineWidth:1.0];
    [axes stroke];
    
    // Draw grid lines
    [[NSColor lightGrayColor] set];
    NSBezierPath *grid = [NSBezierPath bezierPath];
    [grid setLineWidth:0.5];
    
    // Vertical grid lines
    for (int i = 0; i <= 10; i++) {
        float x = plotX + (plotWidth * i / 10.0);
        [grid moveToPoint:NSMakePoint(x, plotY)];
        [grid lineToPoint:NSMakePoint(x, plotY + plotHeight)];
    }
    
    // Horizontal grid lines
    for (int i = 0; i <= 10; i++) {
        float y = plotY + (plotHeight * i / 10.0);
        [grid moveToPoint:NSMakePoint(plotX, y)];
        [grid lineToPoint:NSMakePoint(plotX + plotWidth, y)];
    }
    [grid stroke];
    
    // Draw curves
    if (redTRC) {
        [self drawCurve:redTRC color:[NSColor redColor] inRect:NSMakeRect(plotX, plotY, plotWidth, plotHeight)];
    }
    if (greenTRC) {
        [self drawCurve:greenTRC color:[NSColor greenColor] inRect:NSMakeRect(plotX, plotY, plotWidth, plotHeight)];
    }
    if (blueTRC) {
        [self drawCurve:blueTRC color:[NSColor blueColor] inRect:NSMakeRect(plotX, plotY, plotWidth, plotHeight)];
    }
    
    // Draw labels
    NSDictionary *labelAttrs = @{
        NSFontAttributeName: [NSFont systemFontOfSize:10.0],
        NSForegroundColorAttributeName: [NSColor blackColor]
    };
    
    // X axis label
    NSString *xLabel = @"Input (0.0 - 1.0)";
    NSSize xLabelSize = [xLabel sizeWithAttributes:labelAttrs];
    [xLabel drawAtPoint:NSMakePoint(plotX + (plotWidth - xLabelSize.width) / 2, plotY - 20) withAttributes:labelAttrs];
    
    // Y axis label
    NSString *yLabel = @"Output (0.0 - 1.0)";
    NSSize yLabelSize = [yLabel sizeWithAttributes:labelAttrs];
    // Rotate for vertical label (simplified - would use NSAffineTransform in full implementation)
    [yLabel drawAtPoint:NSMakePoint(5, plotY + (plotHeight - yLabelSize.width) / 2) withAttributes:labelAttrs];
    
    // Legend
    float legendY = bounds.size.height - 30;
    float legendX = bounds.size.width - 150;
    if (redTRC) {
        [[NSColor redColor] set];
        NSRectFill(NSMakeRect(legendX, legendY, 15, 15));
        [@"Red" drawAtPoint:NSMakePoint(legendX + 20, legendY) withAttributes:labelAttrs];
        legendY -= 20;
    }
    if (greenTRC) {
        [[NSColor greenColor] set];
        NSRectFill(NSMakeRect(legendX, legendY, 15, 15));
        [@"Green" drawAtPoint:NSMakePoint(legendX + 20, legendY) withAttributes:labelAttrs];
        legendY -= 20;
    }
    if (blueTRC) {
        [[NSColor blueColor] set];
        NSRectFill(NSMakeRect(legendX, legendY, 15, 15));
        [@"Blue" drawAtPoint:NSMakePoint(legendX + 20, legendY) withAttributes:labelAttrs];
    }
}

- (void)drawCurve:(ICCTagTRC *)trc color:(NSColor *)color inRect:(NSRect)rect {
    NSArray *points = [trc curvePoints];
    if ([points count] == 0) {
        return;
    }
    
    NSBezierPath *curve = [NSBezierPath bezierPath];
    [curve setLineWidth:2.0];
    [color set];
    
    NSUInteger pointCount = [points count];
    BOOL firstPoint = YES;
    
    for (NSUInteger i = 0; i < pointCount; i++) {
        double input = (double)i / (pointCount - 1);
        double output = [[points objectAtIndex:i] doubleValue];
        
        // Clamp output to valid range
        if (output < 0.0) output = 0.0;
        if (output > 1.0) output = 1.0;
        
        float x = rect.origin.x + input * rect.size.width;
        float y = rect.origin.y + output * rect.size.height;
        
        NSPoint point = NSMakePoint(x, y);
        
        if (firstPoint) {
            [curve moveToPoint:point];
            firstPoint = NO;
        } else {
            [curve lineToPoint:point];
        }
    }
    
    [curve stroke];
}

- (void)dealloc {
    [curveView release];
    [currentProfile release];
    [redTRC release];
    [greenTRC release];
    [blueTRC release];
    [super dealloc];
}

@end
