//
//  ICCTagMetadata.h
//  SmallICCer
//
//  Metadata tag (text, description, etc.)
//

#import "ICCTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface ICCTagMetadata : ICCTag {
    NSString *textValue;
    NSString *locale;
}

@property (nonatomic, retain) NSString *textValue;
@property (nonatomic, retain) NSString *locale;

@end

NS_ASSUME_NONNULL_END
