//
//  ICCProfile.h
//  SmallICCer
//
//  Represents a loaded ICC profile
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCTag;

@interface ICCProfile : NSObject {
    // Header fields
    NSUInteger profileSize;
    NSString *preferredCMM;
    NSUInteger version;
    NSUInteger deviceClass;
    NSUInteger dataColorSpace;
    NSUInteger pcsColorSpace;
    NSDate *creationDate;
    NSString *platformSignature;
    NSUInteger flags;
    NSString *deviceManufacturer;
    NSString *deviceModel;
    NSUInteger deviceAttributes;
    NSUInteger renderingIntent;
    NSArray *pcsIlluminant; // XYZ values
    NSString *profileCreator;
    
    // Tag table
    NSMutableDictionary *tags;
}

@property (nonatomic) NSUInteger profileSize;
@property (nonatomic, retain) NSString *preferredCMM;
@property (nonatomic) NSUInteger version;
@property (nonatomic) NSUInteger deviceClass;
@property (nonatomic) NSUInteger dataColorSpace;
@property (nonatomic) NSUInteger pcsColorSpace;
@property (nonatomic, retain) NSDate *creationDate;
@property (nonatomic, retain) NSString *platformSignature;
@property (nonatomic) NSUInteger flags;
@property (nonatomic, retain) NSString *deviceManufacturer;
@property (nonatomic, retain) NSString *deviceModel;
@property (nonatomic) NSUInteger deviceAttributes;
@property (nonatomic) NSUInteger renderingIntent;
@property (nonatomic, retain) NSArray *pcsIlluminant;
@property (nonatomic, retain) NSString *profileCreator;
@property (nonatomic, retain) NSMutableDictionary *tags;

- (ICCTag *)tagWithSignature:(NSString *)signature;
- (void)setTag:(ICCTag *)tag withSignature:(NSString *)signature;
- (NSArray *)allTagSignatures;

@end

NS_ASSUME_NONNULL_END
