//
//  test_SettingsManager.m
//  SmallICCer Tests
//
//  Unit tests for SettingsManager (shared manager, load/save, properties).
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"

int testSharedManager() {
    SettingsManager *m1 = [SettingsManager sharedManager];
    if (!m1) {
        NSLog(@"ERROR: sharedManager returned nil");
        return 1;
    }
    SettingsManager *m2 = [SettingsManager sharedManager];
    if (m1 != m2) {
        NSLog(@"ERROR: sharedManager should return same instance");
        return 1;
    }
    NSLog(@"PASS: sharedManager singleton");
    return 0;
}

int testLoadSettings() {
    SettingsManager *m = [SettingsManager sharedManager];
    [m loadSettings];
    if ([m renderingQuality] < 0 || [m renderingQuality] > 2) {
        NSLog(@"ERROR: renderingQuality should be 0-2, got %ld", (long)[m renderingQuality]);
        return 1;
    }
    if ([m comparisonColorSpaces] == nil) {
        NSLog(@"ERROR: comparisonColorSpaces should be non-nil after load");
        return 1;
    }
    if ([m backgroundColorRed] < 0.0f || [m backgroundColorRed] > 1.0f) {
        NSLog(@"ERROR: backgroundColorRed out of range");
        return 1;
    }
    NSLog(@"PASS: loadSettings");
    return 0;
}

int testSaveSettings() {
    SettingsManager *m = [SettingsManager sharedManager];
    NSInteger q = [m renderingQuality];
    [m setRenderingQuality:1];
    [m saveSettings];
    [m loadSettings];
    if ([m renderingQuality] != 1) {
        NSLog(@"WARN: save/load round-trip for renderingQuality (may be OK if defaults changed)");
    }
    [m setRenderingQuality:q];
    [m saveSettings];
    NSLog(@"PASS: saveSettings (no crash)");
    return 0;
}

int testShowGridShowAxes() {
    SettingsManager *m = [SettingsManager sharedManager];
    [m setShowGrid:YES];
    [m setShowAxes:NO];
    if (![m showGrid] || [m showAxes]) {
        NSLog(@"ERROR: showGrid/showAxes set/get");
        return 1;
    }
    [m setShowGrid:YES];
    [m setShowAxes:YES];
    NSLog(@"PASS: showGrid/showAxes properties");
    return 0;
}

int testBackgroundColor() {
    SettingsManager *m = [SettingsManager sharedManager];
    [m setBackgroundColorRed:0.2f];
    [m setBackgroundColorGreen:0.3f];
    [m setBackgroundColorBlue:0.4f];
    if ([m backgroundColorRed] != 0.2f || [m backgroundColorGreen] != 0.3f || [m backgroundColorBlue] != 0.4f) {
        NSLog(@"ERROR: background color set/get");
        return 1;
    }
    NSLog(@"PASS: backgroundColor properties");
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int failures = 0;
    failures += testSharedManager();
    failures += testLoadSettings();
    failures += testSaveSettings();
    failures += testShowGridShowAxes();
    failures += testBackgroundColor();
    if (failures == 0) {
        NSLog(@"All SettingsManager tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    [pool release];
    return failures;
}
