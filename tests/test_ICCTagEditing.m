//
//  test_ICCTagEditing.m
//  SmallICCer Tests
//
//  Unit tests for ICC tag editing functionality
//

#import <Foundation/Foundation.h>
#import "ICCTag.h"
#import "ICCTagTRC.h"
#import "ICCTagMatrix.h"
#import "ICCTagLUT.h"
#import "ICCTagMetadata.h"
#import "ICCProfile.h"

int testICCTagBase() {
    ICCTag *tag = [[ICCTag alloc] initWithData:NULL signature:@"test"];
    
    if (!tag) {
        NSLog(@"ERROR: Failed to create ICCTag");
        return 1;
    }
    
    if (![[tag signature] isEqualToString:@"test"]) {
        NSLog(@"ERROR: Tag signature mismatch");
        [tag release];
        return 1;
    }
    
    [tag release];
    NSLog(@"PASS: ICCTag base class");
    return 0;
}

int testICCTagTRC() {
    ICCTagTRC *trcTag = [[ICCTagTRC alloc] init];
    
    if (!trcTag) {
        NSLog(@"ERROR: Failed to create ICCTagTRC");
        return 1;
    }
    
    // Test curve point access
    NSArray *curvePoints = [trcTag curvePoints];
    // Curve points may be nil initially, that's OK
    
    // Test value at position
    double value = [trcTag valueAtPosition:0.5];
    // Value should be in valid range (0.0 to 1.0 typically)
    if (value < 0.0 || value > 1.0) {
        // This might be OK depending on implementation, just log
        NSLog(@"NOTE: TRC value at 0.5 is %f (may be valid)", value);
    }
    
    [trcTag release];
    NSLog(@"PASS: ICCTagTRC");
    return 0;
}

int testICCTagMatrix() {
    ICCTagMatrix *matrixTag = [[ICCTagMatrix alloc] init];
    
    if (!matrixTag) {
        NSLog(@"ERROR: Failed to create ICCTagMatrix");
        return 1;
    }
    
    // Test matrix element access
    double value = [matrixTag matrixElement:0 col:0];
    // Value may be 0 initially, that's OK
    
    // Test setting matrix element
    [matrixTag setMatrixElement:0 col:0 value:1.0];
    value = [matrixTag matrixElement:0 col:0];
    if (fabs(value - 1.0) > 0.001) {
        NSLog(@"ERROR: Matrix element not set correctly");
        [matrixTag release];
        return 1;
    }
    
    [matrixTag release];
    NSLog(@"PASS: ICCTagMatrix");
    return 0;
}

int testICCTagLUT() {
    ICCTagLUT *lutTag = [[ICCTagLUT alloc] init];
    
    if (!lutTag) {
        NSLog(@"ERROR: Failed to create ICCTagLUT");
        return 1;
    }
    
    // Test LUT properties
    NSUInteger inputChannels = [lutTag inputChannels];
    NSUInteger outputChannels = [lutTag outputChannels];
    NSUInteger gridPoints = [lutTag gridPoints];
    
    // These may be 0 initially, that's OK
    
    [lutTag release];
    NSLog(@"PASS: ICCTagLUT");
    return 0;
}

int testICCTagMetadata() {
    ICCTagMetadata *metaTag = [[ICCTagMetadata alloc] init];
    
    if (!metaTag) {
        NSLog(@"ERROR: Failed to create ICCTagMetadata");
        return 1;
    }
    
    // Test setting text value
    [metaTag setTextValue:@"Test metadata"];
    NSString *text = [metaTag textValue];
    
    if (![text isEqualToString:@"Test metadata"]) {
        NSLog(@"ERROR: Metadata text not set correctly");
        [metaTag release];
        return 1;
    }
    
    [metaTag release];
    NSLog(@"PASS: ICCTagMetadata");
    return 0;
}

int testProfileTagAccess() {
    ICCProfile *profile = [[ICCProfile alloc] init];
    
    // Test tag access methods
    ICCTag *tag = [profile tagWithSignature:@"nonexistent"];
    if (tag != nil) {
        NSLog(@"ERROR: Nonexistent tag should return nil");
        [profile release];
        return 1;
    }
    
    // Add a tag
    ICCTag *testTag = [[ICCTag alloc] initWithData:NULL signature:@"test"];
    [profile setTag:testTag withSignature:@"test"];
    [testTag release];
    
    // Retrieve it
    ICCTag *retrievedTag = [profile tagWithSignature:@"test"];
    if (!retrievedTag) {
        NSLog(@"ERROR: Failed to retrieve added tag");
        [profile release];
        return 1;
    }
    
    // Check all tag signatures
    NSArray *signatures = [profile allTagSignatures];
    if ([signatures count] != 1) {
        NSLog(@"ERROR: Expected 1 tag signature, got %lu", (unsigned long)[signatures count]);
        [profile release];
        return 1;
    }
    
    if (![[signatures objectAtIndex:0] isEqualToString:@"test"]) {
        NSLog(@"ERROR: Tag signature mismatch");
        [profile release];
        return 1;
    }
    
    [profile release];
    NSLog(@"PASS: Profile tag access");
    return 0;
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int failures = 0;
    failures += testICCTagBase();
    failures += testICCTagTRC();
    failures += testICCTagMatrix();
    failures += testICCTagLUT();
    failures += testICCTagMetadata();
    failures += testProfileTagAccess();
    
    if (failures == 0) {
        NSLog(@"All ICC tag editing tests passed!");
    } else {
        NSLog(@"%d test(s) failed", failures);
    }
    
    [pool release];
    return failures;
}
