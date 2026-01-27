//
//  SettingsManager.h
//  SmallICCer
//
//  Manages user preferences and settings
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsManager : NSObject {
    NSUserDefaults *defaults;
    NSInteger renderingQuality;
    NSArray *comparisonColorSpaces;
    BOOL showGrid;
    BOOL showAxes;
    CGFloat backgroundColorRed;
    CGFloat backgroundColorGreen;
    CGFloat backgroundColorBlue;
}

// Rendering quality settings
@property (nonatomic) NSInteger renderingQuality; // 0=low, 1=medium, 2=high

// Color space presets
@property (nonatomic, retain) NSArray *comparisonColorSpaces;

// UI layout preferences
@property (nonatomic) BOOL showGrid;
@property (nonatomic) BOOL showAxes;
@property (nonatomic) CGFloat backgroundColorRed;
@property (nonatomic) CGFloat backgroundColorGreen;
@property (nonatomic) CGFloat backgroundColorBlue;

+ (SettingsManager *)sharedManager;
- (void)saveSettings;
- (void)loadSettings;

@end

NS_ASSUME_NONNULL_END
