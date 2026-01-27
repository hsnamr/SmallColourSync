//
//  ICCParser.h
//  SmallICCer
//
//  Parses ICC profile files
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ICCProfile;

@interface ICCParser : NSObject

- (ICCProfile *)parseProfileFromPath:(NSString *)path error:(NSError **)error;
- (ICCProfile *)parseProfileFromData:(NSData *)data error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
